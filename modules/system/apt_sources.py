#!/usr/bin/env python3
"""Read active APT source declarations without evaluating configuration."""
import argparse
import re
import shlex
import sys
from pathlib import Path
from urllib.parse import urlsplit


REPOSITORIES = {
    'SYSTEM_APT_DOCKER': ('download.docker.com',),
    'SYSTEM_APT_LEMONLDAP': ('lemonldap-ng.org',),
    'SYSTEM_APT_NODEJS': ('deb.nodesource.com',),
    'SYSTEM_APT_NVIDIA': ('developer.download.nvidia.com', 'nvidia.github.io'),
    'SYSTEM_APT_PROXMOX': ('download.proxmox.com', 'enterprise.proxmox.com'),
    'SYSTEM_APT_VSCODE': ('packages.microsoft.com',),
    'SYSTEM_APT_WEBMIN': ('download.webmin.com',),
    'SYSTEM_APT_CGPT': ('persistent.oaistatic.com',),
    'SOFTWARE_APT_CROWDSEC': ('packagecloud.io',),
    'DIU_APT_REPOSITORY_FD': ('public.fusiondirectory.org',),
}


def legacy(text):
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if not re.match(r'^deb(?:-src)?\s', line):
            raise ValueError('entrée APT historique invalide')
        words = shlex.split(line, comments=True)
        kind = words.pop(0)
        options = []
        if words and words[0].startswith('['):
            while words:
                word = words.pop(0)
                options.append(word)
                if word.endswith(']'):
                    break
            else:
                raise ValueError('options APT incomplètes')
        if words and words[0].startswith('cdrom:[') and ']' not in words[0]:
            label = []
            while words:
                word = words.pop(0)
                label.append(word)
                if ']' in word:
                    break
            else:
                raise ValueError('source CD-ROM incomplète')
            words.insert(0, ' '.join(label))
        if len(words) < 2:
            raise ValueError('entrée APT incomplète')
        yield {'types': [kind], 'uris': [words[0]], 'suites': [words[1]],
               'components': words[2:], 'signed-by': ' '.join(options)}


def deb822(text):
    fields = {}
    previous = None
    for line in text.splitlines() + ['']:
        if not line.strip():
            if fields:
                if fields.get('enabled', 'yes').lower() != 'no':
                    if fields.get('enabled', 'yes').lower() != 'yes':
                        raise ValueError('activation deb822 invalide')
                    if not all(fields.get(key) for key in ('types', 'uris', 'suites')):
                        raise ValueError('strophe deb822 incomplète')
                    if any(t not in ('deb', 'deb-src') for t in fields['types'].split()):
                        raise ValueError('type deb822 invalide')
                    yield {k: fields.get(k, '').split() for k in ('types', 'uris', 'suites', 'components')} | {'signed-by': fields.get('signed-by', '')}
                fields = {}
                previous = None
            continue
        if line.lstrip().startswith('#'):
            continue
        if line[0].isspace():
            if previous is None:
                raise ValueError('continuation deb822 invalide')
            fields[previous] += ' ' + line.strip()
            continue
        key, separator, value = line.partition(':')
        key = key.lower()
        if not separator or not re.fullmatch(r'[a-z][a-z0-9-]*', key) or key in fields:
            raise ValueError('champ deb822 invalide ou dupliqué')
        fields[key] = value.strip()
        previous = key


def sources(root):
    files = []
    main = root / 'sources.list'
    if main.exists() or main.is_symlink():
        files.append(main)
    folder = root / 'sources.list.d'
    if folder.exists():
        if not folder.is_dir():
            raise ValueError('répertoire de sources APT invalide')
        files.extend(sorted(p for p in folder.iterdir() if p.suffix in ('.list', '.sources')
                            and re.fullmatch(r'[A-Za-z0-9_.-]+', p.name)))
    entries = []
    for path in files:
        if not path.is_file():
            raise ValueError('source APT non régulière')
        text = path.read_text(encoding='utf-8')
        entries.extend(deb822(text) if path.suffix == '.sources' else legacy(text))
    return entries


