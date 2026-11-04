"""DisplayLink CLI tests: all privileged operations are replaced by stateful mocks."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / 'modules/system/drivers.sh'

MOCKS = r'''
set -uo pipefail
source "$ROOT/modules/system/drivers.sh"
source "$ROOT/modules/system/apt.sh"
print_error() { printf '%s\n' "$*" >&2; }
record() { printf '%s\n' "$*" >> "$CALLS"; }
mock_installed=${INITIAL_INSTALLED:-1}
mock_loaded=${INITIAL_LOADED:-1}
mock_current=${INITIAL_CURRENT:-1}
mock_active=${INITIAL_ACTIVE:-1}
mock_built=${INITIAL_BUILT:-1}
mock_headers=${INITIAL_HEADERS:-1}
mock_version=${INITIAL_VERSION:-1.15.1+dfsg-1}
SYSTEM_DRIVERS_DISPLAY_LINK=UNSET
SYSTEM_DEBIAN_ENVIRONNEMENT=${FAMILY-PHYSICAL}
uname() { printf '%s\n' "${KERNEL:-7.0.12+deb13-amd64}"; }
dpkg-query() {
    if [[ "$*" == *'${Version}'* ]]; then printf '%s' "$mock_version"; return; fi
    if [[ "${FAIL:-}" == discovery ]]; then return 2; fi
    if [[ "$mock_installed" == 1 ]]; then printf installed; else return 1; fi
}
apt-cache() {
    record "CANDIDATE ${*: -1}"
    printf '  Candidate: %s\n' "${CANDIDATE:-1.14.8+dfsg-1}"
}
apt-get() {
    record "APT $*"
    [[ "${FAIL:-}" != apt ]] || return 1
    if [[ "$1" == --simulate ]]; then
        printf 'Remv displaylink-driver [6.1-2]\nRemv evdi-dkms [1.15.1]\n'
        [[ "${FAIL:-}" != extra_remove ]] || printf 'Remv unrelated [1]\n'
    elif [[ "$1" == install ]]; then
        [[ "${FAIL:-}" == final_package ]] || mock_installed=1
        if [[ "$*" == *evdi-dkms=* ]]; then mock_version=${CANDIDATE}; fi
        if [[ "$*" == *.deb* ]]; then mock_version=1.15.1+dfsg-1; fi
        [[ "${FAIL:-}" == final_headers ]] || mock_headers=1
    elif [[ "$1" == remove ]]; then
        [[ "${FAIL:-}" == remaining_package ]] || mock_installed=0
    else
        return 99
    fi
}
system_drivers_headers_ready() { [[ "$mock_headers" == 1 ]]; }
system_drivers_library_ready() { [[ "${FAIL:-}" != library ]]; }
system_drivers_module_loaded() { [[ "$mock_loaded" == 1 ]]; }
system_drivers_module_current() { [[ "$mock_current" == 1 ]]; }
system_drivers_download_evdi() { record "DOWNLOAD $1"; [[ "${FAIL:-}" != download ]]; }
dkms() {
    record "DKMS $*"
    if [[ "$1" == status ]]; then
        [[ "$mock_built" != 1 ]] || printf 'evdi/1.15.1+dfsg, kernel, x86_64: installed\n'
    else
        [[ "${FAIL:-}" != dkms ]] || return 1
        [[ "${FAIL:-}" == final_dkms ]] || mock_built=1
    fi
}
modprobe() {
    record "MODULE $*"
    [[ "${FAIL:-}" != module ]] || return 1
    if [[ "$1" == -r ]]; then mock_loaded=0; else mock_loaded=1; [[ "${FAIL:-}" == final_module ]] || mock_current=1; fi
}
systemctl() {
    record "SERVICE $*"
    case "$1" in
        show) printf '%s\n' "${LOAD_STATE:-loaded}" ;;
        stop) [[ "${FAIL:-}" != stop ]] || return 1; mock_active=0 ;;
        enable) [[ "${FAIL:-}" != service ]] || return 1; mock_active=1 ;;
        is-active) [[ "${FAIL:-}" != service_query ]] || return 1; [[ "$mock_active" == 1 ]] || return 3 ;;
        *) return 99 ;;
    esac
}
# Keep the real atomic writer, redirect only its destination.
eval "$(declare -f system_drivers_persist_state | sed '1s/system_drivers_persist_state/test_persist_state/')"
system_drivers_persist_state() {
    [[ "${FAIL:-}" != persist ]] || return 1
    test_persist_state "$1" "$CONFIG"
}
if manage_system_action ${ACTION:-drivers install displaylink}; then result=0; else result=$?; fi
if [[ "$result" == 0 && "${REPEAT:-0}" == 1 ]]; then
    if manage_system_action ${ACTION:-drivers install displaylink}; then result=0; else result=$?; fi
fi
printf 'RESULT=%s STATE=%s\n' "$result" "$SYSTEM_DRIVERS_DISPLAY_LINK"
exit "$result"
'''


class DriversTests(unittest.TestCase):
    def run_driver(self, **settings):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            tmp = Path(tmp)
            config = tmp / 'system.conf'
            config.write_text('export OTHER=kept\nexport SYSTEM_DRIVERS_DISPLAY_LINK=UNSET\n')
            calls = tmp / 'calls'
            calls.touch()
            env = dict(os.environ, ROOT=str(ROOT), CALLS=str(calls), CONFIG=str(config), TMPDIR=str(tmp))
            env.update(settings)
            result = subprocess.run(['bash', '-c', MOCKS], env=env, text=True, capture_output=True)
            return result, calls.read_text(), config.read_text()

    def assert_failed(self, result, config):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn('STATE=UNSET', result.stdout)
        self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK=UNSET', config)

    def test_healthy_idempotent(self):
        for family in ('PHYSICAL', 'PROXMOX'):
            with self.subTest(family=family):
                result, calls, config = self.run_driver(FAMILY=family)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn('APT ', calls)
                self.assertNotIn('MODULE ', calls)
                self.assertNotIn('SERVICE stop', calls)
                self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK=1', config)
                self.assertIn('OTHER=kept', config)

    def test_disallowed_environments(self):
        for family in ('VM', 'LXC', 'DOCKER', 'UNSET', '', 'unknown'):
            result, calls, config = self.run_driver(FAMILY=family)
            self.assert_failed(result, config)
            self.assertEqual(calls, '')

    def test_fallback_kernel7_old_evdi(self):
        result, calls, config = self.run_driver(INITIAL_VERSION='1.14.8+dfsg-1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('DOWNLOAD ', calls)
        self.assertIn('APT install -y --no-remove -- dkms displaylink-driver libevdi-dev ', calls)
        self.assertIn('evdi-dkms_1.15.1+dfsg-1_all.deb', calls)
        self.assertEqual(calls.count('APT install'), 1)
        self.assertIn('MODULE -r evdi', calls)
        self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK=1', config)

    def test_recent_candidate(self):
        result, calls, _ = self.run_driver(INITIAL_VERSION='1.14.8+dfsg-1', CANDIDATE='1.16.0-1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('DOWNLOAD', calls)
        self.assertIn('evdi-dkms=1.16.0-1', calls)

    def test_kernel6_no_fallback(self):
        result, calls, _ = self.run_driver(KERNEL='6.12.94+deb13-amd64', INITIAL_VERSION='1.14.8+dfsg-1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('DOWNLOAD', calls)
        self.assertNotIn('APT ', calls)

    def test_missing_headers_debian_and_proxmox(self):
        for kernel, header in [('7.0.12+deb13-amd64', 'linux-headers-7.0.12+deb13-amd64'),
                               ('7.0.12-1-pve', 'proxmox-headers-7.0.12-1-pve')]:
            result, calls, _ = self.run_driver(KERNEL=kernel, INITIAL_HEADERS='0')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(header, calls)

    def test_missing_headers_candidate(self):
        result, calls, config = self.run_driver(INITIAL_HEADERS='0', CANDIDATE='(none)')
        self.assert_failed(result, config)
        self.assertNotIn('APT ', calls)

    def test_build_missing_module(self):
        result, calls, _ = self.run_driver(INITIAL_BUILT='0', INITIAL_LOADED='0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('DKMS install -m evdi -v 1.15.1+dfsg -k 7.0.12+deb13-amd64', calls)
        self.assertIn('MODULE evdi', calls)

    def test_old_loaded_module(self):
        result, calls, _ = self.run_driver(INITIAL_CURRENT='0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('SERVICE stop', calls)
        self.assertIn('MODULE -r evdi', calls)
        self.assertIn('MODULE evdi', calls)

    def test_failures_preserve_state(self):
        variants = {
            'discovery': {}, 'download': {'INITIAL_VERSION': '1.14.8+dfsg-1'},
            'apt': {'INITIAL_INSTALLED': '0'}, 'final_package': {'INITIAL_INSTALLED': '0'},
            'dkms': {'INITIAL_BUILT': '0'}, 'module': {'INITIAL_LOADED': '0'},
            'stop': {'INITIAL_CURRENT': '0'}, 'library': {}, 'service': {}, 'persist': {},
            'final_headers': {'INITIAL_HEADERS': '0'}, 'final_dkms': {'INITIAL_BUILT': '0'},
            'final_module': {'INITIAL_CURRENT': '0'},
        }
        for failure, settings in variants.items():
            with self.subTest(failure=failure):
                result, calls, config = self.run_driver(FAIL=failure, **settings)
                self.assert_failed(result, config)
                if failure == 'download':
                    self.assertNotIn('APT ', calls)

    def test_remove_all_environments(self):
        for family in ('PHYSICAL', 'PROXMOX', 'VM', 'LXC', 'DOCKER', 'UNSET'):
            result, calls, config = self.run_driver(ACTION='drivers remove displaylink', FAMILY=family)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('APT remove -y --no-auto-remove -- displaylink-driver evdi-dkms', calls)
            self.assertIn('MODULE -r evdi', calls)
            self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK=0', config)

    def test_remove_absent(self):
        result, calls, config = self.run_driver(ACTION='drivers remove displaylink', INITIAL_INSTALLED='0',
                                               INITIAL_LOADED='0', INITIAL_ACTIVE='0', LOAD_STATE='not-found')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('APT ', calls)
        self.assertNotIn('MODULE ', calls)
        self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK=0', config)

    def test_remove_failures(self):
        for failure in ('discovery', 'apt', 'module', 'stop', 'remaining_package', 'persist', 'extra_remove', 'service_query'):
            result, calls, config = self.run_driver(ACTION='drivers remove displaylink', FAIL=failure)
            self.assert_failed(result, config)
            if failure == 'extra_remove':
                self.assertNotIn('APT remove', calls)

    def test_route_errors(self):
        for action in ('drivers', 'drivers install', 'drivers remove', 'drivers bad displaylink',
                       'drivers install other', 'drivers install displaylink extra'):
            result, calls, config = self.run_driver(ACTION=action)
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertEqual(calls, '')
            self.assertIn('UNSET', config)

    def test_help_before_bootstrap(self):
        for prefix in ([], ['system'], ['system', 'drivers'], ['system', 'drivers', 'install'],
                       ['system', 'drivers', 'remove'], ['system', 'drivers', 'install', 'displaylink'],
                       ['system', 'drivers', 'remove', 'displaylink']):
            result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *prefix, 'help'],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('displaylink', result.stdout)

    def test_repeated_install_and_remove(self):
        result, calls, _ = self.run_driver(INITIAL_INSTALLED='0', INITIAL_LOADED='0', REPEAT='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls.count('APT install'), 1)
        result, calls, _ = self.run_driver(ACTION='drivers remove displaylink', REPEAT='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls.count('APT remove'), 1)

    def test_invalid_help(self):
        for arguments in [('system', 'drivers', 'bad'), ('system', 'drivers', 'install', 'other'),
                          ('system', 'drivers', 'remove', 'displaylink', 'extra')]:
            result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *arguments, 'help'],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 2)

    def test_real_package_state(self):
        for value, status, expected in [('installed', 0, 0), ('config-files', 0, 1),
                                         ('unpacked', 0, 2), ('', 1, 1), ('', 2, 3), ('weird', 0, 3)]:
            code = f'''source "{MODULE}"
dpkg-query() {{ printf '%s' '{value}'; return {status}; }}
system_drivers_package_state evdi-dkms
'''
            result = subprocess.run(['bash', '-c', code], capture_output=True)
            self.assertEqual(result.returncode, expected)

    def test_persistence_duplicates_and_failure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            target = Path(tmp) / 'system.conf'
            target.write_text('KEEP=x\n SYSTEM_DRIVERS_DISPLAY_LINK=0\nexport SYSTEM_DRIVERS_DISPLAY_LINK=UNSET\n')
            script = f'''source "{MODULE}"
SYSTEM_DRIVERS_DISPLAY_LINK=UNSET
system_drivers_persist_state 1 "{target}" || exit 1
system_drivers_persist_state 1 "{target}" || exit 2
printf '%s' "$SYSTEM_DRIVERS_DISPLAY_LINK"
'''
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, '1')
            self.assertEqual(target.read_text().count('SYSTEM_DRIVERS_DISPLAY_LINK='), 1)
            self.assertIn('KEEP=x', target.read_text())
            before = target.read_text()
            failure = f'''source "{MODULE}"
SYSTEM_DRIVERS_DISPLAY_LINK=UNSET
mv() {{ return 1; }}
if system_drivers_persist_state 0 "{target}"; then exit 99; fi
printf '%s' "$SYSTEM_DRIVERS_DISPLAY_LINK"
'''
            result = subprocess.run(['bash', '-c', failure], text=True, capture_output=True)
            self.assertEqual(result.stdout, 'UNSET')
            self.assertEqual(target.read_text(), before)

    def test_download_real_verification_without_network(self):
        artifact = ROOT / '.evdi-validation/evdi-dkms_1.15.1+dfsg-1_all.deb'
        if not artifact.is_file():
            self.skipTest('Paquet de validation local absent')
        with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
            target = Path(tmp) / 'evdi.deb'
            script = f'''source "{MODULE}"
curl() {{ cp "{artifact}" "{target}"; }}
system_drivers_download_evdi "{target}"
'''
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            script = f'''source "{MODULE}"
curl() {{ printf corrupt > "{target}"; }}
system_drivers_download_evdi "{target}"
'''
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True)
            self.assertNotEqual(result.returncode, 0)


if __name__ == '__main__':
    unittest.main()
