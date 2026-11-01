#!/usr/bin/env python3
"""Tests isolés de la déclaration du réglage FILES2RAM système."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/system/system_files2ram.sh'


class SystemFiles2RamTests(unittest.TestCase):
    def run_case(self, body, initial=None, disabled=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text()
            declaration = declaration.replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            if disabled:
                declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'config' / 'system.env'))
            env.pop('SYSTEM_FILES2RAM', None)
            if initial is not None:
                env['SYSTEM_FILES2RAM'] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + body],
                env=env, capture_output=True, text=True)

    def test_default_persistence_export_and_idempotence(self):
        result = self.run_case('''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == system ]]
[[ "$SYSTEM_FILES2RAM" == 0 ]]
bash -c '[[ "$SYSTEM_FILES2RAM" == 0 ]]'
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_FILES2RAM=0' ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_values_are_preserved(self):
        for value in ('0', '1', ''):
            with self.subTest(value=value):
                result = self.run_case('''expected="$SYSTEM_FILES2RAM"
source "$TEST_SCRIPT"
[[ "$SYSTEM_FILES2RAM" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_persistence_errors_do_not_export(self):
        result = self.run_case('''install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_FILES2RAM+x}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_disabled_cleanup(self):
        result = self.run_case('''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export SYSTEM_FILES2RAM=1' 'export SYSTEM_FILES2RAM_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${SYSTEM_FILES2RAM+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_FILES2RAM_EXTRA=keep' ]]
''', initial='1', disabled=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_consumer_uses_new_name_with_disabled_fallback(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertEqual(source.count('if [[ "${SYSTEM_FILES2RAM:-0}" == "1" ]]'), 1)
        self.assertNotRegex(source, r'\$(?:\{)?FILES2RAM(?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
