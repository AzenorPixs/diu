#!/usr/bin/env python3
"""Validate configured hosts and render safe hosts-file lines."""

import ipaddress
import json
import re
import sys
from pathlib import Path


def render(path):
    with Path(path).open(encoding='utf-8') as stream:
        entries = json.load(stream)
    if not isinstance(entries, list):
        raise ValueError('Le fichier doit contenir un tableau JSON.')
    lines = []
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
        lines.append(f'{ip}\t{fqdn}')
    return '\n'.join(lines)


def main():
    try:
        output = render(sys.argv[1])
    except (OSError, UnicodeError, ValueError, json.JSONDecodeError) as error:
        print(f'Configuration hosts invalide : {error}', file=sys.stderr)
        return 1
    if output:
        print(output)
    return 0


if __name__ == '__main__':
    sys.exit(main())
