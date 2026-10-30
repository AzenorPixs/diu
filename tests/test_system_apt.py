#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SystemAptTests(unittest.TestCase):
    BASE_PACKAGES = set('''
        aptitude apache2-utils apt-transport-https bash-completion
        bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg
        gpg inetutils-telnet iptables jq libpq5 libsecret-tools lshw lsb-release
        man-db manpages-fr net-tools netcat-traditional nicstat openssl pciutils
        postgresql-client python3-pytest ripgrep shellcheck sudo tcpdump
        traceroute tree util-linux wget
    '''.split())

    def run_prerequisites(self, family=None, installed='', failure='', display='0'):
        script = r'''
set -Eeuo pipefail
print_info() { printf 'INFO %s\n' "$*"; }
print_error() { printf 'ERROR %s\n' "$*" >&2; }
dpkg-query() {
    case " $TEST_INSTALLED " in
        *" ${!#} "*) printf 'installed\n' ;;
        *) return 1 ;;
    esac
}
apt-get() {
    [[ $# -eq 4 && "$1" == install && "$2" == -y && "$3" == -- ]] || return 99
    printf 'APT %s\n' "$4"
    [[ "$4" != "$TEST_FAILURE" ]]
}
source "$ROOT/modules/system/apt.sh"
if system_install_prerequisites; then
    exit 0
else
    exit "$?"
fi
'''
        env = dict(os.environ, ROOT=str(ROOT), TEST_INSTALLED=installed,
                   TEST_FAILURE=failure, SYSTEM_DRIVERS_DISPLAY_LINK=display)
        env.pop('SYSTEM_DEBIAN_ENVIRONNEMENT', None)
        if family is not None:
            env['SYSTEM_DEBIAN_ENVIRONNEMENT'] = family
        return subprocess.run(['bash', '-c', script], env=env, text=True,
                              capture_output=True)

    def assert_prerequisites(self, result, expected):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')
        lines = []
        for package in sorted(expected):
            lines.extend([f'INFO Installation du prérequis : {package}',
                          f'APT {package}'])
        self.assertEqual(result.stdout.splitlines(), lines)

    def test_prerequisites_for_all_families(self):
        for family in ('LXC', 'PHYSICAL', 'VM', 'DOCKER', 'PROXMOX'):
            with self.subTest(family=family):
                extra = {'acl'}
                if family == 'PROXMOX':
                    extra |= {'conntrack', 'glances', 'rsync'}
                self.assert_prerequisites(self.run_prerequisites(family),
                                          self.BASE_PACKAGES | extra)

    def test_docker_and_vm_have_identical_prerequisites(self):
        docker = self.run_prerequisites('DOCKER')
        vm = self.run_prerequisites('VM')
        self.assertEqual(docker.returncode, 0, docker.stderr)
        self.assertEqual(vm.returncode, 0, vm.stderr)
        self.assertEqual(docker.stdout, vm.stdout)

    def test_unknown_environment_preserves_initial_base(self):
        for family in (None, '', 'UNSET', 'UNKNOWN'):
            with self.subTest(family=family):
                self.assert_prerequisites(self.run_prerequisites(family),
                                          self.BASE_PACKAGES)

    def test_installed_packages_are_silent(self):
        for family in ('LXC', 'PHYSICAL', 'VM', 'DOCKER', 'PROXMOX'):
            with self.subTest(family=family):
                installed = self.BASE_PACKAGES | {'acl', 'conntrack', 'glances', 'rsync'}
                self.assert_prerequisites(
                    self.run_prerequisites(family, ' '.join(sorted(installed))), set())

    def test_installed_aptitude_does_not_hide_missing_package(self):
        installed = (self.BASE_PACKAGES | {'acl'}) - {'jq'}
        self.assert_prerequisites(
            self.run_prerequisites('VM', ' '.join(sorted(installed))), {'jq'})

    def test_apt_failure_stops_even_in_conditional_call(self):
        result = self.run_prerequisites('VM', failure='acl')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(),
                         ['INFO Installation du prérequis : acl', 'APT acl'])
        self.assertIn("Échec de l'installation du prérequis : acl", result.stderr)

    def test_shared_function_does_not_install_displaylink(self):
        self.assert_prerequisites(self.run_prerequisites('PHYSICAL', display='1'),
                                  self.BASE_PACKAGES | {'acl'})

    def test_historical_prerequisites_and_displaylink(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        block = source.split('### PREREQUISITES ###', 1)[1].split('### APT ###', 1)[0]
        mocks = r'''
set -Eeuo pipefail
system_install_prerequisites() { printf 'COMMON\n'; }
dpkg() {
    [[ "$*" == '-s evdi-dkms' ]] || exit 99
    [[ "$TEST_DISPLAY_INSTALLED" == 1 ]]
}
uname() { printf 'test-kernel\n'; }
apt() { printf 'APT %s\n' "$*"; }
'''
        for family in ('LXC', 'PHYSICAL', 'VM', 'DOCKER', 'PROXMOX'):
            for display, installed in (('0', '0'), ('UNSET', '0'), ('1', '0'), ('1', '1')):
                with self.subTest(family=family, display=display, installed=installed):
                    env = dict(os.environ, SYSTEM_DEBIAN_ENVIRONNEMENT=family,
                               SYSTEM_DRIVERS_DISPLAY_LINK=display, TEST_DISPLAY_INSTALLED=installed)
                    result = subprocess.run(['bash', '-c', mocks + block], env=env,
                                            text=True, capture_output=True)
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    lines = result.stdout.splitlines()
                    self.assertEqual(lines.count('COMMON'), 1)
                    self.assertEqual(lines[0], 'COMMON')
                    apt_calls = [line for line in lines if line.startswith('APT ')]
                    self.assertEqual(apt_calls, [])
                    self.assertEqual(lines, ['COMMON'])

    def test_prerequisites_include_postgresql_packages(self):
        script = r'''
set -Eeuo pipefail
print_info() { :; }
apt-get() { printf '%s\n' "$*"; }
dpkg-query() { return 1; }
source "$ROOT/modules/system/apt.sh"
system_install_prerequisites
'''
        result = subprocess.run(
            ["bash", "-c", script],
            env=dict(os.environ, ROOT=str(ROOT)),
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("install -y -- libpq5", result.stdout.splitlines())
        self.assertIn("install -y -- postgresql-client", result.stdout.splitlines())

    def test_nvidia_deb822_sources_omit_components(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            directory = Path(directory)
            script = r'''
set -Eeuo pipefail
print_error() { printf '%s\n' "$*" >&2; }
source "$ROOT/modules/system/apt.sh"
SYSTEM_DEBIAN_RELEASE=trixie
SYSTEM_APT_THIRD_PARTY_DIRECTORY="$TMPDIR/sources.list.d"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="$TMPDIR/keyrings"
system_apt_is_deb822() { return 0; }
install() { mkdir -p "$TMPDIR/sources.list.d" "$TMPDIR/keyrings"; }
curl() { printf 'fake-key'; }
gpg() {
    touch "$TMPDIR/keyrings/nvidia-archive-keyring.gpg"
    touch "$TMPDIR/keyrings/nvidia-container-toolkit-archive-keyring.gpg"
}
system_apt_repository_engine 1 nvidia key deb / amd64 https://nvidia.example/ ""
system_apt_repository_engine 1 nvidia-container-toolkit key deb / amd64 https://nvidia.example/container/ ""
! grep -q '^Components:' "$TMPDIR/sources.list.d/nvidia.sources"
! grep -q '^Components:' "$TMPDIR/sources.list.d/nvidia-container-toolkit.sources"
'''
            result = subprocess.run(
                ["bash", "-c", script],
                env=dict(os.environ, ROOT=str(ROOT), TMPDIR=str(directory),
                          SYSTEM_APT_NVIDIA="1"),
                text=True,
                capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def run_repository(self, directory, modern, enable='1', failure=''):
        script = r'''
set -Eeuo pipefail
print_error() { printf '%s\n' "$*" >&2; }
source "$ROOT/modules/system/apt.sh"
SYSTEM_APT_THIRD_PARTY_DIRECTORY="$TMPDIR/sources.list.d"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="$TMPDIR/keyrings"
system_apt_is_deb822() { [[ "$TEST_MODERN" == 1 ]]; }
curl() {
    printf 'curl %s\n' "$*" >> "$TMPDIR/calls"
    [[ "$*" == '-fsSL https://docker.example/gpg' ]] || return 99
    if [[ "$TEST_FAILURE" == curl ]]; then
        printf 'curl: (60) simulated TLS certificate mismatch\n' >&2
        return 60
    fi
    printf 'synthetic-public-key'
}
gpg() {
    printf 'gpg %s\n' "$*" >> "$TMPDIR/calls"
    [[ "$1" == --dearmor && "$2" == --yes && "$3" == --output ]] || return 99
    local input
    input="$(cat)"
    [[ "$input" == synthetic-public-key ]] || return 99
    [[ "$TEST_FAILURE" != gpg ]] || return 1
    printf 'synthetic-keyring' > "$4"
}
system_apt_repository_engine "$TEST_ENABLE" docker https://docker.example/gpg \
    deb trixie amd64 https://docker.example/debian stable
'''
        return subprocess.run(
            ['bash', '-c', script], text=True, capture_output=True,
            env=dict(os.environ, ROOT=str(ROOT), TMPDIR=str(directory),
                     TEST_MODERN=str(int(modern)), TEST_ENABLE=enable,
                     TEST_FAILURE=failure),
        )

    def assert_repository_source(self, directory, modern):
        sources = directory / 'sources.list.d'
        keyring = directory / 'keyrings/docker-archive-keyring.gpg'
        if modern:
            self.assertEqual((sources / 'docker.sources').read_text(),
                             'Types: deb\nURIs: https://docker.example/debian\n'
                             'Suites: trixie\nArchitectures: amd64\n'
                             f'Components: stable\nSigned-By: {keyring}\n\n')
            self.assertFalse((sources / 'docker.list').exists())
        else:
            self.assertEqual((sources / 'docker.list').read_text(),
                             f'deb [arch=amd64 signed-by={keyring}] '
                             'https://docker.example/debian trixie stable\n')
            self.assertFalse((sources / 'docker.sources').exists())

    def test_existing_keyring_skips_download_even_with_tls_failure(self):
        for modern in (False, True):
            with self.subTest(modern=modern), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = Path(tmp)
                keyring = directory / 'keyrings/docker-archive-keyring.gpg'
                keyring.parent.mkdir()
                keyring.write_text('existing-synthetic-keyring')
                sources = directory / 'sources.list.d'
                sources.mkdir()
                alternate = 'docker.list' if modern else 'docker.sources'
                (sources / alternate).write_text('old-source')
                result = self.run_repository(directory, modern, failure='curl')
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')
                self.assertFalse((directory / 'calls').exists())
                self.assertEqual(keyring.read_text(), 'existing-synthetic-keyring')
                self.assert_repository_source(directory, modern)

    def test_missing_or_empty_keyring_downloads_once(self):
        for modern in (False, True):
            for empty in (False, True):
                with self.subTest(modern=modern, empty=empty), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                    directory = Path(tmp)
                    keyring = directory / 'keyrings/docker-archive-keyring.gpg'
                    if empty:
                        keyring.parent.mkdir()
                        keyring.touch()
                    result = self.run_repository(directory, modern)
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual(keyring.read_text(), 'synthetic-keyring')
                    self.assertEqual(keyring.stat().st_mode & 0o777, 0o644)
                    calls = (directory / 'calls').read_text().splitlines()
                    self.assertCountEqual(calls, [
                        'curl -fsSL https://docker.example/gpg',
                        f'gpg --dearmor --yes --output {keyring}',
                    ])
                    self.assert_repository_source(directory, modern)
                    result = self.run_repository(directory, modern, failure='curl')
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual((directory / 'calls').read_text().splitlines(), calls)
                    self.assertEqual(keyring.read_text(), 'synthetic-keyring')
                    self.assert_repository_source(directory, modern)

    @unittest.skipIf(os.geteuid() == 0, 'root peut lire un fichier sans permission de lecture')
    def test_unreadable_keyring_is_not_reused(self):
        for modern in (False, True):
            with self.subTest(modern=modern), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = Path(tmp)
                keyring = directory / 'keyrings/docker-archive-keyring.gpg'
                keyring.parent.mkdir()
                keyring.write_text('unreadable-synthetic-keyring')
                keyring.chmod(0o200)
                self.assertFalse(os.access(keyring, os.R_OK))
                result = self.run_repository(directory, modern)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(keyring.read_text(), 'synthetic-keyring')
                self.assertEqual(keyring.stat().st_mode & 0o777, 0o644)
                self.assertEqual(len((directory / 'calls').read_text().splitlines()), 2)
                self.assert_repository_source(directory, modern)

    def test_required_key_failure_preserves_existing_sources(self):
        for modern in (False, True):
            for failure in ('curl', 'gpg'):
                with self.subTest(modern=modern, failure=failure), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                    directory = Path(tmp)
                    sources = directory / 'sources.list.d'
                    sources.mkdir()
                    for name in ('docker.list', 'docker.sources'):
                        (sources / name).write_text('existing-source')
                    result = self.run_repository(directory, modern, failure=failure)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("Impossible d'installer la clé GPG du dépôt APT : docker",
                                  result.stderr)
                    for name in ('docker.list', 'docker.sources'):
                        self.assertEqual((sources / name).read_text(), 'existing-source')

    def test_disabled_repository_removes_managed_files_without_download(self):
        for modern in (False, True):
            with self.subTest(modern=modern), tempfile.TemporaryDirectory(dir=ROOT) as tmp:
                directory = Path(tmp)
                keyring = directory / 'keyrings/docker-archive-keyring.gpg'
                keyring.parent.mkdir()
                keyring.write_text('existing-synthetic-keyring')
                sources = directory / 'sources.list.d'
                sources.mkdir()
                for name in ('docker.list', 'docker.sources', 'unmanaged.list'):
                    (sources / name).write_text('existing-source')
                result = self.run_repository(directory, modern, enable='0', failure='curl')
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertFalse(keyring.exists())
                self.assertFalse((sources / 'docker.list').exists())
                self.assertFalse((sources / 'docker.sources').exists())
                self.assertEqual((sources / 'unmanaged.list').read_text(), 'existing-source')
                self.assertFalse((directory / 'calls').exists())


if __name__ == "__main__":
    unittest.main()
