#!/usr/bin/env python3
"""Maintain separate, validated rsyslog client and server role files."""

import os
import re
import shutil
import socket
import subprocess
import sys
from pathlib import Path

from configuration_transaction import publish
from ssh_configuration import read_regular


CLIENT = re.compile(r'^\s*(?:\*\.\*\s+@@?\S+|action\(\s*type="omfwd")', re.MULTILINE)
UDP = re.compile(r'^\s*(?:input\(\s*type="imudp"|\$UDPServerRun\s+)', re.MULTILINE)
TCP = re.compile(r'^\s*(?:input\(\s*type="imtcp"|\$InputTCPServerRun\s+)', re.MULTILINE)
HEADER = {"client": "# DIU SYSLOG CLIENT v1\n", "server": "# DIU SYSLOG SERVER v1\n"}


def context(prefix, role):
    if role not in HEADER:
        raise ValueError("rôle syslog invalide")
    etc = prefix / "etc"
    main = etc / "rsyslog.conf"
    directory = etc / "rsyslog.d"
    if any(path.is_symlink() for path in (etc, directory)) or not directory.is_dir():
        raise ValueError("répertoire syslog inaccessible ou symbolique")
    main_bytes, _ = read_regular(main)
    main_text = main_bytes.decode("utf-8")
    if "rsyslog.d/" not in main_text or "*.conf" not in main_text:
        raise ValueError("inclusion du répertoire syslog non vérifiable")
    target = directory / f"40-diu-{role}.conf"
    other_texts = [main_text]
    for path in sorted(directory.glob("*.conf")):
        if path == target:
            continue
        data, _ = read_regular(path)
        other_texts.append(data.decode("utf-8"))
    data, metadata = read_regular(target, missing=True)
    if metadata is not None and not data.startswith(HEADER[role].encode()):
        raise ValueError("fichier syslog DIU déjà occupé")
    return main, target, data, metadata, "\n".join(other_texts)


def client_target():
    target = os.environ.get("SYSLOG_CLIENT_SERVER", "")
    if not re.fullmatch(r"[A-Za-z0-9.\[\]:_-]+", target):
        raise ValueError("destination syslog client absente ou invalide")
    return target


def server_flags():
    result = {}
    for name in ("KERNEL", "OMADA", "SSO", "SURICATA"):
        value = os.environ.get("SYSLOG_SERVER_SKIL_" + name, "0")
        if value not in ("0", "1"):
            raise ValueError("option syslog serveur invalide")
        result[name] = value == "1"
    return result


def client_config():
    target = client_target()
    return (HEADER["client"] +
            f'template(name="diu_client_kernel" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")\n'
            f'if ($programname == "ulogd" or $msg contains "REJECT") then {{\n'
            f'  action(type="omfwd" target="{target}" port="514" protocol="udp" template="diu_client_kernel")\n'
            '  stop\n}\n' + f'*.* @{target}:514\nstop\n').encode()


def server_config(other_text):
    flags = server_flags()
    hostname = os.environ.get("HOSTNAME") or socket.gethostname()
    if not re.fullmatch(r"[A-Za-z0-9._-]+", hostname):
        raise ValueError("nom système syslog invalide")
    lines = [HEADER["server"].rstrip("\n")]
    if not re.search(r'^\s*module\(\s*load="imudp"', other_text, re.MULTILINE):
        lines.append('module(load="imudp")')
    if not re.search(r'^\s*module\(\s*load="imtcp"', other_text, re.MULTILINE):
        lines.append('module(load="imtcp")')
    lines.extend([
        'template(name="diu_remote_path" type="string" string="/var/log/machines/%HOSTNAME%/%PROGRAMNAME%.log")',
        'template(name="diu_kernel" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")',
        'template(name="diu_omada" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% omada:%msg%\\n")',
        'template(name="diu_sso" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% lemonldap-ng:%msg%\\n")',
    ])
    if flags["SURICATA"]:
        for destination in ("fw-chn", "fw-dmz", "fw-online", "fw-pln", "fw-stp"):
            lines.append(f'template(name="diu_{destination}" type="string" string="{destination} %SYSLOGTAG% %msg%\\n")')
    lines.append('ruleset(name="diu_server_remote") {')
    if flags["KERNEL"]:
        lines.extend(['  if ($programname == "ulogd") then {',
                      f'    action(type="omfile" File="/var/log/machines/{hostname}/kernel.log" template="diu_kernel")',
                      '    stop', '  }'])
    if flags["OMADA"]:
        lines.extend(['  if ($programname == "-") then {',
                      '    action(type="omfile" File="/var/log/machines/omada/omada.log" template="diu_omada")',
                      '    stop', '  }'])
    if flags["SSO"]:
        lines.extend(['  if ($msg contains "[LLNG:") then {',
                      '    action(type="omfile" File="/var/log/machines/sso/lemonldap-ng.log" template="diu_sso")',
                      '    stop', '  }'])
    if flags["SURICATA"]:
        for host, destination in (("fw-chn.ch-nontron.fr", "fw-chn"), ("fw-dmz.ch-nontron.fr", "fw-dmz"),
                                  ("fw-online.ch-nontron.fr", "fw-online"), ("fw-online-int.ch-nontron.fr", "fw-online"),
                                  ("fw-pln.ch-nontron.fr", "fw-pln"), ("fw-pln-int.ch-nontron.fr", "fw-pln"),
                                  ("fw-stp.ch-nontron.fr", "fw-stp"), ("fw-stp-int.ch-nontron.fr", "fw-stp")):
            lines.extend([f'  if (($hostname == "{host}") and ($programname == "suricata")) then {{',
                          f'    action(type="omfile" File="/var/log/machines/{destination}/suricata.log" template="diu_{destination}")',
                          '    stop', '  }'])
    lines.extend([
        '  action(type="omfile" dynaFile="diu_remote_path")',
        '}',
        'input(type="imudp" port="514" ruleset="diu_server_remote")',
        'input(type="imtcp" port="514" ruleset="diu_server_remote")',
        '',
    ])
    return "\n".join(lines).encode()


