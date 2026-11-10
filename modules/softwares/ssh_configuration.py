#!/usr/bin/env python3
"""Converge SSH settings without replacing existing authorized keys."""

import os
import pwd
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


BEGIN = "# BEGIN DIU SSH CONVERGENCE"
END = "# END DIU SSH CONVERGENCE"
PATH_PATTERN = re.compile(r"^[A-Za-z0-9%/._~+-]+$")


def read_regular(path, missing=False):
    try:
        descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    except FileNotFoundError:
        if missing:
            return b"", None
        raise
    try:
        metadata = os.fstat(descriptor)
        if not stat.S_ISREG(metadata.st_mode):
            raise ValueError("fichier SSH non régulier")
        with os.fdopen(descriptor, "rb") as stream:
            return stream.read(), metadata
    except BaseException:
        try:
            os.close(descriptor)
        except OSError:
            pass
        raise


def effective(sshd, path):
    result = subprocess.run([sshd, "-T", "-f", str(path)], capture_output=True, text=True, check=False)
    if result.returncode:
        raise ValueError("configuration SSH non vérifiable")
    values = {}
    for line in result.stdout.splitlines():
        name, separator, value = line.partition(" ")
        if separator and name in {"authorizedkeysfile", "permitrootlogin", "usepam", "x11forwarding"}:
            if name in values:
                raise ValueError("paramètre SSH effectif dupliqué")
            values[name] = value.strip()
    if not all(name in values for name in ("authorizedkeysfile", "permitrootlogin", "usepam", "x11forwarding")):
        raise ValueError("paramètres SSH effectifs incomplets")
    return values


def authorized_paths(value):
    paths = value.split()
    if not paths or any(not PATH_PATTERN.fullmatch(path) for path in paths):
        raise ValueError("chemins de clés SSH ambigus")
    if paths == ["none"]:
        paths = []
    if ".ssh/authorized_keys" not in paths:
        paths.append(".ssh/authorized_keys")
    return paths


def configured_keys():
    keys = []
    for name in ("KEY_SSH_ADMIN", "KEY_SSH_ACME"):
        key = os.environ.get(name, "")
        if "\n" in key or "\r" in key or "\x00" in key:
            raise ValueError("clé SSH invalide")
        if key and key not in keys:
            keys.append(key)
    return keys


def remove_managed_block(text):
    output = []
    inside = False
    seen = False
    for line in text.splitlines(keepends=True):
        marker = line.rstrip("\r\n")
        if marker == BEGIN:
            if inside or seen:
                raise ValueError("bloc SSH dupliqué")
            inside = True
            seen = True
        elif marker == END:
            if not inside:
                raise ValueError("bloc SSH incomplet")
            inside = False
        elif not inside:
            output.append(line)
    if inside:
        raise ValueError("bloc SSH incomplet")
    return "".join(output)


def write_candidate(path, data, original_stat, owner=None, forced_mode=None):
    descriptor, name = tempfile.mkstemp(prefix=".diu-ssh-", dir=path.parent)
    try:
        if original_stat:
            os.fchmod(descriptor, forced_mode if forced_mode is not None else stat.S_IMODE(original_stat.st_mode))
            if (os.fstat(descriptor).st_uid, os.fstat(descriptor).st_gid) != (original_stat.st_uid, original_stat.st_gid):
                os.fchown(descriptor, original_stat.st_uid, original_stat.st_gid)
        else:
            os.fchmod(descriptor, forced_mode if forced_mode is not None else 0o600)
            if owner and (os.fstat(descriptor).st_uid, os.fstat(descriptor).st_gid) != owner:
                os.fchown(descriptor, *owner)
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        return Path(name)
    except BaseException:
        try:
            os.close(descriptor)
        except OSError:
            pass
        Path(name).unlink(missing_ok=True)
        raise


