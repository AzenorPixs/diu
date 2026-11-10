#!/usr/bin/env python3
"""Extract a GitHub release archive without paths or links escaping its root."""

import posixpath
import sys
import tarfile
from pathlib import PurePosixPath


def normalized(path):
    if not path or path.startswith("/"):
        raise ValueError("chemin absolu ou vide")
    result = posixpath.normpath(path)
    if result == ".." or result.startswith("../"):
        raise ValueError("chemin extérieur à l'archive")
    return result


def extract(archive_path, destination):
    with tarfile.open(archive_path, "r:gz") as archive:
        members = archive.getmembers()
        indexed = {}
        for member in members:
            name = normalized(member.name)
            if name in indexed:
                raise ValueError("chemin d'archive dupliqué")
            if not (member.isfile() or member.isdir() or member.issym() or member.islnk()):
                raise ValueError("type d'entrée d'archive non autorisé")
            indexed[name] = member

        links = {name for name, member in indexed.items() if member.issym() or member.islnk()}
        for name, member in indexed.items():
            parts = PurePosixPath(name).parts
            if any("/".join(parts[:index]) in links for index in range(1, len(parts))):
                raise ValueError("entrée sous un lien d'archive")
            if member.issym() or member.islnk():
                if not member.linkname or member.linkname.startswith("/"):
                    raise ValueError("cible de lien absolue ou vide")
                base = posixpath.dirname(name) if member.issym() else "."
                target = normalized(posixpath.join(base, member.linkname))
                target_member = indexed.get(target)
                if target_member is None or not (target_member.isfile() or (member.issym() and target_member.isdir())):
                    raise ValueError("cible de lien absente ou non sûre")
                target_parts = PurePosixPath(target).parts
                if any("/".join(target_parts[:index]) in links for index in range(1, len(target_parts))):
                    raise ValueError("cible sous un lien d'archive")
            member.mode &= 0o777
        archive.extractall(destination, members=members, numeric_owner=False)


def main():
    if len(sys.argv) != 3:
        print("Usage : safe_archive.py <archive> <destination>", file=sys.stderr)
        return 2
    try:
        extract(sys.argv[1], sys.argv[2])
    except (EOFError, KeyError, OSError, tarfile.TarError, UnicodeError, ValueError) as error:
        print(f"Archive GitHub refusée : {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
