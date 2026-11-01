#!/usr/bin/env python3
"""Tests isolés des six déclarations système FSTAB."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODULES = [
    ('SYSTEM_FSTAB', 'system_fstab.sh', '0'),
    ('SYSTEM_FSTAB_CONFIG1', 'system_fstab_config1.sh', 'NONE'),
    ('SYSTEM_FSTAB_CONFIG2', 'system_fstab_config2.sh', 'NONE'),
    ('SYSTEM_FSTAB_CONFIG3', 'system_fstab_config3.sh', 'NONE'),
    ('SYSTEM_FSTAB_CONFIG4', 'system_fstab_config4.sh', 'NONE'),
    ('SYSTEM_FSTAB_CONFIG5', 'system_fstab_config5.sh', 'NONE'),
]


class SystemFstabTests(unittest.TestCase):
    def run_case(self, variable, filename, default_value, body,
                 initial=None, disabled=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            source = ROOT / 'modules/diu/variables/system' / filename
            declaration = source.read_text()
            declaration = declaration.replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            if disabled:
                declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'config' / 'system.env'),
                       TEST_VARIABLE=variable, TEST_DEFAULT=default_value)
            env.pop(variable, None)
            if initial is not None:
                env[variable] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + body],
                env=env, capture_output=True, text=True)

    def test_static_declarations_persist_export_and_are_idempotent(self):
        for variable, filename, default_value in MODULES:
            with self.subTest(variable=variable):
                body = '''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == system ]]
[[ "${!TEST_VARIABLE}" == "$TEST_DEFAULT" ]]
bash -c '[[ "${!TEST_VARIABLE}" == "$TEST_DEFAULT" ]]'
[[ "$(cat "$TEST_CONFIG")" == "export $TEST_VARIABLE=$TEST_DEFAULT" ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
'''
                result = self.run_case(variable, filename, default_value, body)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_existing_values_are_preserved(self):
        for variable, filename, default_value in MODULES:
            values = ('0', '1', '') if variable == 'SYSTEM_FSTAB' else (
                'NONE', 'UUID=abc /data ext4 defaults 0 2', '')
            for value in values:
                with self.subTest(variable=variable, value=value):
                    result = self.run_case(
                        variable, filename, default_value,
                        '''expected="${!TEST_VARIABLE}"
source "$TEST_SCRIPT"
[[ "${!TEST_VARIABLE}" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual(result.stderr, '')

    def test_persistence_errors_do_not_export(self):
        for variable, filename, default_value in MODULES:
            with self.subTest(variable=variable):
                result = self.run_case(
                    variable, filename, default_value,
                    '''install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${!TEST_VARIABLE+x}" ]]
''')
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn('impossible', result.stderr)

    def test_disabled_state_removes_only_the_exact_persisted_variable(self):
        for variable, filename, default_value in MODULES:
            with self.subTest(variable=variable):
                body = '''mkdir -p "$(dirname "$TEST_CONFIG")"
printf 'export %s=custom\\nexport %s_EXTRA=keep\\n' "$TEST_VARIABLE" "$TEST_VARIABLE" > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${!TEST_VARIABLE+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == "export ${TEST_VARIABLE}_EXTRA=keep" ]]
'''
                result = self.run_case(variable, filename, default_value, body,
                                       initial='custom', disabled=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_entry_point_uses_only_the_new_names(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertEqual(source.count('if [[ "${SYSTEM_FSTAB:-0}" == "1" ]]'), 1)
        for index in range(1, 6):
            self.assertIn(f'SYSTEM_FSTAB_CONFIG{index}', source)
        self.assertNotRegex(source, r'\$(?:\{)?FSTAB(?:\})?(?![A-Z0-9_])')
        self.assertNotRegex(source, r'\$(?:\{)?FSTAB_CONFIG[1-5](?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
