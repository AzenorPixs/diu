#!/usr/bin/env python3
"""Détection et persistance DisplayLink isolées de la configuration réelle."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = ROOT / 'modules/diu/variables/system/system_drivers_display_link.sh'
VARIABLE = 'SYSTEM_DRIVERS_DISPLAY_LINK'


class DisplayLinkDeclarationTests(unittest.TestCase):
    def run_declaration(self, driver='installed', driver_rc=0, evdi='installed',
                        evdi_rc=0, prelude='', after='', disabled=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            directory = Path(directory)
            config = directory / 'system.env'
            source = directory / 'declaration.sh'
            text = DECLARATION.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$CONFIG"')
            if disabled:
                text = text.replace('state="ENABLE"', 'state="DISABLE"')
            source.write_text(text)
            env = dict(os.environ, DECLARATION=str(source), CONFIG=str(config),
                       CALLS=str(directory / 'calls'), DRIVER=driver, EVDI=evdi,
                       DRIVER_RC=str(driver_rc), EVDI_RC=str(evdi_rc))
            env.pop(VARIABLE, None)
            script = r'''
set -Eeuo pipefail
dpkg-query() {
    [[ "$1" == -W && "$2" == '-f=${db:Status-Status}' && $# -eq 3 ]] || return 99
    printf '%s\n' "$3" >> "$CALLS"
    case "$3" in
        displaylink-driver) printf '%s' "$DRIVER"; return "$DRIVER_RC" ;;
        evdi-dkms) printf '%s' "$EVDI"; return "$EVDI_RC" ;;
        *) return 99 ;;
    esac
}
''' + prelude + '\nsource "$DECLARATION"\n' + after
            result = subprocess.run(['bash', '-c', script], env=env,
                                    text=True, capture_output=True)
            content = config.read_text() if config.is_file() else None
            calls = (directory / 'calls').read_text() if (directory / 'calls').exists() else ''
            return result, content, calls

    def assert_detected(self, expected, **kwargs):
        result, content, _ = self.run_declaration(after=r'''
[[ "$config" == STATIC && "$scope" == system && "$state" == ENABLE ]]
bash -c 'printf "%s\n" "$SYSTEM_DRIVERS_DISPLAY_LINK"'
''', **kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, expected + '\n')
        self.assertEqual(content, f'export {VARIABLE}={expected}\n')
        if expected == 'UNSET':
            self.assertIn(VARIABLE, result.stderr)
        else:
            self.assertEqual(result.stderr, '')

    def test_installed_absent_and_partial(self):
        self.assert_detected('1')
        for package in ('driver', 'evdi'):
            self.assert_detected('0', **{package: '', package + '_rc': 1})
            for state in ('not-installed', 'config-files', 'unpacked', 'half-installed',
                          'half-configured', 'triggers-awaited', 'triggers-pending'):
                with self.subTest(package=package, state=state):
                    self.assert_detected('0', **{package: state})
        self.assert_detected('0', driver='', driver_rc=1, evdi='', evdi_rc=1)

    def test_errors_and_incoherent_results(self):
        for package in ('driver', 'evdi'):
            for state, rc in (('', 2), ('installed', 1), ('', 0), ('unknown', 0), ('installed\ninstalled', 0)):
                with self.subTest(package=package, state=state, rc=rc):
                    self.assert_detected('UNSET', **{package: state, package + '_rc': rc})
        self.assert_detected('UNSET', driver='', driver_rc=1, evdi='', evdi_rc=2)
        self.assert_detected('UNSET', driver='', driver_rc=2, evdi='', evdi_rc=1)

    def test_missing_tool(self):
        self.assert_detected('UNSET', prelude=r'''
command() {
    if [[ "$1" == -v && "$2" == dpkg-query ]]; then return 1; fi
    builtin command "$@"
}
''')

    def test_existing_values_exported_without_detection(self):
        for value in ('0', '1', 'UNSET'):
            result, content, calls = self.run_declaration(
                prelude=f'{VARIABLE}={value}',
                after='bash -c \'printf "%s\\n" "$SYSTEM_DRIVERS_DISPLAY_LINK"\'')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, value + '\n')
            self.assertIsNone(content)
            self.assertEqual(calls, '')

    def test_invalid_values_do_not_write_or_detect(self):
        for value in ('', '2', 'invalid'):
            result, content, calls = self.run_declaration(prelude=f"{VARIABLE}='{value}'")
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('valeur invalide', result.stderr)
            self.assertIsNone(content)
            self.assertEqual(calls, '')

    def test_repeated_load_and_persistent_reload(self):
        result, content, calls = self.run_declaration(after=r'''
source "$DECLARATION"
unset SYSTEM_DRIVERS_DISPLAY_LINK
source "$CONFIG"
dpkg-query() { printf 'unexpected query\n' >&2; return 99; }
source "$DECLARATION"
[[ "$SYSTEM_DRIVERS_DISPLAY_LINK" == 1 ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(content, f'export {VARIABLE}=1\n')
        self.assertEqual(calls.splitlines(), ['displaylink-driver', 'evdi-dkms'])

    def test_persistence_errors(self):
        for prelude in ('install() { return 1; }', 'mkdir "$CONFIG"'):
            result, content, _ = self.run_declaration(prelude=prelude + r'''
if source "$DECLARATION"; then exit 99; fi
[[ -z "${SYSTEM_DRIVERS_DISPLAY_LINK+x}" ]] || exit 98
exit 0
''')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(VARIABLE, result.stderr)
            self.assertIsNone(content)

    def test_disabled_removes_only_exact_declaration(self):
        result, content, calls = self.run_declaration(disabled=True, prelude=r'''
export SYSTEM_DRIVERS_DISPLAY_LINK=1
printf 'export SYSTEM_DRIVERS_DISPLAY_LINK=1\nOTHER=keep\n' > "$CONFIG"
''', after='[[ -z "${SYSTEM_DRIVERS_DISPLAY_LINK+x}" ]]')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(content, 'OTHER=keep\n')
        self.assertEqual(calls, '')


if __name__ == '__main__':
    unittest.main()
