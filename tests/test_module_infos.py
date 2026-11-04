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
    'SYSTEM_DEBIAN_ENVIRONNEMENT SYSTEM_DEBIAN_RELEASE SYSTEM_TIME_ZONE '
    'SYSTEM_APT_DEBIAN_UPDATES SYSTEM_APT_DEBIAN_SOURCES SYSTEM_APT_DEBIAN_BACKPORT '
    'SYSTEM_APT_DEBIAN_CONTRIB SYSTEM_APT_DEBIAN_NONFRFEE '
    'SYSTEM_APT_CGPT SYSTEM_APT_DOCKER SYSTEM_APT_LEMONLDAP '
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
               if not k.startswith(('SYSTEM_', 'SOFTWARES_APT_CROWDSEC', 'INTERFACE_ETHERNET'))}
        imports = ''.join(f'source "{ROOT}/modules/{m}/infos.sh"\n' for m in MODULES)
        return subprocess.run(['bash', '-c', 'set -Eeuo pipefail\n' + imports + code,
                               'bash', *arguments], env=env, capture_output=True, text=True)

    def test_debian_exact_order_and_values(self):
        declarations = '\n'.join(f'{v}=value{i}' for i, v in enumerate(VARIABLES))
        r = self.run_shell(declarations + '\nsystem_info_debian')
        self.assertEqual(r.returncode, 0, r.stderr)
        lines = [x.strip() for x in r.stdout.splitlines() if set(x.strip()) != {'='}]
        self.assertEqual([x for x in lines if '=' in x],
                         [f'{v}=value{i}' for i, v in enumerate(VARIABLES)])
        self.assertEqual([x for x in lines if x and '=' not in x],
                         ['SYSTEM DEBIAN', 'SYSTEM APT OFFICIAL', 'SYSTEM APT UNOFFICIAL', 'SYSTEM FLATPAK'])

    def test_missing_and_empty_values(self):
        r = self.run_shell('SYSTEM_DEBIAN_RELEASE=""\nsystem_info_debian')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('SYSTEM_DEBIAN_RELEASE=\n', r.stdout)
        self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT=UNSET', r.stdout)
        self.assertIn('SYSTEM_TIME_ZONE=UNSET', r.stdout)
        r = self.run_shell('SYSTEM_TIME_ZONE=""\nsystem_info_debian')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('SYSTEM_TIME_ZONE=\n', r.stdout)

    def test_crowdsec_settings_are_reported_in_software_scope(self):
        r = self.run_shell('SOFTWARES_APT_CROWDSEC=1\n'
                           'SOFTWARES_APT_CROWDSEC_AGENT=0\n'
                           'SOFTWARES_APT_CROWDSEC_BOUNCER=1\nsoftwares_infos')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual([line for line in r.stdout.splitlines() if '=' in line], [
            'SOFTWARES_APT_CROWDSEC=1',
            'SOFTWARES_APT_CROWDSEC_AGENT=0',
            'SOFTWARES_APT_CROWDSEC_BOUNCER=1',
        ])

    def test_desktop_toggle_is_reported_in_desktop_scope(self):
        r = self.run_shell('DESKTOP=1\ndesktop_infos')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('DESKTOP=1\n', r.stdout)

    def test_devops_toggle_is_reported_in_environments_scope(self):
        r = self.run_shell('ENVIRONMENTS_DEVOPS=1\nENVIRONMENT_DOCKER=0\nENVIRONMENT_IA=1\nenvironments_infos')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('ENVIRONMENTS_DEVOPS=1\n', r.stdout)
        self.assertIn('ENVIRONMENT_DOCKER=0\n', r.stdout)
        self.assertIn('ENVIRONMENT_IA=1\n', r.stdout)

    def test_drivers_without_version_query(self):
        for value in (None, '', '0', 'UNSET'):
            declaration = '' if value is None else f'SYSTEM_DRIVERS_DISPLAY_LINK="{value}"\n'
            r = self.run_shell(declaration + 'dpkg-query() { echo QUERY_INTERDITE >&2; return 99; }\nsystem_info_drivers')
            self.assertEqual(r.returncode, 0, r.stderr)
            expected = 'UNSET' if value is None else value
            self.assertIn(f'SYSTEM_DRIVERS_DISPLAY_LINK={expected}\n', r.stdout)
            self.assertNotIn('Version DisplayLink', r.stdout)
            self.assertEqual(r.stderr, '')

    def test_drivers_installed_version(self):
        r = self.run_shell(r'''
SYSTEM_DRIVERS_DISPLAY_LINK=1
dpkg-query() {
    [[ "$*" == '-W -f=${db:Status-Status}\t${Version} displaylink-driver' ]] || return 99
    printf 'installed\t6.1-2'
}
system_info_drivers
printf 'STATE=%s\n' "$SYSTEM_DRIVERS_DISPLAY_LINK"
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('Version DisplayLink : 6.1-2', r.stdout)
        self.assertLess(r.stdout.index('SYSTEM_DRIVERS_DISPLAY_LINK=1'), r.stdout.index('Version DisplayLink'))
        self.assertIn('STATE=1', r.stdout)

    def test_drivers_unavailable_version(self):
        for stub in ('return 1', 'return 2', 'return 127',
                     "printf 'unpacked\\t6.1-2'", "printf 'installed\\t'", "printf 'unexpected'"):
            with self.subTest(stub=stub):
                r = self.run_shell('SYSTEM_DRIVERS_DISPLAY_LINK=1\n'
                                   + f'dpkg-query() {{ {stub}; }}\n'
                                   + 'if system_info_drivers; then result=0; else result=$?; fi\n'
                                   + 'printf "STATE=%s\\n" "$SYSTEM_DRIVERS_DISPLAY_LINK"\nexit "$result"')
                self.assertEqual(r.returncode, 1, r.stderr)
                self.assertIn('Version DisplayLink : UNSET', r.stdout)
                self.assertIn('Impossible de déterminer', r.stderr)
                self.assertIn('STATE=1', r.stdout)

    def test_drivers_failure_keeps_network_output(self):
        r = self.run_shell('SYSTEM_DRIVERS_DISPLAY_LINK=1\ndpkg-query() { return 1; }\nsystem_info')
        self.assertEqual(r.returncode, 1)
        self.assertIn('Informations réseau', r.stdout)
        self.assertIn('SYSTEM DEBIAN', r.stdout)

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
        lines = [x.strip('# ') for x in r.stdout.splitlines()]
        titles = ['DESKTOP', 'DIU', 'ENVIRONNEMENTS', 'IA', 'PROJECTS', 'SOFTWARES', 'SYSTEM']
        self.assertEqual([x for x in lines if x in titles], titles)
        self.assertIn('2026.test', lines)
        self.assertLess(r.stdout.index('SYSTEM DEBIAN'), r.stdout.index('SYSTEM DRIVERS'))
        self.assertLess(r.stdout.index('SYSTEM DRIVERS'), r.stdout.index('Informations réseau'))

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
        routes += [('system', 'infos', 'network'), ('system', 'infos', 'debian'), ('system', 'infos', 'drivers')]
        for route in routes:
            with self.subTest(route=route):
                r = self.dispatch(*route)
                self.assertEqual(r.returncode, 0, r.stderr)
                self.assertTrue(r.stdout.strip())
                self.assertNotIn('INSTALLATION_INTERDITE', r.stdout)
                if route == ('system', 'infos', 'network'):
                    self.assertIn('Informations réseau', r.stdout)
                    self.assertNotIn('SYSTEM DEBIAN', r.stdout)
                elif route == ('system', 'infos', 'debian'):
                    self.assertIn('SYSTEM DEBIAN', r.stdout)
                    self.assertNotIn('Informations réseau', r.stdout)

    def test_invalid_arguments(self):
        for route in [('infos', 'extra'), ('system', 'infos', 'unknown'),
                      ('system', 'infos', 'debian', 'extra'), ('system', 'infos', 'drivers', 'extra'), ('system', 'infos', 'extra'),
                      ('diu', 'unknown'), ('desktop', 'infos', 'extra')]:
            with self.subTest(route=route):
                r = self.dispatch(*route)
                self.assertEqual(r.returncode, 2, r.stderr)
                self.assertIn('help', r.stderr)
                self.assertNotIn('INSTALLATION_INTERDITE', r.stdout)

    def test_actual_help_without_configuration(self):
        routes = [('infos',)] + [(m, 'infos') for m in
                  ('desktop', 'diu', 'environnements', 'ia', 'projects', 'softwares', 'system')]
        routes += [('system',), ('system', 'infos'), ('system', 'infos', 'network'), ('system', 'infos', 'debian'), ('system', 'infos', 'drivers')]
        for route in routes:
            for suffix in ('help', '?'):
                with self.subTest(route=route, suffix=suffix):
                    r = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *route, suffix],
                                       capture_output=True, text=True)
                    self.assertEqual(r.returncode, 0, r.stderr)
                    self.assertIn('rid ' + ' '.join(route), r.stdout)
                    if route in (('system', 'infos'), ('system',)):
                        self.assertIn('rid system infos network', r.stdout)
                        self.assertIn('rid system infos debian', r.stdout)
                        self.assertIn('rid system infos drivers', r.stdout)
                    self.assertNotIn('rid system info ', r.stdout)

    def test_extraction_and_imports(self):
        root = (ROOT / 'root-install-debian.sh').read_text()
        self.assertNotIn('display_infos', root)
        self.assertIn('\nsystem_info_network\n', root)
        for module in MODULES:
            self.assertIn(f'modules/{module}/infos.sh', root)


if __name__ == '__main__':
    unittest.main()
