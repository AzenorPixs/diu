import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AptSourceInitializationTests(unittest.TestCase):
    def detect(self, variable, files, binary=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            root = Path(folder)
            (root / 'sources.list.d').mkdir()
            for name, text in files.items():
                (root / name).write_text(text, encoding='utf-8')
            command = [sys.executable, '-B', str(ROOT / 'modules/system/apt_sources.py'), variable, '--root', str(root)]
            if binary:
                command.append('--binary')
            return subprocess.run(command, text=True, capture_output=True, check=False)

    def test_independent_components_in_both_formats(self):
        for text, name in [('deb https://deb.debian.org/debian trixie main non-free-firmware\n', 'sources.list'),
                           ('Types: deb\nURIs: https://mirror.invalid/debian\nSuites: trixie\nComponents: main\n non-free-firmware\n', 'sources.list.d/debian.sources')]:
            for variable, expected in [('SYSTEM_APT_DEBIAN_NONFRFEE', '0'),
                                       ('SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE', '1'),
                                       ('SYSTEM_APT_DEBIAN_CONTRIB', '0')]:
                with self.subTest(name=name, variable=variable):
                    result = self.detect(variable, {name: text})
                    self.assertEqual((result.returncode, result.stdout), (0, expected + '\n'), result.stderr)

    def test_comments_disabled_stanzas_and_backups_do_not_activate(self):
        files = {'sources.list': '# deb https://deb.debian.org/debian trixie main contrib\n',
                 'sources.list.d/backup.list.save': 'deb https://deb.debian.org/debian trixie contrib\n',
                 'sources.list.d/invalid name.list': 'deb https://deb.debian.org/debian trixie contrib\n',
                 'sources.list.d/disabled.sources': 'Enabled: no\nTypes: deb\nURIs: https://deb.debian.org/debian\nSuites: trixie\nComponents: contrib\n'}
        result = self.detect('SYSTEM_APT_DEBIAN_CONTRIB', files)
        self.assertEqual((result.returncode, result.stdout), (0, '0\n'), result.stderr)

    def test_multiple_mongodb_branches_are_reported_as_ambiguous(self):
        result = self.detect('SYSTEM_APT_MONGODB', {'sources.list':
                             'deb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main\n'
                             'deb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main\n'})
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, '')

    def test_source_code_repository_does_not_prove_binary_readiness(self):
        files = {'sources.list': 'deb-src https://deb.debian.org/debian trixie main contrib\n'}
        declared = self.detect('SYSTEM_APT_DEBIAN_CONTRIB', files)
        binaries = self.detect('SYSTEM_APT_DEBIAN_CONTRIB', files, binary=True)
        self.assertEqual((declared.returncode, declared.stdout), (0, '1\n'), declared.stderr)
        self.assertEqual((binaries.returncode, binaries.stdout), (0, '0\n'), binaries.stderr)

    def test_unsupported_version_is_not_initialised_as_absent(self):
        for variable, entry in [('SYSTEM_APT_MONGODB', 'deb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/9.0 main\n'),
                                ('SYSTEM_APT_WAZUH', 'deb https://packages.wazuh.com/5.x/apt stable main\n')]:
            result = self.detect(variable, {'sources.list': entry})
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, '')

    def test_all_repository_variables_detect_active_sources(self):
        paths = {'SYSTEM_APT_DOCKER': 'https://download.docker.com/linux/debian',
                 'SYSTEM_APT_LEMONLDAP': 'https://lemonldap-ng.org/deb',
                 'SYSTEM_APT_NODEJS': 'https://deb.nodesource.com/node_24.x',
                 'SYSTEM_APT_NVIDIA': 'https://nvidia.github.io/libnvidia-container/stable/deb/amd64',
                 'SYSTEM_APT_PROXMOX': 'https://download.proxmox.com/debian/pve',
                 'SYSTEM_APT_VSCODE': 'https://packages.microsoft.com/repos/code',
                 'SYSTEM_APT_WEBMIN': 'https://download.webmin.com/download/newkey/repository',
                 'SYSTEM_APT_CGPT': 'https://persistent.oaistatic.com/codex-app-prod/linux/deb',
                 'SOFTWARE_APT_CROWDSEC': 'https://packagecloud.io/crowdsec/crowdsec/any',
                 'DIU_APT_REPOSITORY_FD': 'https://public.fusiondirectory.org/debian/fusiondirectory-tools/'}
        for variable, uri in paths.items():
            for disabled in (False, True):
                with self.subTest(variable=variable, disabled=disabled):
                    text = ('# ' if disabled else '') + f'deb {uri} stable main\n'
                    r = self.detect(variable, {'sources.list': text})
                    self.assertEqual((r.returncode, r.stdout), (0, f'{0 if disabled else 1}\n'), r.stderr)

    def test_versions_suites_and_source_packages(self):
        files = {'sources.list': 'deb-src https://deb.debian.org/debian trixie-updates main\ndeb https://deb.debian.org/debian trixie-backports main\ndeb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main\ndeb https://packages.wazuh.com/4.x/apt stable main\n'}
        for variable, expected in [('SYSTEM_APT_MONGODB', 8), ('SYSTEM_APT_WAZUH', 4),
                                   ('SYSTEM_APT_DEBIAN_SOURCES', 1), ('SYSTEM_APT_DEBIAN_UPDATES', 1),
                                   ('SYSTEM_APT_DEBIAN_BACKPORT', 1)]:
            r = self.detect(variable, files)
            self.assertEqual((r.returncode, r.stdout), (0, f'{expected}\n'), r.stderr)

    def test_invalid_active_source_does_not_become_absence(self):
        r = self.detect('SYSTEM_APT_DOCKER', {'sources.list.d/invalid.sources': 'Types: deb\nURIs: https://download.docker.com\n'})
        self.assertNotEqual(r.returncode, 0)
        self.assertEqual(r.stdout, '')
        self.assertNotIn('https://', r.stderr)

    def test_first_declaration_is_persisted_and_existing_zero_preserved(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            root = Path(folder)
            (root / 'sources.list').write_text('deb https://deb.debian.org/debian trixie main contrib\n')
            config = root / 'system.env'
            script = r'''
set -Eeuo pipefail
source "$1/modules/system/apt-source-state.sh"
unset SYSTEM_APT_DEBIAN_CONTRIB
system_apt_repository_declare "$2" SYSTEM_APT_DEBIAN_CONTRIB
[[ "$SYSTEM_APT_DEBIAN_CONTRIB" == 1 ]]
SYSTEM_APT_DEBIAN_CONTRIB=0
system_apt_repository_declare "$2" SYSTEM_APT_DEBIAN_CONTRIB
[[ "$SYSTEM_APT_DEBIAN_CONTRIB" == 0 ]]
'''
            r = subprocess.run(['bash', '-c', script, '--', str(ROOT), str(config)],
                               env=dict(os.environ, SYSTEM_APT_SOURCE_ROOT=str(root)), text=True, capture_output=True)
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertEqual(config.read_text(), 'export SYSTEM_APT_DEBIAN_CONTRIB=1\n')

    def test_system_commands_keep_non_free_and_firmware_independent(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            root = Path(folder)
            source = (ROOT / 'modules/system/apt.sh').read_text()
            source = source.replace('. "$(dirname -- "${BASH_SOURCE[0]}")/apt-source-state.sh"',
                                    '. "$TEST_ROOT/modules/system/apt-source-state.sh"')
            source = source.replace('variable_config_file="/root/diu/config/system.env"',
                                    'variable_config_file="$TEST_CONFIG"')
            module = root / 'apt.sh'
            module.write_text(source)
            script = r'''
set -Eeuo pipefail
source "$TEST_MODULE"
print_error() { printf '%s\n' "$*" >&2; }
system_apt_configure_debian_sources() { system_apt_debian_components; printf '\n'; }
SYSTEM_APT_DEBIAN_CONTRIB=0
SYSTEM_APT_DEBIAN_NONFRFEE=0
SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE=0
manage_system_action install apt non-free-firmware
[[ "$SYSTEM_APT_DEBIAN_NONFRFEE" == 0 && "$SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE" == 1 ]]
manage_system_action install apt non-free
manage_system_action remove apt non-free-firmware
[[ "$SYSTEM_APT_DEBIAN_NONFRFEE" == 1 && "$SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE" == 0 ]]
'''
            config = root / 'system.env'
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True,
                                    env=dict(os.environ, TEST_ROOT=str(ROOT), TEST_MODULE=str(module), TEST_CONFIG=str(config)))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), ['main non-free-firmware', 'main non-free non-free-firmware', 'main non-free'])
            self.assertIn('export SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE=0\n', config.read_text())

    def test_all_global_repository_declarations_detect_then_preserve(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            root = Path(folder)
            (root / 'sources.list.d').mkdir()
            (root / 'sources.list').write_text(
                'deb-src https://deb.debian.org/debian trixie main contrib non-free non-free-firmware\n'
                'deb https://deb.debian.org/debian trixie-updates main\n'
                'deb https://deb.debian.org/debian trixie-backports main\n'
                'deb https://download.docker.com/linux/debian trixie stable\n'
                'deb https://lemonldap-ng.org/deb stable main\n'
                'deb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main\n'
                'deb https://deb.nodesource.com/node_24.x nodistro main\n'
                'deb https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64 /\n'
                'deb https://download.proxmox.com/debian/pve trixie pve-no-subscription\n'
                'deb https://packages.microsoft.com/repos/code stable main\n'
                'deb https://packages.wazuh.com/4.x/apt stable main\n'
                'deb https://download.webmin.com/download/repository sarge contrib\n'
                'deb https://persistent.oaistatic.com/codex-app-prod/linux/deb stable main\n'
                'deb https://packagecloud.io/crowdsec/crowdsec/any any main\n'
                'deb https://public.fusiondirectory.org/debian/fusiondirectory-tools/ bullseye main\n')
            files = list((ROOT / 'modules/diu/variables/system').glob('system_apt_debian_*.sh'))
            files += [ROOT / 'modules/diu/variables/system/system_apt_unofficial.sh',
                      ROOT / 'modules/diu/variables/diu/diu_apt_repository_fd.sh',
                      ROOT / 'modules/diu/variables/softwares/desired_crowdsec_repository.sh']
            copies = []
            for index, path in enumerate(files):
                target = root / f'declaration-{index}.sh'
                target.write_text(path.read_text().replace('variable_config_file="/root/diu/config/${scope}.env"',
                                                         'variable_config_file="$FIXTURE/${scope}.env"'))
                copies.append(str(target))
            script = r'''
set -Eeuo pipefail
source "$TEST_ROOT/modules/system/apt-source-state.sh"
source "$TEST_ROOT/modules/softwares/desired-state.sh"
source "$TEST_ROOT/modules/softwares/global-declarations.sh"
for file in "$@"; do source "$file"; done
[[ "$SYSTEM_APT_MONGODB" == 8 && "$SYSTEM_APT_WAZUH" == 4 ]]
for variable in SYSTEM_APT_DEBIAN_CONTRIB SYSTEM_APT_DEBIAN_NONFRFEE SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE SYSTEM_APT_DEBIAN_UPDATES SYSTEM_APT_DEBIAN_BACKPORT SYSTEM_APT_DEBIAN_SOURCES SYSTEM_APT_DOCKER SYSTEM_APT_LEMONLDAP SYSTEM_APT_NODEJS SYSTEM_APT_NVIDIA SYSTEM_APT_PROXMOX SYSTEM_APT_VSCODE SYSTEM_APT_WEBMIN SYSTEM_APT_CGPT DIU_APT_REPOSITORY_FD SOFTWARE_APT_CROWDSEC; do
    [[ "${!variable}" == 1 ]]
done
: > "$FIXTURE/sources.list"
for file in "$@"; do source "$file"; done
[[ "$SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE" == 1 && "$SYSTEM_APT_DOCKER" == 1 ]]
'''
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith(('SYSTEM_APT_', 'SOFTWARE_APT_CROWDSEC', 'DIU_APT_REPOSITORY_FD'))}
            env.update(TEST_ROOT=str(ROOT), FIXTURE=str(root), SYSTEM_APT_SOURCE_ROOT=str(root))
            result = subprocess.run(['bash', '-c', script, '--', *copies], env=env,
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(sum(len(p.read_text().splitlines()) for p in root.glob('*.env')), 18)


if __name__ == '__main__':
    unittest.main()
