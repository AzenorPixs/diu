#!/usr/bin/env python3
"""Informations et routage isolés, sans configuration ni installation réelle."""
import os
from pathlib import Path
import re
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODULES = ('desktop', 'diu', 'environments', 'ia', 'projects', 'softwares', 'system')
VARIABLES = (
    'SYSTEM_DEBIAN_ENVIRONNEMENT SYSTEM_DEBIAN_RELEASE '
    'SYSTEM_APT_DEBIAN_UPDATES SYSTEM_APT_DEBIAN_SOURCES SYSTEM_APT_DEBIAN_BACKPORT '
    'SYSTEM_APT_DEBIAN_CONTRIB SYSTEM_APT_DEBIAN_NONFRFEE '
    'SYSTEM_APT_CGPT SYSTEM_APT_CROWDSEC SYSTEM_APT_DOCKER SYSTEM_APT_LEMONLDAP '
    'SYSTEM_APT_MONGODB SYSTEM_APT_NODEJS SYSTEM_APT_NVIDIA SYSTEM_APT_PROXMOX '
    'SYSTEM_APT_VSCODE SYSTEM_APT_WAZUH SYSTEM_APT_WEBMIN SYSTEM_FLATPAK'
).split()


def function_from(path, name):
    text = (ROOT / path).read_text()
    match = re.search(r'^' + name + r'\(\) \{\n.*?^\}', text, re.M | re.S)
    if not match:
        raise AssertionError(name)
    return match.group()