def role_present(role, text):
    if role == "client":
        return bool(CLIENT.search(text))
    return bool(UDP.search(text) or TCP.search(text))


def ulogd_update(prefix):
    path = prefix / "etc/ulogd.conf"
    original, metadata = read_regular(path)
    output = []
    in_sys1 = False
    sys1_sections = 0
    found_stack = found_facility = False
    for line in original.decode("utf-8").splitlines(keepends=True):
        stripped = line.strip()
        if stripped == "[sys2]":
            line = "[sys1]\n"
            stripped = "[sys1]"
        if stripped.startswith("[") and stripped.endswith("]"):
            in_sys1 = stripped == "[sys1]"
            if in_sys1:
                sys1_sections += 1
        if "stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU" in line:
            line = "#stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU\n"
        elif "stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG" in line:
            line = "stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG\n"
            found_stack = True
        elif in_sys1 and re.match(r"^[ \t]*facility[ \t]*=", line):
            line = "facility=LOG_LOCAL0\n"
            found_facility = True
        output.append(line)
    if sys1_sections != 1 or not found_stack or not found_facility:
        raise ValueError("configuration ulogd non reconnue")
    return path, original, metadata, "".join(output).encode("utf-8"), None


def validate_and_restart(main, restart_state):
    if subprocess.run(["rsyslogd", "-N1", "-f", str(main)], stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL, check=False).returncode:
        raise ValueError("configuration rsyslog candidate invalide")
    restart_state[0] = True
    for service in ("rsyslog", "ulogd2"):
        if subprocess.run(["service", service, "restart"], stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL, check=False).returncode:
            raise ValueError("redémarrage du service syslog échoué")


def apply(action, role, prefix, package_removal):
    main, target, original, metadata, other = context(prefix, role)
    if role_present(role, other):
        if action == "check" and metadata is None:
            if role == "client":
                target_host = client_target()
                return 0 if re.search(r'^[ \t]*\*\.\*[ \t]+@@?' + re.escape(target_host) + r':514(?:\s|$)', other, re.MULTILINE) else 1
            return 0 if UDP.search(other) and TCP.search(other) else 1
        if action != "remove" or not package_removal:
            raise ValueError("configuration syslog non gérée ; modification refusée")
    desired = client_config() if role == "client" and action != "remove" else None
    if role == "server" and action != "remove":
        desired = server_config(other)
    if action == "check":
        if metadata is None or original != desired:
            return 1
        _, ulogd_original, _, ulogd_desired, _ = ulogd_update(prefix)
        return 0 if ulogd_original == ulogd_desired else 1
    changes = [(target, original, metadata, None if action == "remove" else desired, None)]
    if action == "configure":
        if role == "client" and UDP.search(other) and TCP.search(other) and 'ruleset="diu_server_remote"' not in other:
            raise ValueError("serveur syslog existant non isolé ; configuration client refusée")
        changes.append(ulogd_update(prefix))
    if all((updated is None and item_metadata is None) or (updated == item_original and item_metadata is not None)
           for _, item_original, item_metadata, updated, _ in changes):
        return 0
    if action == "remove" and package_removal:
        publish(changes)
        return 0
    restart_state = [False]
    try:
        publish(changes, lambda: validate_and_restart(main, restart_state))
    except (OSError, ValueError) as error:
        restoration_failed = False
        if restart_state[0]:
            for service in ("rsyslog", "ulogd2"):
                if subprocess.run(["service", service, "restart"], stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL, check=False).returncode:
                    restoration_failed = True
        if restoration_failed:
            detail = str(error) if isinstance(error, ValueError) else "écriture impossible"
            raise ValueError(detail + " ; redémarrage après restauration échoué") from error
        raise
    return 0


def main():
    if len(sys.argv) not in (4, 5) or sys.argv[1] not in ("configure", "remove", "check", "preflight"):
        return 2
    action, role, mode = sys.argv[1:4]
    if role not in HEADER or mode not in ("keep-package", "remove-package"):
        return 2
    prefix = Path(sys.argv[4]) if len(sys.argv) == 5 else Path("/")
    try:
        if action == "preflight":
            client_target() if role == "client" else server_flags()
            return 0
        return apply(action, role, prefix, mode == "remove-package")
    except (OSError, UnicodeError, ValueError) as error:
        detail = str(error) if isinstance(error, ValueError) else "lecture ou écriture impossible"
        print(f"Configuration syslog incomplète ou impossible : {detail}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