def unchanged(path, original, metadata):
    current, current_metadata = read_regular(path, missing=True)
    if metadata is None:
        return current_metadata is None
    if current_metadata is None or current != original:
        return False
    return (current_metadata.st_uid, current_metadata.st_gid, stat.S_IMODE(current_metadata.st_mode)) == (
        metadata.st_uid, metadata.st_gid, stat.S_IMODE(metadata.st_mode)
    )


def key_targets(prefix):
    root = prefix / "root"
    if root.is_symlink() or not root.is_dir():
        raise ValueError("répertoire root indisponible ou symbolique")
    targets = [(root / ".ssh/authorized_keys", None)]
    enabled = os.environ.get("ENVIRONMENT_DOCKER", "0")
    if enabled not in ("0", "1"):
        raise ValueError("état de l'environnement Docker invalide")
    if enabled == "0":
        return targets
    account = os.environ.get("ENVIRONMENT_DOCKER_USER", "")
    if not re.fullmatch(r"[a-z_][a-z0-9_-]*", account):
        raise ValueError("compte Docker invalide")
    try:
        details = pwd.getpwnam(account)
    except KeyError as error:
        raise ValueError("compte Docker indisponible") from error
    home = PurePosixPath(details.pw_dir)
    if not home.is_absolute() or ".." in home.parts:
        raise ValueError("répertoire personnel Docker invalide")
    directory = prefix
    for component in home.parts[1:]:
        directory = directory / component
        if directory.is_symlink():
            raise ValueError("répertoire personnel Docker symbolique refusé")
    if not directory.is_dir():
        raise ValueError("répertoire personnel Docker indisponible")
    target = directory / ".ssh/authorized_keys"
    if target != targets[0][0]:
        targets.append((target, (details.pw_uid, details.pw_gid)))
    return targets


def converge(prefix):
    config = prefix / "etc/ssh/sshd_config"
    if any(path.is_symlink() for path in (prefix / "etc", config.parent)):
        raise ValueError("répertoire SSH symbolique refusé")
    config_bytes, config_stat = read_regular(config)
    keys = configured_keys()
    records = []
    for keys_path, owner in key_targets(prefix):
        if keys_path.parent.is_symlink():
            raise ValueError("répertoire SSH symbolique refusé")
        old_keys, keys_stat = read_regular(keys_path, missing=True)
        if not old_keys.strip() and not keys:
            raise ValueError("aucune clé autorisée disponible")
        existing = old_keys.decode("utf-8").splitlines()
        key_bytes = old_keys
        for key in keys:
            if key not in existing:
                if key_bytes and not key_bytes.endswith(b"\n"):
                    key_bytes += b"\n"
                key_bytes += key.encode("utf-8") + b"\n"
        records.append({"path": keys_path, "owner": owner, "original": old_keys, "metadata": keys_stat,
                        "updated": key_bytes, "candidate": None, "rollback": None,
                        "published": None, "committed": False, "preserve": False})
    sshd = shutil.which("sshd")
    if not sshd:
        raise ValueError("sshd indisponible")
    paths = authorized_paths(effective(sshd, config)["authorizedkeysfile"])
    remaining = remove_managed_block(config_bytes.decode("utf-8"))
    block = "\n".join((BEGIN, "PermitRootLogin yes", "UsePAM yes", "X11Forwarding no",
                       "AuthorizedKeysFile " + " ".join(paths), END, ""))
    config_new = (block + remaining).encode("utf-8")
    config_candidate = None
    try:
        config_candidate = write_candidate(config, config_new, config_stat)
        if subprocess.run([sshd, "-t", "-f", str(config_candidate)], stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL, check=False).returncode:
            raise ValueError("configuration SSH candidate invalide")
        current = effective(sshd, config_candidate)
        if any(current[name] != value for name, value in
               (("permitrootlogin", "yes"), ("usepam", "yes"), ("x11forwarding", "no"))):
            raise ValueError("configuration SSH candidate non conforme")
        for record in records:
            directory = record["path"].parent
            if directory.is_symlink():
                raise ValueError("répertoire SSH symbolique refusé")
            if not directory.exists():
                directory.mkdir(mode=0o700)
                if record["owner"] and (directory.stat().st_uid, directory.stat().st_gid) != record["owner"]:
                    os.chown(directory, *record["owner"], follow_symlinks=False)
            record["candidate"] = write_candidate(record["path"], record["updated"], record["metadata"], record["owner"])
        if not unchanged(config, config_bytes, config_stat) or any(
            not unchanged(record["path"], record["original"], record["metadata"]) for record in records
        ):
            raise ValueError("configuration SSH modifiée simultanément")
        try:
            for record in records:
                if record["updated"] == record["original"] and record["metadata"] is not None:
                    continue
                if record["metadata"] is not None:
                    record["rollback"] = write_candidate(record["path"], record["original"], record["metadata"])
                    os.replace(record["candidate"], record["path"])
                    record["candidate"] = None
                else:
                    os.link(record["candidate"], record["path"])
                record["committed"] = True
                _, record["published"] = read_regular(record["path"])
            if config_new != config_bytes:
                os.replace(config_candidate, config)
                config_candidate = None
        except BaseException as error:
            failures = []
            for record in reversed(records):
                if not record["committed"]:
                    continue
                try:
                    current_keys, current_metadata = read_regular(record["path"], missing=True)
                    published = record["published"]
                    if (current_metadata is None or published is None or current_keys != record["updated"] or
                        (current_metadata.st_dev, current_metadata.st_ino, current_metadata.st_mode,
                         current_metadata.st_uid, current_metadata.st_gid) !=
                        (published.st_dev, published.st_ino, published.st_mode,
                         published.st_uid, published.st_gid)):
                        raise ValueError("clés modifiées simultanément")
                    if record["rollback"]:
                        os.replace(record["rollback"], record["path"])
                        record["rollback"] = None
                    else:
                        record["path"].unlink()
                except (OSError, ValueError):
                    record["preserve"] = True
                    if record["rollback"]:
                        failures.append(str(record["rollback"]))
                    else:
                        failures.append(str(record["path"]))
            if failures:
                raise ValueError("configuration SSH partielle ; éléments conservés : " + ", ".join(failures)) from error
            raise
    finally:
        if config_candidate:
            config_candidate.unlink(missing_ok=True)
        for record in records:
            if record["candidate"]:
                record["candidate"].unlink(missing_ok=True)
            if record["rollback"] and not record["preserve"]:
                record["rollback"].unlink(missing_ok=True)


