#!/usr/bin/env python3
"""Finalisation des dépôts tiers avec configuration, clés et réseau isolés."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLES = (
    'DOCKER', 'LEMONLDAP', 'MONGODB', 'NODEJS', 'NVIDIA',
    'PROXMOX', 'VSCODE', 'WAZUH', 'WEBMIN', 'CGPT',
)
REPOSITORIES = (
    'crowdsec', 'docker', 'lemonldap', 'mongodb', 'nodesource', 'nvidia',
    'nvidia-container-toolkit', 'proxmox', 'vscode', 'wazuh', 'webmin', 'chatgpt',
)


class UnofficialAptTests(unittest.TestCase):
    def prepare(self, directory):
        directory = Path(directory)
        (directory / 'sources').mkdir(exist_ok=True)
        (directory / 'keyrings').mkdir(exist_ok=True)
        (directory / 'config.txt').touch()
        (directory / 'local-public.asc').write_text('synthetic-local-public-key')
        declaration = (ROOT / 'modules/diu/variables/system/system_apt_unofficial.sh').read_text()
        declaration = declaration.replace(
            'variable_config_file="/root/diu/config/${scope}.env"',
            'variable_config_file="$TEST_CONFIG"')
        declaration = declaration.replace('/etc/apt/sources.list.d', '"$TEST_SOURCES"')
        declaration = declaration.replace('/etc/apt/sources.list', '"$TMPDIR/sources.list"')
        crowdsec = (ROOT / 'modules/diu/variables/softwares/software_apt_crowdsec.sh').read_text()
        crowdsec = crowdsec.replace(
            'variable_config_file="/root/diu/config/${scope}.env"',
            'variable_config_file="$TEST_SOFTWARES_CONFIG"')
        crowdsec = crowdsec.replace('/etc/apt/sources.list.d', '"$TEST_SOURCES"')
        crowdsec = crowdsec.replace('/etc/apt/sources.list', '"$TMPDIR/sources.list"')
        declaration += '\n' + crowdsec
        (directory / 'declaration.sh').write_text(declaration)
        module = (ROOT / 'modules/system/apt.sh').read_text().replace(
            'variable_config_file="/root/diu/config/system.env"',
            'variable_config_file="$TEST_CONFIG"').replace(
            'variable_config_file="/root/diu/config/softwares.env"',
            'variable_config_file="$TEST_SOFTWARES_CONFIG"')
        (directory / 'apt.sh').write_text(module)
        return directory

    def run_shell(self, directory, body, **values):
        prelude = r'''
set -Eeuo pipefail
print_error() { printf '%s\n' "$*" >&2; }
source "$TMPDIR/apt.sh"
SYSTEM_APT_THIRD_PARTY_DIRECTORY="$TEST_SOURCES"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="$TMPDIR/keyrings"
SYSTEM_APT_CGPT_KEY_FILE="$TMPDIR/local-public.asc"
system_apt_is_deb822() { [[ "$TEST_MODERN" == 1 ]]; }
curl() {
    printf 'curl %s\n' "$*" >> "$TMPDIR/calls"
    [[ "$TEST_FAILURE" != curl ]] || return 60
    printf 'synthetic-public-key'
}
gpg() {
    [[ "$1" == --dearmor && "$2" == --yes && "$3" == --output ]] || return 99
    printf 'gpg\n' >> "$TMPDIR/calls"
    cat > "$4"
    [[ "$TEST_FAILURE" != gpg ]]
}
system_apt_debian_configure() { system_apt_configure_unofficial; }
'''
        env = dict(PATH=os.defpath, ROOT=str(ROOT), TMPDIR=str(directory),
                   TEST_CONFIG=str(directory / 'config.txt'),
                   TEST_SOFTWARES_CONFIG=str(directory / 'softwares.txt'),
                   TEST_SOURCES=str(directory / 'sources'), TEST_MODERN='1',
                   TEST_FAILURE='', SYSTEM_DEBIAN_RELEASE='trixie')
        env.update({name: str(value) for name, value in values.items()})
        return subprocess.run(['bash', '-c', prelude + '\n' + body], env=env,
                              text=True, capture_output=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_defaults_detection_export_and_persistence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            result = self.run_shell(directory, r'''
source "$TMPDIR/declaration.sh"
bash -c '[[ "$SYSTEM_APT_DOCKER" == 0 && "$SYSTEM_APT_CGPT" == 0 ]]'
source "$TMPDIR/declaration.sh"
''')
            self.assert_success(result)
            self.assertEqual((directory / 'config.txt').read_text().splitlines(),
                             [f'export SYSTEM_APT_{name}=0' for name in VARIABLES])
            self.assertEqual((directory / 'softwares.txt').read_text().splitlines(),
                             ['export SOFTWARES_APT_CROWDSEC=0'])

    def test_each_existing_repository_is_detected(self):
        patterns = dict(
            CROWDSEC='packagecloud.io/crowdsec', DOCKER='download.docker.com',
            LEMONLDAP='lemonldap-ng', MONGODB='mongodb-org/4.4',
            NODEJS='deb.nodesource.com', NVIDIA='developer.download.nvidia.com',
            PROXMOX='download.proxmox.com', VSCODE='packages.microsoft.com/repos/code',
            WAZUH='packages.wazuh.com/4.x', WEBMIN='download.webmin.com', CGPT='codex',
        )
        for name, pattern in patterns.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                (directory / 'sources/existing.sources').write_text(pattern)
                result = self.run_shell(directory, 'source "$TMPDIR/declaration.sh"')
                self.assert_success(result)
                expected = 4 if name in ('MONGODB', 'WAZUH') else 1
                config = directory / ('softwares.txt' if name == 'CROWDSEC' else 'config.txt')
                variable = 'SOFTWARES_APT_CROWDSEC' if name == 'CROWDSEC' else f'SYSTEM_APT_{name}'
                self.assertIn(f'export {variable}={expected}', config.read_text().splitlines())

    def test_legacy_activation_fallback(self):
        cases = [
            ({'SOFTWARES_APT_CROWDSEC_AGENT': 1}, 'CROWDSEC', 1),
            ({'SOFTWARES_APT_CROWDSEC_BOUNCER': 1}, 'CROWDSEC', 1),
            ({'SOFTWARES_APT_LEMONLDAP': 1}, 'LEMONLDAP', 1),
            ({'SOFTWARES_APT_WAZUH_SERVER': 1, 'WAZUH_SERVER_UPGRADE': 1}, 'WAZUH', 4),
            ({'SOFTWARES_APT_WAZUH_SERVER': 1, 'WAZUH_SERVER_UPGRADE': 0}, 'WAZUH', 0),
            ({'SOFTWARES_APT_WAZUH_SERVER': 0, 'WAZUH_SERVER_UPGRADE': 1}, 'WAZUH', 0),
        ]
        cases += [({'SOFTWARES_APT_MONGODB': 1, 'MONGODB_VERSION': version}, 'MONGODB', branch)
                  for version, branch in [('4.4', 4), ('5', 5), ('6', 6), ('7', 7), ('8', 8)]]
        cases += [({'SOFTWARES_APT_MONGODB': 0, 'MONGODB_VERSION': '8'}, 'MONGODB', 0),
                  ({'SOFTWARES_APT_MONGODB': 1, 'MONGODB_VERSION': 'unknown'}, 'MONGODB', 0)]
        for values, name, expected in cases:
            with self.subTest(values=values), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                result = self.run_shell(directory, 'source "$TMPDIR/declaration.sh"', **values)
                self.assert_success(result)
                config = directory / ('softwares.txt' if name == 'CROWDSEC' else 'config.txt')
                variable = 'SOFTWARES_APT_CROWDSEC' if name == 'CROWDSEC' else f'SYSTEM_APT_{name}'
                self.assertIn(f'export {variable}={expected}', config.read_text().splitlines())

    def test_persisted_values_take_priority_over_detection_and_legacy(self):
        for value in (0, 1, 4):
            with self.subTest(value=value), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                (directory / 'sources/wazuh.sources').write_text('packages.wazuh.com/4.x')
                result = self.run_shell(directory, r'''
source "$TMPDIR/declaration.sh"
printf '%s\n' "$SYSTEM_APT_WAZUH"
''', SYSTEM_APT_WAZUH=value, WAZUH_SERVER=1, WAZUH_SERVER_UPGRADE=1)
                self.assert_success(result)
                self.assertEqual(result.stdout.strip(), str(value))
                self.assertNotIn('SYSTEM_APT_WAZUH', (directory / 'config.txt').read_text())

    def test_wazuh_values_and_commands(self):
        for modern in (0, 1):
            for value in (0, 1, 4):
                with self.subTest(modern=modern, value=value), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                    directory = self.prepare(tmp)
                    keyring = directory / 'keyrings/wazuh-archive-keyring.gpg'
                    keyring.write_text('existing-synthetic-keyring')
                    for suffix in ('sources', 'list'):
                        (directory / f'sources/wazuh.{suffix}').write_text('old-source')
                    result = self.run_shell(directory, r'''
system_apt_configure_unofficial
printf '%s\n' "$SYSTEM_APT_WAZUH"
''', TEST_MODERN=modern, SYSTEM_APT_WAZUH=value)
                    self.assert_success(result)
                    self.assertEqual(result.stdout.strip(), str(value))
                    suffix = 'sources' if modern else 'list'
                    source = directory / f'sources/wazuh.{suffix}'
                    self.assertEqual(source.exists(), value != 0)
                    self.assertEqual(keyring.exists(), value != 0)
                    if value:
                        self.assertIn('https://packages.wazuh.com/4.x/apt', source.read_text())
                    self.assertFalse((directory / 'calls').exists())
            for action, requested, expected in [('install', 'wazuh-4', 4),
                                                ('install', 'wazuh', 1), ('remove', 'wazuh', 0)]:
                with self.subTest(action=action, requested=requested), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                    directory = self.prepare(tmp)
                    result = self.run_shell(directory, f'manage_system_action {action} apt {requested}',
                                            TEST_MODERN=modern)
                    self.assert_success(result)
                    self.assertIn(f'SYSTEM_APT_WAZUH={expected}',
                                  (directory / 'config.txt').read_text())

    def test_invalid_wazuh_aborts_before_configuring_repositories(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            result = self.run_shell(directory, r'''
if system_apt_configure_unofficial; then exit 99; else exit "$?"; fi
''', SYSTEM_APT_WAZUH=8, SYSTEM_APT_DOCKER=1)
            self.assertEqual(result.returncode, 1)
            self.assertIn('Activation de dépôt APT invalide : wazuh', result.stderr)
            self.assertFalse((directory / 'calls').exists())
            self.assertEqual(list((directory / 'sources').iterdir()), [])

    def test_mongodb_branch_and_debian_suite_compatibility(self):
        for release in ('bullseye', 'bookworm', 'trixie'):
            for branch in (4, 5, 6, 7, 8):
                with self.subTest(release=release, branch=branch), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                    directory = self.prepare(tmp)
                    result = self.run_shell(directory, 'system_apt_configure_unofficial',
                                            SYSTEM_DEBIAN_RELEASE=release, SYSTEM_APT_MONGODB=branch)
                    self.assert_success(result)
                    version = '4.4' if branch == 4 else f'{branch}.0'
                    suite = 'bullseye' if release == 'bullseye' else 'bookworm'
                    self.assertIn(f'Suites: {suite}/mongodb-org/{version}',
                                  (directory / 'sources/mongodb.sources').read_text())
                    self.assertIn(f'server-{version}.asc', (directory / 'calls').read_text())

    def test_all_repositories_and_both_formats_preserve_existing_keyrings(self):
        for modern in (0, 1):
            with self.subTest(modern=modern), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                for name in REPOSITORIES:
                    (directory / f'keyrings/{name}-archive-keyring.gpg').write_text('existing-keyring')
                values = {f'SYSTEM_APT_{name}': 1 for name in VARIABLES}
                values['SOFTWARES_APT_CROWDSEC'] = 1
                values.update(SYSTEM_APT_MONGODB=8, SYSTEM_APT_WAZUH=4, TEST_MODERN=modern,
                              TEST_FAILURE='curl')
                result = self.run_shell(directory, 'system_apt_configure_unofficial', **values)
                self.assert_success(result)
                suffix = 'sources' if modern else 'list'
                self.assertEqual({p.name for p in (directory / 'sources').iterdir()},
                                 {f'{name}.{suffix}' for name in REPOSITORIES})
                for name in REPOSITORIES:
                    if modern and name.startswith('nvidia'):
                        self.assertNotIn('Components:', (directory / f'sources/{name}.{suffix}').read_text())
                    if name != 'chatgpt':
                        self.assertEqual((directory / f'keyrings/{name}-archive-keyring.gpg').read_text(),
                                         'existing-keyring')
                self.assertFalse((directory / 'calls').exists())

    def test_install_remove_commands_and_real_persistence_for_every_repository(self):
        for requested in ('crowdsec', 'docker', 'lemonldap', 'mongodb', 'nodejs',
                          'nvidia', 'proxmox', 'vscode', 'wazuh', 'webmin', 'cgpt'):
            with self.subTest(requested=requested), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                result = self.run_shell(directory, f'''
manage_system_action install apt {requested}
manage_system_action install apt {requested}
''')
                self.assert_success(result)
                config_file = directory / ('softwares.txt' if requested == 'crowdsec' else 'config.txt')
                config = config_file.read_text().splitlines()
                variable = 'SOFTWARES_APT_CROWDSEC' if requested == 'crowdsec' else f'SYSTEM_APT_{requested.upper()}'
                value = 8 if requested == 'mongodb' else 1
                self.assertEqual(config, [f'export {variable}={value}'])
                self.assertTrue(list((directory / 'sources').iterdir()))
                result = self.run_shell(directory, f'manage_system_action remove apt {requested}')
                self.assert_success(result)
                self.assertEqual(config_file.read_text().splitlines(),
                                 [f'export {variable}=0'])
                self.assertEqual(list((directory / 'sources').iterdir()), [])

    def test_mongodb_command_keeps_configured_branch_or_selects_explicit_branch(self):
        for requested, initial, expected in [('mongodb', 4, 4), ('mongodb', 7, 7),
                                              ('mongodb-4', 8, 4), ('mongodb-8', 4, 8)]:
            with self.subTest(requested=requested, initial=initial), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                result = self.run_shell(directory, f'manage_system_action install apt {requested}',
                                        SYSTEM_APT_MONGODB=initial)
                self.assert_success(result)
                self.assertIn(f'export SYSTEM_APT_MONGODB={expected}',
                              (directory / 'config.txt').read_text().splitlines())

    def test_historical_crowdsec_keyring_is_copied_without_download(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            historical = directory / 'keyrings/crowdsec-crowdsec-archive-keyring.gpg'
            historical.write_text('historical-synthetic-keyring')
            result = self.run_shell(directory, 'system_apt_configure_unofficial',
                                    SOFTWARES_APT_CROWDSEC=1, TEST_FAILURE='curl')
            self.assert_success(result)
            self.assertEqual((directory / 'keyrings/crowdsec-archive-keyring.gpg').read_text(),
                             historical.read_text())
            self.assertEqual(historical.read_text(), 'historical-synthetic-keyring')
            self.assertFalse((directory / 'calls').exists())

    def test_repository_failure_propagates_in_conditional_call(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            result = self.run_shell(directory, r'''
if system_apt_configure_unofficial; then exit 99; else exit "$?"; fi
''', SYSTEM_APT_DOCKER=1, SYSTEM_APT_LEMONLDAP=1, TEST_FAILURE='curl')
            self.assertEqual(result.returncode, 1)
            self.assertIn("Impossible d'installer la clé GPG du dépôt APT : docker", result.stderr)
            self.assertEqual(list((directory / 'sources').iterdir()), [])
            self.assertNotIn('lemonldap', (directory / 'calls').read_text())

    def test_cgpt_install_remove_and_local_key(self):
        for modern in (0, 1):
            with self.subTest(modern=modern), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = self.prepare(tmp)
                result = self.run_shell(directory, r'''
manage_system_action install apt cgpt
[[ "$SYSTEM_APT_CGPT" == 1 ]]
''', TEST_MODERN=modern, TEST_FAILURE='curl')
                self.assert_success(result)
                suffix = 'sources' if modern else 'list'
                self.assertEqual({p.name for p in (directory / 'sources').iterdir()},
                                 {f'chatgpt.{suffix}'})
                self.assertEqual((directory / 'keyrings/chatgpt-archive-keyring.gpg').read_text(),
                                 'synthetic-local-public-key')
                self.assertFalse((directory / 'calls').exists())
                result = self.run_shell(directory, r'''
manage_system_action remove apt cgpt
[[ "$SYSTEM_APT_CGPT" == 0 ]]
''', TEST_MODERN=modern, TEST_FAILURE='curl')
                self.assert_success(result)
                self.assertEqual(list((directory / 'sources').iterdir()), [])
                self.assertFalse((directory / 'keyrings/chatgpt-archive-keyring.gpg').exists())

    def test_cgpt_missing_local_key_does_not_write_sources(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            result = self.run_shell(directory, r'''
SYSTEM_APT_CGPT_KEY_FILE="$TMPDIR/missing-public.asc"
if system_apt_configure_unofficial; then exit 99; else exit "$?"; fi
''', SYSTEM_APT_CGPT=1)
            self.assertEqual(result.returncode, 1)
            self.assertIn('missing-public.asc', result.stderr)
            self.assertEqual(list((directory / 'sources').iterdir()), [])

    def test_failed_historical_key_copy_preserves_original_and_sources(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            directory = self.prepare(tmp)
            historical = directory / 'keyrings/crowdsec-crowdsec-archive-keyring.gpg'
            historical.write_text('historical-synthetic-keyring')
            result = self.run_shell(directory, r'''
install() { if [[ "$1" == -m ]]; then return 1; else command install "$@"; fi; }
if system_apt_configure_unofficial; then exit 99; else exit "$?"; fi
''', SOFTWARES_APT_CROWDSEC=1, TEST_FAILURE='curl')
            self.assertEqual(result.returncode, 1)
            self.assertIn('Impossible d\'installer la clé GPG historique', result.stderr)
            self.assertEqual(historical.read_text(), 'historical-synthetic-keyring')
            self.assertFalse((directory / 'calls').exists())
            self.assertEqual(list((directory / 'sources').iterdir()), [])


class HistoricalAptTests(unittest.TestCase):
    def test_monolith_keeps_one_repository_configuration_and_fusiondirectory(self):
        block = (ROOT / 'root-install-debian.sh').read_text().split('### APT ###', 1)[1].split('### DRIVERS ###', 1)[0]
        self.assertEqual(block.count('system_apt_debian_configure'), 1)
        for token in ('CROWDSEC_BOUNCER', '$LEMONLDAP', '$MONGODB', '$WAZUH_SERVER', 'curl -fsSL'):
            self.assertNotIn(token, block)
        for release, fusion in [('bookworm', 0), ('bullseye', 0), ('bullseye', 1)]:
            with self.subTest(release=release, fusion=fusion), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = Path(tmp)
                (directory / 'etc/apt/sources.list.d').mkdir(parents=True)
                (directory / 'usr/share/keyrings').mkdir(parents=True)
                isolated = block.replace('/etc/', str(directory / 'etc') + '/')
                isolated = isolated.replace('/usr/share/', str(directory / 'usr/share') + '/')
                mocks = r'''
set -Eeuo pipefail
system_apt_debian_configure() { printf 'CONFIGURE\n'; }
apt() { printf 'APT %s\n' "$*"; }
gpg() {
    printf 'GPG %s\n' "$*" >> "$TMPDIR/calls"
    if [[ "$1" == --export ]]; then printf 'synthetic-public-key'; fi
}
'''
                result = subprocess.run(['bash', '-c', mocks + isolated], text=True, capture_output=True,
                                        env=dict(PATH=os.defpath, TMPDIR=tmp, SYSTEM_DEBIAN_RELEASE=release,
                                                 DIU_APT_REPOSITORY_FD=str(fusion)))
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stdout.splitlines().count('CONFIGURE'), 1)
                self.assertIn('APT -y update', result.stdout)
                self.assertIn('APT autoremove -y', result.stdout)
                source = directory / 'etc/apt/sources.list.d/fusion-directory.list'
                self.assertEqual(source.exists(), bool(fusion))
                if fusion:
                    self.assertIn('bullseye-fusiondirectory-release/', source.read_text())
                    self.assertEqual(len((directory / 'calls').read_text().splitlines()), 2)
                else:
                    self.assertFalse((directory / 'calls').exists())


if __name__ == '__main__':
    unittest.main()
