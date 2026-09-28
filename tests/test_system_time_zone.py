#!/usr/bin/env python3
"""Déclaration statique du fuseau, sans accès à la configuration réelle."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/system/system_time_zone.sh'


class SystemTimeZoneTests(unittest.TestCase):
    def run_case(self, stub, body, initial=None, disabled=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            if disabled:
                declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'config' / 'system.env'))
            env.pop('SYSTEM_TIME_ZONE', None)
            if initial is not None:
                env['SYSTEM_TIME_ZONE'] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + stub + '\n' + body],
                env=env, capture_output=True, text=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_detection_persistence_export_and_idempotence(self):
        r = self.run_case('''timedatectl() {
    [[ "$*" == 'show --property=Timezone --value' ]] || return 99
    printf '%s\\n' Europe/London
}''', '''source "$TEST_SCRIPT"
[[ "$SYSTEM_TIME_ZONE" == Europe/London ]]
bash -c '[[ "$SYSTEM_TIME_ZONE" == Europe/London ]]'
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_TIME_ZONE=Europe/London' ]]
timedatectl() { echo UNEXPECTED >&2; return 99; }
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
unset SYSTEM_TIME_ZONE
source "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ "$SYSTEM_TIME_ZONE" == Europe/London ]]
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
''')
        self.assert_success(r)
        self.assertEqual(r.stderr, '')

    def test_fallback(self):
        for stub in ('return 1', 'return 0', "printf 'UTC'; return 1"):
            with self.subTest(stub=stub):
                r = self.run_case('timedatectl() { ' + stub + '; }', '''source "$TEST_SCRIPT"
[[ "$SYSTEM_TIME_ZONE" == Europe/Paris ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_TIME_ZONE=Europe/Paris' ]]
''')
                self.assert_success(r)
                self.assertIn('repli sur Europe/Paris', r.stderr)

    def test_missing_command(self):
        r = self.run_case('', '''SYSTEM_TIME_ZONE=existing
source "$TEST_SCRIPT"
unset SYSTEM_TIME_ZONE
PATH=/nonexistent
value="$(variable_generator)"
[[ "$value" == Europe/Paris ]]
''')
        self.assert_success(r)
        self.assertIn('repli sur Europe/Paris', r.stderr)

    def test_existing_values_preserved(self):
        for value in ('UTC', ''):
            with self.subTest(value=value):
                r = self.run_case('timedatectl() { echo UNEXPECTED >&2; return 99; }', '''expected="$SYSTEM_TIME_ZONE"
source "$TEST_SCRIPT"
[[ "$SYSTEM_TIME_ZONE" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                self.assert_success(r)
                self.assertEqual(r.stderr, '')

    def test_persistence_errors_do_not_export(self):
        for preparation in ('install() { return 1; }', 'mkdir -p "$TEST_CONFIG"'):
            with self.subTest(preparation=preparation):
                r = self.run_case('timedatectl() { printf UTC; }', preparation + '''
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_TIME_ZONE+x}" ]]
''')
                self.assert_success(r)
                self.assertIn('impossible', r.stderr)

    def test_shell_escaping(self):
        r = self.run_case('timedatectl() { printf \'%s\' \'Zone with spaces; $(false)\'; }', '''source "$TEST_SCRIPT"
expected="$SYSTEM_TIME_ZONE"
unset SYSTEM_TIME_ZONE
source "$TEST_CONFIG"
[[ "$SYSTEM_TIME_ZONE" == "$expected" ]]
''')
        self.assert_success(r)

    def test_disabled_cleanup(self):
        r = self.run_case('timedatectl() { echo UNEXPECTED >&2; return 99; }', '''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export SYSTEM_TIME_ZONE=UTC' 'export SYSTEM_TIME_ZONE_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${SYSTEM_TIME_ZONE+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_TIME_ZONE_EXTRA=keep' ]]
source "$TEST_SCRIPT"
''', initial='UTC', disabled=True)
        self.assert_success(r)
        self.assertEqual(r.stderr, '')


if __name__ == '__main__':
    unittest.main()
