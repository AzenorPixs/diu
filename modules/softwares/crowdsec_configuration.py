#!/usr/bin/env python3
"""Maintain CrowdSec configuration without exposing the API key."""

import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlsplit

from configuration_transaction import publish
from ssh_configuration import read_regular


LOCAL_URL = "http://127.0.0.1:8080/"
DEFAULT_REMOTE_URL = "http://siem.ch-nontron.fr:8080/"
KEY_PATTERN = re.compile(r"^[A-Za-z0-9_./:+@=-]+$")


def inputs():
    key = os.environ.get("SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY", "")
    if not KEY_PATTERN.fullmatch(key):
        raise ValueError("clé API CrowdSec absente ou invalide")
    return key


def safe_url(value):
    if "\n" in value or "\r" in value:
        raise ValueError("URL CrowdSec invalide")
    try:
        parsed = urlsplit(value)
        port = parsed.port
    except ValueError as error:
        raise ValueError("URL CrowdSec invalide") from error
    if parsed.scheme not in ("http", "https") or not parsed.hostname or parsed.username or parsed.password:
        raise ValueError("URL CrowdSec invalide")
    if port is not None and not 1 <= port <= 65535:
        raise ValueError("URL CrowdSec invalide")
    return value


def replace_keys(data, replacements, optional=()):
    text = data.decode("utf-8")
    for key, value in replacements.items():
        pattern = re.compile(r"^([ \t]*)" + re.escape(key) + r"[ \t]*:[^\r\n]*$", re.MULTILINE)
        matches = list(pattern.finditer(text))
        if len(matches) != 1:
            if not matches and key in optional:
                continue
            raise ValueError("configuration CrowdSec ambiguë ou incomplète")
        encoded = "false" if value is False else json.dumps(value, ensure_ascii=True)
        text = pattern.sub(lambda match: f"{match.group(1)}{key}: {encoded}", text, count=1)
    return text.encode("utf-8")


def paths(prefix):
    etc = prefix / "etc"
    crowdsec = etc / "crowdsec"
    bouncers = crowdsec / "bouncers"
    if any(path.is_symlink() for path in (etc, crowdsec, bouncers)):
        raise ValueError("répertoire CrowdSec symbolique refusé")
    return crowdsec / "config.yaml", bouncers / "crowdsec-firewall-bouncer.yaml", bouncers / ".diu-standalone-enabled"


def remote_url(bouncer_bytes):
    explicit = os.environ.get("SOFTWARE_APT_CROWDSEC_BOUNCER_API_URL", "")
    if explicit:
        return safe_url(explicit)
    text = bouncer_bytes.decode("utf-8")
    matches = re.findall(r"^[ \t]*api_url[ \t]*:[ \t]*([^\r\n#]+)", text, re.MULTILINE)
    if len(matches) != 1:
        raise ValueError("URL CrowdSec ambiguë")
    current = matches[0].strip()
    if current.startswith(('"', "'")):
        if len(current) < 2 or current[-1] != current[0] or "\\" in current:
            raise ValueError("URL CrowdSec ambiguë")
        current = current[1:-1]
    if current in (LOCAL_URL, "http://localhost:8080/"):
        current = DEFAULT_REMOTE_URL
    return safe_url(current)


def plan(action, mode, prefix):
    agent_path, bouncer_path, marker = paths(prefix)
    if action == "disable-bouncer" and mode == "absent":
        marker_bytes, marker_stat = read_regular(marker, missing=True)
        if marker_stat is not None and marker_bytes != b"1\n":
            raise ValueError("marqueur CrowdSec invalide")
        return [(marker, marker_bytes, marker_stat, None, 0o600)]
    key = inputs()
    bouncer_bytes, bouncer_stat = read_regular(bouncer_path)
    if action in ("agent", "check-agent"):
        agent_bytes, agent_stat = read_regular(agent_path)
        agent_new = replace_keys(agent_bytes, {"log_dir": "/var/log/machines/siem", "listen_uri": "0.0.0.0:8080"})
        bouncer_new = replace_keys(bouncer_bytes, {"api_url": LOCAL_URL, "api_key": key,
                                                  "log_dir": "/var/log/machines/siem", "disable_ipv6": False},
                                    optional=("log_dir", "disable_ipv6"))
        return [(agent_path, agent_bytes, agent_stat, agent_new, None),
                (bouncer_path, bouncer_bytes, bouncer_stat, bouncer_new, 0o600)]
    marker_bytes, marker_stat = read_regular(marker, missing=True)
    if marker_stat is not None and marker_bytes != b"1\n":
        raise ValueError("marqueur CrowdSec invalide")
    url = LOCAL_URL if mode == "local" else remote_url(bouncer_bytes)
    replacements = {"api_url": url, "api_key": key, "disable_ipv6": False}
    if mode == "remote":
        replacements["log_mode"] = "stdout"
    bouncer_new = replace_keys(bouncer_bytes, replacements, optional=("disable_ipv6", "log_mode"))
    marker_new = None if action == "disable-bouncer" else b"1\n"
    return [(bouncer_path, bouncer_bytes, bouncer_stat, bouncer_new, 0o600),
            (marker, marker_bytes, marker_stat, marker_new, 0o600)]


def main():
    if len(sys.argv) not in (3, 4):
        return 2
    action, mode = sys.argv[1:3]
    if action not in ("preflight", "agent", "bouncer", "disable-bouncer", "check-agent", "check-bouncer"):
        return 2
    if mode not in ("local", "remote", "absent"):
        return 2
    prefix = Path(sys.argv[3]) if len(sys.argv) == 4 else Path("/")
    try:
        if action == "preflight":
            inputs()
            explicit = os.environ.get("SOFTWARE_APT_CROWDSEC_BOUNCER_API_URL", "")
            if explicit:
                safe_url(explicit)
            return 0
        changes = plan(action, mode, prefix)
        if action.startswith("check-"):
            return 0 if all(updated == original and (expected_mode is None or metadata is not None and metadata.st_mode & 0o777 == expected_mode)
                            for _, original, metadata, updated, expected_mode in changes) else 1
        publish(changes)
        return 0
    except (OSError, UnicodeError, ValueError) as error:
        detail = str(error) if isinstance(error, ValueError) else "lecture ou écriture impossible"
        print(f"Configuration CrowdSec incomplète ou impossible : {detail}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
