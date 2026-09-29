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


if __name__ == "__main__":
    unittest.main()