def is_debian(entry):
    if 'debian-archive-keyring' in entry['signed-by']:
        return True
    for uri in entry['uris']:
        if uri.lower().startswith('cdrom:[debian'):
            return True
        url = urlsplit(uri)
        host = (url.hostname or '').lower()
        if host == 'debian.org' or host.endswith('.debian.org') or url.path.rstrip('/') in ('/debian', '/debian-security'):
            return True
    return False


def detect(entries, variable):
    components = {'SYSTEM_APT_DEBIAN_CONTRIB': 'contrib', 'SYSTEM_APT_DEBIAN_NONFRFEE': 'non-free',
                  'SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE': 'non-free-firmware'}
    if variable.startswith('SYSTEM_APT_DEBIAN_'):
        entries = [entry for entry in entries if is_debian(entry)]
        if variable in components:
            return int(any(components[variable] in entry['components'] for entry in entries))
        if variable == 'SYSTEM_APT_DEBIAN_SOURCES':
            return int(any('deb-src' in entry['types'] for entry in entries))
        suffix = {'SYSTEM_APT_DEBIAN_UPDATES': '-updates', 'SYSTEM_APT_DEBIAN_BACKPORT': '-backports'}.get(variable)
        if suffix:
            return int(any(suite.endswith(suffix) for entry in entries for suite in entry['suites']))
        raise ValueError('variable Debian inconnue')
    uris = [urlsplit(uri) for entry in entries for uri in entry['uris']]
    if variable == 'SYSTEM_APT_MONGODB':
        versions = set()
        for entry in entries:
            if any((urlsplit(uri).hostname or '').lower() in ('repo.mongodb.org', 'repo.mongodb.com') for uri in entry['uris']):
                for value in entry['uris'] + entry['suites']:
                    match = re.search(r'/mongodb-org/([0-9]+)\.([0-9]+)(?:/|$)', value)
                    if match:
                        major, minor = int(match[1]), int(match[2])
                        if major not in (4, 5, 6, 7, 8) or minor not in ((0, 4) if major == 4 else (0,)):
                            raise ValueError('branche MongoDB non prise en charge')
                        versions.add(major)
        if len(versions) > 1:
            raise ValueError('plusieurs branches MongoDB actives')
        return next(iter(versions), 0)
    if variable == 'SYSTEM_APT_WAZUH':
        if any((u.hostname or '').lower() == 'packages.wazuh.com' and
               re.match(r'/[0-9]+\.x(?:/|$)', u.path) and not u.path.startswith('/4.x') for u in uris):
            raise ValueError('branche Wazuh non prise en charge')
        return 4 if any((u.hostname or '').lower() == 'packages.wazuh.com' and u.path.startswith('/4.x') for u in uris) else 0
    if variable not in REPOSITORIES:
        raise ValueError('variable de dépôt inconnue')
    for uri in uris:
        if (uri.hostname or '').lower() not in REPOSITORIES[variable]:
            continue
        if variable == 'SYSTEM_APT_VSCODE' and not uri.path.startswith('/repos/code'):
            continue
        if variable == 'SYSTEM_APT_CGPT' and not uri.path.startswith('/codex-app-prod/linux/deb'):
            continue
        if variable == 'SOFTWARE_APT_CROWDSEC' and not uri.path.startswith('/crowdsec/'):
            continue
        return 1
    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('variable')
    parser.add_argument('--root', type=Path, default=Path('/etc/apt'))
    parser.add_argument('--binary', action='store_true')
    args = parser.parse_args()
    try:
        entries = sources(args.root)
        if args.binary:
            entries = [entry for entry in entries if 'deb' in entry['types']]
        print(detect(entries, args.variable))
        return 0
    except (OSError, UnicodeError, ValueError):
        print('Détection APT impossible : sources illisibles, invalides ou ambiguës.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
