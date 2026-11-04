import os
import json
import shutil
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
            isolated.write_text(source.replace('/etc/hosts', str(hosts)))
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
            isolated.write_text(source.replace('/etc/hosts', str(Path(directory) / 'missing' / 'hosts')))
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
            script.write_text(source.replace('/etc/hosts', str(hosts)))
            config = base / 'config'
            config.mkdir()
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
            self.assertIn('127.0.0.1\tmon.site.fr\n2001:db8::1\tautre.site.fr', generated)
            for invalid in ('not json', '[{"ip":"127.0.0.1","fqdn":"bad\\nname"}]',
                            '[{"ip":"999.1.1.1","fqdn":"example.org"}]',
                            json.dumps([{'ip': 'fe80::1%eth0\n127.0.0.1 injected', 'fqdn': 'example.org'}])):
                config_file.write_text(invalid)
                result = subprocess.run(command, env=env, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(hosts.read_text(), generated)

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