def check(prefix):
    config = prefix / "etc/ssh/sshd_config"
    if any(path.is_symlink() for path in (prefix / "etc", config.parent)):
        raise ValueError("répertoire SSH symbolique refusé")
    _, _ = read_regular(config)
    keys = configured_keys()
    for keys_path, _ in key_targets(prefix):
        if keys_path.parent.is_symlink():
            raise ValueError("répertoire SSH symbolique refusé")
        keys_bytes, _ = read_regular(keys_path, missing=True)
        existing = keys_bytes.decode("utf-8").splitlines()
        if not keys_bytes.strip() or any(key not in existing for key in keys):
            return 1
    sshd = shutil.which("sshd")
    if not sshd:
        raise ValueError("sshd indisponible")
    values = effective(sshd, config)
    if any(values[name] != value for name, value in
           (("permitrootlogin", "yes"), ("usepam", "yes"), ("x11forwarding", "no"))):
        return 1
    if ".ssh/authorized_keys" not in values["authorizedkeysfile"].split():
        return 1
    return 0


def main():
    if len(sys.argv) not in (2, 3) or sys.argv[1] not in ("configure", "check"):
        print("Usage : ssh_configuration.py <configure|check> [racine]", file=sys.stderr)
        return 2
    prefix = Path(sys.argv[2]) if len(sys.argv) == 3 else Path("/")
    try:
        if sys.argv[1] == "check":
            return check(prefix)
        converge(prefix)
        return 0
    except (OSError, UnicodeError, ValueError) as error:
        detail = str(error) if isinstance(error, ValueError) else "lecture ou écriture impossible"
        print(f"Configuration SSH incomplète ou impossible : {detail}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
