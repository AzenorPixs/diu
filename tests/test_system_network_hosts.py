import os
import json
import shutil
import re
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class NetworkHostsTests(unittest.TestCase):
    def test_generated_hosts(self):
        source = (ROOT / 'modules/system/network.sh').read_text()
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            hosts = Path(directory) / 'hosts'
            isolated = Path(directory) / 'network.sh'
            helper = Path(directory) / 'modules/system'
            helper.mkdir(parents=True)
            shutil.copy(ROOT / 'modules/system/hosts_json.py', helper)
            isolated.write_text(source.replace('/root/diu/config/hosts.json', str(Path(directory) / 'production/config/hosts.json')).replace('/etc/hosts', str(hosts)))
            for state1, ip1, state2, ip2, expected in (
                ('UP', '192.0.2.1', 'UP', '192.0.2.2', '192.0.2.1'),
                ('DOWN', '192.0.2.1', 'UP', '192.0.2.2', '192.0.2.2'),
                ('UP', 'bad', 'UP', '192.0.2.2', '192.0.2.2'),
                ('UP', 'NONE', 'DOWN', '192.0.2.2', None),
            ):
                with self.subTest(expected=expected):
                    hosts.write_text('old entry\n')
                    env = dict(os.environ, BASH_SCRIPT_PATH=directory, INTERFACE_ETHERNET1_STATE=state1,
                               INTERFACE_ETHERNET1_IP=ip1,
                               INTERFACE_ETHERNET2_STATE=state2,
                               INTERFACE_ETHERNET2_IP=ip2,
                               HOSTNAME_FQDN='host.example', HOSTNAME='host')
                    result = subprocess.run(['bash', '-c', 'source "$1"; system_network_hosts',
                                             'bash', str(isolated)], env=env, capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(json.loads((Path(directory) / 'config/hosts.json').read_text()), [])
                    text = hosts.read_text()
                    self.assertIn('127.0.0.1       localhost\n', text)
                    self.assertIn('::1     localhost ip6-localhost ip6-loopback\n', text)
                    self.assertNotIn('old entry', text)
                    self.assertNotIn('docker', text)
                    if expected:
                        self.assertIn(f'{expected}\thost.example\thost\n', text)
                    else:
                        self.assertNotIn('host.example', text)

    def test_hosts_write_failure_is_reported(self):
        source = (ROOT / 'modules/system/network.sh').read_text()
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            isolated = Path(directory) / 'network.sh'
            helper = Path(directory) / 'modules/system'
            helper.mkdir(parents=True)
            shutil.copy(ROOT / 'modules/system/hosts_json.py', helper)
            isolated.write_text(source.replace('/root/diu/config/hosts.json', str(Path(directory) / 'production/config/hosts.json')).replace('/etc/hosts', str(Path(directory) / 'missing' / 'hosts')))
            env = dict(os.environ, BASH_SCRIPT_PATH=directory, INTERFACE_ETHERNET1_STATE='DOWN', INTERFACE_ETHERNET1_IP='NONE',
                       INTERFACE_ETHERNET2_STATE='DOWN', INTERFACE_ETHERNET2_IP='NONE')
            result = subprocess.run(['bash', '-c', 'source "$1"; system_network_hosts',
                                     'bash', str(isolated)], env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)

    def test_multiple_entries_and_invalid_json_preserves_hosts(self):
        source = (ROOT / 'modules/system/network.sh').read_text()
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            base = Path(directory)
            helper = base / 'modules/system'
            helper.mkdir(parents=True)
            shutil.copy(ROOT / 'modules/system/hosts_json.py', helper)
            hosts = base / 'hosts'
            script = base / 'network.sh'
            script.write_text(source.replace('/root/diu/config/hosts.json', str(Path(directory) / 'production/config/hosts.json')).replace('/etc/hosts', str(hosts)))
            config = base / 'production/config'
            config.mkdir(parents=True)
            (base / 'config').mkdir()
            (base / 'config/hosts.json').write_text('[{"ip":"192.0.2.99","fqdn":"dev.example"}]')
            config_file = config / 'hosts.json'
            entries = [{'ip': '127.0.0.1', 'fqdn': 'mon.site.fr'},
                       {'ip': '2001:db8::1', 'fqdn': 'autre.site.fr'}]
            config_file.write_text(json.dumps(entries))
            env = dict(os.environ, BASH_SCRIPT_PATH=directory,
                       INTERFACE_ETHERNET1_STATE='DOWN', INTERFACE_ETHERNET1_IP='NONE',
                       INTERFACE_ETHERNET2_STATE='DOWN', INTERFACE_ETHERNET2_IP='NONE')
            command = ['bash', '-c', 'source "$1"; system_network_hosts', 'bash', str(script)]
            result = subprocess.run(command, env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            generated = hosts.read_text()
            self.assertNotIn('dev.example', generated)
            (base / 'config/hosts.json').unlink()
            second = subprocess.run(command, env=env, capture_output=True, text=True)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual(json.loads((base / 'config/hosts.json').read_text()), [])
            self.assertEqual(hosts.read_text(), generated)
            self.assertIn('127.0.0.1\tmon.site.fr\n2001:db8::1\tautre.site.fr', generated)
            for invalid in ('not json', '[{"ip":"127.0.0.1","fqdn":"bad\\nname"}]',
                            '[{"ip":"999.1.1.1","fqdn":"example.org"}]',
                            json.dumps([{'ip': 'fe80::1%eth0\n127.0.0.1 injected', 'fqdn': 'example.org'}])):
                config_file.write_text(invalid)
                result = subprocess.run(command, env=env, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(hosts.read_text(), generated)

    def test_management_sort_delete_and_isolation(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            base = Path(directory)
            production = base / 'production/config/hosts.json'
            dev = base / 'config/hosts.json'
            dev.parent.mkdir()
            dev.write_text('[]\n')
            script = ROOT / 'modules/system/hosts_json.py'
            def manage(*args):
                return subprocess.run(['python3', '-B', str(script), 'manage', str(production), *args],
                                      capture_output=True, text=True)
            self.assertEqual(manage('list').returncode, 0)
            self.assertEqual(json.loads(production.read_text()), [])
            for ip, fqdn in [('2001:db8::2', 'z.example'), ('192.0.2.10', 'z.example'),
                             ('192.0.2.2', 'b.example'), ('192.0.2.2', 'a.example')]:
                result = manage('add', ip, fqdn)
                self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(manage('add', '192.0.2.2', 'a.example').returncode, 0)
            entries = json.loads(production.read_text())
            self.assertEqual([(e['ip'], e['fqdn']) for e in entries], [
                ('192.0.2.2', 'a.example'), ('192.0.2.2', 'b.example'),
                ('192.0.2.10', 'z.example'), ('2001:db8::2', 'z.example')])
            self.assertIn('192.0.2.2\ta.example', manage('list').stdout)
            self.assertEqual(manage('del', '192.0.2.2', 'a.example').returncode, 0)
            self.assertIn('absente', manage('del', '192.0.2.2', 'absent.example').stdout)
            before = production.read_text()
            self.assertNotEqual(manage('add', 'bad', 'bad.example').returncode, 0)
            self.assertEqual(production.read_text(), before)
            self.assertEqual(manage('del', 'all').returncode, 0)
            self.assertEqual(json.loads(production.read_text()), [])
            self.assertEqual(dev.read_text(), '[]\n')
            production.write_text('invalid JSON')
            for args in [('add', '127.0.0.1', 'site.example'), ('del', 'all'), ('list',)]:
                self.assertNotEqual(manage(*args).returncode, 0)
                self.assertEqual(production.read_text(), 'invalid JSON')

    def test_shell_wrapper_targets_production_fixture_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            base = Path(directory)
            helper = base / 'modules/system'
            helper.mkdir(parents=True)
            shutil.copy(ROOT / 'modules/system/hosts_json.py', helper)
            production = base / 'production/config/hosts.json'
            development = base / 'config/hosts.json'
            development.parent.mkdir()
            development.write_text('[]\n')
            shell = base / 'network.sh'
            shell.write_text((ROOT / 'modules/system/network.sh').read_text().replace(
                '/root/diu/config/hosts.json', str(production)))
            command = ['bash', '-c', 'source "$1"; system_network_manage_hosts add 192.0.2.1 site.example',
                       'bash', str(shell)]
            result = subprocess.run(command, env=dict(os.environ, BASH_SCRIPT_PATH=directory),
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(production.read_text()), [{'ip': '192.0.2.1', 'fqdn': 'site.example'}])
            self.assertEqual(development.read_text(), '[]\n')

    def test_concurrent_additions_are_not_lost(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            production = Path(directory) / 'config/hosts.json'
            helper = ROOT / 'modules/system/hosts_json.py'
            processes = [subprocess.Popen(['python3', '-B', str(helper), 'manage', str(production),
                                           'add', f'192.0.2.{index}', f'host{index}.example'],
                                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                         for index in range(1, 9)]
            for process in processes:
                output, errors = process.communicate(timeout=10)
                self.assertEqual(process.returncode, 0, output + errors)
            self.assertEqual(len(json.loads(production.read_text())), 8)

    def test_old_projects_hosts_route_rejected(self):
        root_script = (ROOT / 'root-install-debian.sh').read_text()
        match = re.search(r'^manage_project_action\(\) \{\n.*?^\}', root_script, re.M | re.S)
        self.assertIsNotNone(match)
        script = match.group() + "\nrid_display_command_error() { :; }\nmanage_project_action system network hosts \"$@\"\n"
        for args in (('add', '192.0.2.1', 'site.example'), ('del', '192.0.2.1', 'site.example'),
                     ('del', 'all'), ('list',)):
            result = subprocess.run(['bash', '-c', script, 'bash', *args], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)

    def test_system_hosts_route_end_to_end_on_fixture(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            base = Path(directory)
            helper = base / 'modules/system'
            helper.mkdir(parents=True)
            shutil.copy(ROOT / 'modules/system/hosts_json.py', helper)
            production = base / 'production/config/hosts.json'
            network = base / 'network.sh'
            network.write_text((ROOT / 'modules/system/network.sh').read_text().replace(
                '/root/diu/config/hosts.json', str(production)))
            script = r'''
source "$ROOT/modules/system/apt.sh"
source "$NETWORK"
print_error() { printf '%s\n' "$*" >&2; }
manage_system_action network hosts "$@"
'''
            env = dict(os.environ, ROOT=str(ROOT), BASH_SCRIPT_PATH=directory, NETWORK=str(network))
            def call(*args):
                return subprocess.run(['bash', '-c', script, 'bash', *args], env=env,
                                      capture_output=True, text=True)
            self.assertIn('Aucune entrée', call('list').stdout)
            self.assertEqual(call('add', '127.0.0.1', 'site.example').returncode, 0)
            self.assertIn('127.0.0.1\tsite.example', call('list').stdout)
            self.assertEqual(call('del', '127.0.0.1', 'site.example').returncode, 0)
            self.assertEqual(call('del', 'all').returncode, 0)
            self.assertEqual(json.loads(production.read_text()), [])

    def test_system_hosts_help_levels(self):
        for suffix in (('network',), ('network', 'hosts'), ('network', 'hosts', 'add'),
                       ('network', 'hosts', 'del'), ('network', 'hosts', 'list'),
                       ('network', 'hosts', 'update'), ('network', 'hosts', 'del', 'all'),
                       ('network', 'hosts', 'add', '192.0.2.1', 'site.example')):
            with self.subTest(suffix=suffix):
                result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), 'system',
                                         *suffix, 'help'], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('rid system network hosts add <IP> <FQDN>', result.stdout)
                self.assertIn('rid system network hosts update', result.stdout)
        result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), 'projects',
                                 'system', 'network', 'hosts', 'list', 'help'],
                                capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)

    def test_dispatch_and_global_chain(self):
        script = r'''
source "$ROOT/modules/system/apt.sh"
source "$ROOT/modules/system/network.sh"
source "$ROOT/modules/diu/update-all.sh"
print_error() { printf '%s\n' "$*" >&2; }
system_network_hosts() { printf 'hosts\n'; }
system_apt_update() { :; }
system_flatpak_apply() { :; }
diu_update() { :; }
environments_update() { :; }
ia_update() { :; }
projects_update() { :; }
softwares_update() { :; }
manage_system_action network hosts update
manage_system_action network update
manage_system_action update
manage_update_action
if manage_system_action network hosts bogus; then exit 5; fi
'''
        result = subprocess.run(['bash', '-c', script], env=dict(os.environ, ROOT=str(ROOT)),
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ['hosts'] * 4)

    def test_help(self):
        script = r'''source "$ROOT/lib/rid-help.sh"; rid_display_help_context system network hosts update'''
        result = subprocess.run(['bash', '-c', script], env=dict(os.environ, ROOT=str(ROOT)),
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid system network hosts update', result.stdout)
        self.assertIn('entrées existantes sont remplacées', result.stdout)


if __name__ == '__main__':
    unittest.main()
