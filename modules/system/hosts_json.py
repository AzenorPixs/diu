#!/usr/bin/env python3
"""Validate, render and manage hosts entries."""

import fcntl
from contextlib import contextmanager
import ipaddress
import json
import os
import re
import stat
import sys
import tempfile
from pathlib import Path


def validate(entries):
    if not isinstance(entries, list):
        raise ValueError('Le fichier doit contenir un tableau JSON.')
    for item in entries:
        if not isinstance(item, dict) or set(item) != {'ip', 'fqdn'}:
            raise ValueError('Chaque entrée doit contenir uniquement ip et fqdn.')
        ip, fqdn = item['ip'], item['fqdn']
        if not isinstance(ip, str) or not isinstance(fqdn, str):
            raise ValueError('IP et FQDN doivent être des chaînes.')
        if not re.fullmatch(r'[0-9A-Fa-f:.]+', ip):
            raise ValueError('Adresse IP invalide.')
        ipaddress.ip_address(ip)
        hostname = fqdn[:-1] if fqdn.endswith('.') else fqdn
        labels = hostname.split('.')
        if len(hostname) > 253 or len(labels) < 2 or any(
            not re.fullmatch(r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?', label)
            for label in labels
        ):
            raise ValueError('FQDN invalide.')
    return entries


def read_entries(path):
    with Path(path).open(encoding='utf-8') as stream:
        return validate(json.load(stream))


def render(path):
    return '\n'.join(f"{entry['ip']}\t{entry['fqdn']}" for entry in read_entries(path))


def sort_key(entry):
    ip = ipaddress.ip_address(entry['ip'])
    return ip.version, int(ip), entry['fqdn'].casefold(), entry['fqdn']


def write_entries(path, entries):
    metadata = path.stat()
    descriptor, temporary = tempfile.mkstemp(prefix='.hosts-', dir=path.parent)
    try:
        with os.fdopen(descriptor, 'w', encoding='utf-8') as stream:
            os.fchown(stream.fileno(), metadata.st_uid, metadata.st_gid)
            os.fchmod(stream.fileno(), stat.S_IMODE(metadata.st_mode))
            json.dump(entries, stream, ensure_ascii=False, indent=2)
            stream.write('\n')
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


@contextmanager
def locked_directory(path):
    descriptor = os.open(path, os.O_RDONLY | os.O_DIRECTORY)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX)
        yield
    finally:
        os.close(descriptor)


def manage(path, action, arguments):
    path = Path(path)
    if action not in ('add', 'del', 'list') or (
        action == 'add' and len(arguments) != 2
    ) or (action == 'del' and not (len(arguments) == 2 or arguments == ['all'])) or (
        action == 'list' and arguments
    ):
        raise ValueError('Usage : network {add IP FQDN|del IP FQDN|del all|list}')
    if action == 'add' or (action == 'del' and arguments != ['all']):
        entry = {'ip': arguments[0], 'fqdn': arguments[1]}
        validate([entry])
    path.parent.mkdir(parents=True, exist_ok=True)
    with locked_directory(path.parent):
        if path.is_symlink():
            raise ValueError('Le fichier hosts.json ne doit pas être un lien symbolique.')
        try:
            with path.open('x', encoding='utf-8') as stream:
                stream.write('[]\n')
        except FileExistsError:
            pass
        entries = read_entries(path)
        if action == 'list':
            print(render(path) or 'Aucune entrée.')
            return
        if action == 'add':
            if entry not in entries:
                entries.append(entry)
                message = 'Entrée ajoutée.'
            else:
                message = 'Entrée déjà présente.'
            entries.sort(key=sort_key)
        elif arguments == ['all']:
            entries = []
            message = 'Toutes les entrées ont été supprimées.'
        elif entry in entries:
            entries = [item for item in entries if item != entry]
            message = 'Entrée supprimée.'
        else:
            print('Entrée absente.')
            return
        write_entries(path, entries)
        print(message)


def main():
    try:
        if len(sys.argv) >= 2 and sys.argv[1] == 'manage':
            if len(sys.argv) < 4:
                raise ValueError('Arguments de gestion manquants.')
            manage(sys.argv[2], sys.argv[3], sys.argv[4:])
        elif len(sys.argv) == 2:
            output = render(sys.argv[1])
            if output:
                print(output)
        else:
            raise ValueError('Arguments invalides.')
    except (OSError, UnicodeError, ValueError) as error:
        print(f'Configuration hosts invalide : {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
