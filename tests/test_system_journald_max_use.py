#!/usr/bin/env python3
"""Tests isolés de la limite de taille du journal système."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/system/system_journald_max_use.sh'


class SystemJournaldMaxUseTests(unittest.TestCase):
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
                       TEST_CONFIG=str(target / 'config' / 'system.env'))
            env.pop('SYSTEM_JOURNALD_MAX_USE', None)
            if initial is not None:
                env['SYSTEM_JOURNALD_MAX_USE'] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + body],
                env=env, capture_output=True, text=True)

    def test_default_persistence_export_and_idempotence(self):
        result = self.run_case('''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == system ]]
[[ "$SYSTEM_JOURNALD_MAX_USE" == 500M ]]
bash -c '[[ "$SYSTEM_JOURNALD_MAX_USE" == 500M ]]'
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_JOURNALD_MAX_USE=500M' ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_valid_sizes_are_preserved(self):
        for value in ('100M', '1G', '4096'):
            with self.subTest(value=value):
                result = self.run_case('''expected="$SYSTEM_JOURNALD_MAX_USE"
source "$TEST_SCRIPT"
[[ "$SYSTEM_JOURNALD_MAX_USE" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_invalid_existing_value_is_rejected_without_execution(self):
        result = self.run_case('''if source "$TEST_SCRIPT"; then exit 99; fi
[[ "$SYSTEM_JOURNALD_MAX_USE" == '$(touch ${TEST_CONFIG}.executed)' ]]
[[ ! -e "${TEST_CONFIG}.executed" ]]
''', initial='$(touch ${TEST_CONFIG}.executed)')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('invalide', result.stderr)

    def test_persistence_errors_do_not_export(self):
        result = self.run_case('''install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_JOURNALD_MAX_USE+x}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_disabled_cleanup(self):
        result = self.run_case('''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export SYSTEM_JOURNALD_MAX_USE=1G' 'export SYSTEM_JOURNALD_MAX_USE_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${SYSTEM_JOURNALD_MAX_USE+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_JOURNALD_MAX_USE_EXTRA=keep' ]]
''', initial='1G', disabled=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_consumers_use_new_name_for_both_journald_limits(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertIn('SystemMaxUse=${SYSTEM_JOURNALD_MAX_USE}', source)
        self.assertIn('RuntimeMaxUse=${SYSTEM_JOURNALD_MAX_USE}', source)
        self.assertNotRegex(source, r'\$(?:\{)?JOURNALD_MAX_USE(?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
