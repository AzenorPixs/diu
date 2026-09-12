#!/usr/bin/env python3
"""Tests isolés du moteur Flatpak du module softwares."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PRELUDE = r'''
set -Eeuo pipefail
print_error() { printf 'ERROR %s\n' "$*"; }
print_info() { printf 'INFO %s\n' "$*"; }
print_success() { printf 'OK %s\n' "$*"; }
print_title() { printf '%s\n' "$*"; }
source "$ROOT/modules/softwares/flatpak.sh"
source "$ROOT/modules/softwares/apt.sh"
source "$ROOT/modules/diu/update-all.sh"
flatpak() {
    printf 'flatpak %s\n' "$*" >> "$CALLS"
    case "$1" in
        remotes)
            [[ "${FLATHUB_PRESENT:-1}" == 1 ]] && printf 'flathub\n'
            ;;
        info)
            [[ "${APPLICATION_INSTALLED:-0}" == 1 ]]
            ;;
        list)
            [[ "${APPLICATION_PRESENT:-1}" == 1 ]] && printf 'org.example.App\n'
            ;;
        install|uninstall|update)
            return "${FLATPAK_FAILURE:-0}"
            ;;
    esac
}
'''

class SoftwareFlatpakTests(unittest.TestCase):
    def run_shell(self, script, **variables):
        with tempfile.TemporaryDirectory(prefix='.software-flatpak-test-', dir=ROOT) as directory:
            env = dict(os.environ, ROOT=str(ROOT), TMPDIR=directory,
                       CALLS=f'{directory}/calls', **variables)
            result = subprocess.run(['bash', '-c', PRELUDE + '\n' + script],
                                    env=env, text=True, capture_output=True)
            calls_path = Path(env['CALLS'])
            calls = calls_path.read_text() if calls_path.exists() else ''
            return result, calls

    def test_install_requires_flatpak_client(self):
        result, calls = self.run_shell(r'''
command() {
    if [[ "$1" == -v && "$2" == flatpak ]]; then
        return 1
    fi
    builtin command "$@"
}
software_flatpak_action install org.example.App
''')
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn('rid system install flatpak', result.stdout)
        self.assertEqual(calls, '')

    def test_install_requires_flathub_without_creating_it(self):
        result, calls = self.run_shell(
            'software_flatpak_action install org.example.App', FLATHUB_PRESENT='0')
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn('remote Flathub est absent', result.stdout)
        self.assertEqual(calls.splitlines(), ['flatpak remotes --system --columns=name'])

    def test_install_and_remove_are_targeted(self):
        result, calls = self.run_shell(
            'software_flatpak_action install org.example.App', APPLICATION_INSTALLED='0')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('flatpak install --system --noninteractive flathub -- org.example.App', calls)

        result, calls = self.run_shell(
            'software_flatpak_action remove org.example.App', APPLICATION_INSTALLED='1')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('flatpak uninstall --system --noninteractive -- org.example.App', calls)

    def test_repeated_operations_do_not_mutate(self):
        result, calls = self.run_shell(
            'software_flatpak_action install org.example.App', APPLICATION_INSTALLED='1')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('flatpak install', calls)

        result, calls = self.run_shell(
            'software_flatpak_action remove org.example.App', APPLICATION_INSTALLED='0')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('flatpak uninstall', calls)

    def test_invalid_input_and_extra_argument_do_not_call_flatpak(self):
        for command in (
            'software_flatpak_action install',
            'software_flatpak_action install --bad',
            'manage_softwares_action install flatpak org.example.App extra',
            'manage_softwares_action flatpak update extra',
        ):
            with self.subTest(command=command):
                result, calls = self.run_shell(command)
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertEqual(calls, '')

    def test_update_does_not_install_or_remove_applications(self):
        result, calls = self.run_shell('manage_softwares_action flatpak update')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), [
            'flatpak remotes --system --columns=name',
            'flatpak list --system --app --columns=application',
            'flatpak update --system --noninteractive',
        ])

    def test_update_without_application_is_a_noop(self):
        result, calls = self.run_shell(
            'software_flatpak_update_all', APPLICATION_PRESENT='0')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('aucune application installée', result.stdout)
        self.assertNotIn('flatpak update', calls)

    def test_update_failure_propagates(self):
        result, calls = self.run_shell(
            'software_flatpak_update_all', FLATPAK_FAILURE='1')
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn('flatpak update --system --noninteractive', calls)

    def test_softwares_update_and_universal_update_call_flatpak_once(self):
        result, calls = self.run_shell(r'''
software_apt_update_all() { :; }
software_github_update_all() { :; }
manage_softwares_action update
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.count('flatpak update --system --noninteractive'), 1)

        result, calls = self.run_shell(r'''
software_apt_update_all() { :; }
software_github_update_all() { :; }
update_diu() { :; }
update_all
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.count('flatpak update --system --noninteractive'), 1)


if __name__ == '__main__':
    unittest.main()