class ModuleInfosTests(unittest.TestCase):
    def run_shell(self, code, arguments=()):
        env = {k: v for k, v in os.environ.items()
               if not k.startswith(('SYSTEM_', 'INTERFACE_ETHERNET'))}
        imports = ''.join(f'source "{ROOT}/modules/{m}/infos.sh"\n' for m in MODULES)
        return subprocess.run(['bash', '-c', 'set -Eeuo pipefail\n' + imports + code,
                               'bash', *arguments], env=env, capture_output=True, text=True)

    def test_debian_exact_order_and_values(self):
        declarations = '\n'.join(f'{v}=value{i}' for i, v in enumerate(VARIABLES))
        r = self.run_shell(declarations + '\nsystem_info_debian')
        self.assertEqual(r.returncode, 0, r.stderr)
        lines = r.stdout.splitlines()
        self.assertEqual([x for x in lines if '=' in x],
                         [f'{v}=value{i}' for i, v in enumerate(VARIABLES)])
        self.assertEqual([x for x in lines if x and '=' not in x],
                         ['SYSTEM DEBIAN', 'SYSTEM APT OFFICIAL', 'SYSTEM APT UNOFFICIAL', 'SYSTEM FLATPAK'])

    def test_missing_and_empty_values(self):
        r = self.run_shell('SYSTEM_DEBIAN_RELEASE=""\nsystem_info_debian')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('SYSTEM_DEBIAN_RELEASE=\n', r.stdout)
        self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT=UNSET', r.stdout)

    def test_network_interfaces(self):
        for active in (1, 2):
            r = self.run_shell(f'''
INTERFACE_ETHERNET1_STATE=DOWN
INTERFACE_ETHERNET2_STATE=DOWN
INTERFACE_ETHERNET{active}_STATE=UP
INTERFACE_ETHERNET{active}=eth{active}
INTERFACE_ETHERNET{active}_TYPE=DHCP
INTERFACE_ETHERNET{active}_IP=192.0.2.10
INTERFACE_ETHERNET{active}_IP_CIDR=192.0.2.10/24
INTERFACE_ETHERNET{active}_GW=192.0.2.1
system_info_network
''')
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn(f'Interface Ethernet {active}', r.stdout)
            self.assertNotIn(f'Interface Ethernet {3-active}', r.stdout)
            for value in (f'eth{active}', 'DHCP', '192.0.2.10/24', '192.0.2.1'):
                self.assertIn(value, r.stdout)
        r = self.run_shell('system_info_network')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertNotIn('Interface Ethernet', r.stdout)

    def test_global_and_system_order(self):
        r = self.run_shell('diu_version() { printf "2026.test\\n"; }\ninfos')
        self.assertEqual(r.returncode, 0, r.stderr)
        lines = r.stdout.splitlines()
        titles = ['DESKTOP', 'DIU', 'ENVIRONNEMENTS', 'IA', 'PROJECTS', 'SOFTWARES', 'SYSTEM']
        self.assertEqual([x for x in lines if x in titles], titles)
        self.assertIn('2026.test', lines)
        self.assertLess(r.stdout.index('SYSTEM DEBIAN'), r.stdout.index('Informations réseau'))

    def test_failures_continue_aggregation(self):
        r = self.run_shell('diu_version() { printf "version indisponible\\n" >&2; return 1; }\ninfos')
        self.assertEqual(r.returncode, 1)
        self.assertIn('SYSTEM FLATPAK', r.stdout)
        self.assertIn('version indisponible', r.stderr)
        r = self.run_shell('system_info_debian() { return 1; }\nsystem_info')
        self.assertEqual(r.returncode, 1)
        self.assertIn('Informations réseau', r.stdout)

    def test_version_reuses_installed_package(self):
        version = function_from('modules/diu/update.sh', 'diu_version')
        for success in (True, False):
            stub = 'printf "2026.package"' if success else 'return 1'
            r = self.run_shell('print_error() { printf "%s\\n" "$*" >&2; }\n'
                               + f'dpkg-query() {{ {stub}; }}\n' + version
                               + '\nif diu_infos; then exit 0; else exit 1; fi')
            self.assertEqual(r.returncode, 0 if success else 1)
            self.assertIn('DIU', r.stdout)
            if success:
                self.assertIn('2026.package', r.stdout)
            else:
                self.assertIn("n'est pas installé", r.stderr)

    def dispatch(self, *args):
        dispatch = function_from('root-install-debian.sh', 'dispatch_arguments')
        system = function_from('modules/system/apt.sh', 'manage_system_action')
        return self.run_shell('print_error() { printf "%s\\n" "$*" >&2; }\n'
                              'diu_version() { printf "2026.test\\n"; }\n'
                              + f'source "{ROOT}/lib/rid-help.sh"\n' + system + '\n'
                              + dispatch + '\ndispatch_arguments "$@"\necho INSTALLATION_INTERDITE', args)

    def test_routes_and_termination(self):
        routes = [('infos',)] + [(m, 'infos') for m in
                  ('desktop', 'diu', 'environnements', 'ia', 'projects', 'softwares', 'system')]
        routes += [('system', 'info', 'network'), ('system', 'info', 'debian')]
        for route in routes:
            with self.subTest(route=route):
                r = self.dispatch(*route)
                self.assertEqual(r.returncode, 0, r.stderr)
                self.assertTrue(r.stdout.strip())
                self.assertNotIn('INSTALLATION_INTERDITE', r.stdout)

    def test_invalid_arguments(self):
        for route in [('infos', 'extra'), ('system', 'info'), ('system', 'info', 'unknown'),
                      ('system', 'info', 'debian', 'extra'), ('system', 'infos', 'extra'),
                      ('diu', 'unknown'), ('desktop', 'infos', 'extra')]:
            with self.subTest(route=route):
                r = self.dispatch(*route)
                self.assertEqual(r.returncode, 2, r.stderr)
                self.assertIn('help', r.stderr)
                self.assertNotIn('INSTALLATION_INTERDITE', r.stdout)

    def test_actual_help_without_configuration(self):
        routes = [('infos',)] + [(m, 'infos') for m in
                  ('desktop', 'diu', 'environnements', 'ia', 'projects', 'softwares', 'system')]
        routes += [('system', 'info'), ('system', 'info', 'network'), ('system', 'info', 'debian')]
        for route in routes:
            for suffix in ('help', '?'):
                with self.subTest(route=route, suffix=suffix):
                    r = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *route, suffix],
                                       capture_output=True, text=True)
                    self.assertEqual(r.returncode, 0, r.stderr)
                    self.assertIn('rid ' + ' '.join(route), r.stdout)

    def test_extraction_and_imports(self):
        root = (ROOT / 'root-install-debian.sh').read_text()
        self.assertNotIn('display_infos', root)
        self.assertIn('\nsystem_info_network\n', root)
        for module in MODULES:
            self.assertIn(f'modules/{module}/infos.sh', root)


if __name__ == '__main__':
    unittest.main()
