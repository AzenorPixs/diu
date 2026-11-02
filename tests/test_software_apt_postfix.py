#!/usr/bin/env python3
"""Tests isolés de la déclaration Postfix par APT."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/softwares/software_apt_postfix.sh'


class SoftwareAptPostfixTests(unittest.TestCase):
    def run_case(self, body, initial=None, disabled=False):
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
                       TEST_CONFIG=str(target / 'config' / 'softwares.env'))
            env.pop('SOFTWARES_APT_POSTFIX', None)
            if initial is not None:
                env['SOFTWARES_APT_POSTFIX'] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + body],
                env=env, capture_output=True, text=True)

    def test_default_persistence_export_and_idempotence(self):
        result = self.run_case('''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == softwares ]]
[[ "$SOFTWARES_APT_POSTFIX" == 0 ]]
bash -c '[[ "$SOFTWARES_APT_POSTFIX" == 0 ]]'
[[ "$(cat "$TEST_CONFIG")" == 'export SOFTWARES_APT_POSTFIX=0' ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case('''expected="$SOFTWARES_APT_POSTFIX"
source "$TEST_SCRIPT"
[[ "$SOFTWARES_APT_POSTFIX" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_invalid_existing_value_is_rejected(self):
        result = self.run_case('''if source "$TEST_SCRIPT"; then exit 99; fi
[[ "$SOFTWARES_APT_POSTFIX" == invalid ]]
''', initial='invalid')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('invalide', result.stderr)

    def test_persistence_errors_do_not_export(self):
        result = self.run_case('''install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SOFTWARES_APT_POSTFIX+x}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_disabled_cleanup(self):
        result = self.run_case('''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export SOFTWARES_APT_POSTFIX=1' 'export SOFTWARES_APT_POSTFIX_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${SOFTWARES_APT_POSTFIX+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SOFTWARES_APT_POSTFIX_EXTRA=keep' ]]
''', initial='1', disabled=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_consumer_uses_new_name_with_disabled_fallback(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertEqual(source.count('if [[ "${SOFTWARES_APT_POSTFIX:-0}" -eq 1 ]]'), 1)
        self.assertNotRegex(source, r'\$(?:\{)?POSTFIX(?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
