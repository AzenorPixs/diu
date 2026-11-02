#!/usr/bin/env python3
"""Tests de la déclaration de l'activation de l'environnement DevOps."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'ENVIRONMENTS_DEVOPS'
SOURCE = ROOT / 'modules/diu/variables/environnements/env_devops.sh'


class EnvironmentDevopsTests(unittest.TestCase):
    def run_case(self, body, initial=None):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            module = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            script.write_text(module)
            env = dict(os.environ, TEST_CONFIG=str(Path(directory) / 'environnements.env'))
            if initial is not None:
                env[VARIABLE] = initial
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nsource "$TEST_SCRIPT"\n' + body],
                env=dict(env, TEST_SCRIPT=str(script)), text=True, capture_output=True)
            return result

    def test_static_enabled_scope_and_default(self):
        result = self.run_case('''
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == environnements ]]
[[ "$ENVIRONMENTS_DEVOPS" == 0 ]]
[[ "$(cat "$TEST_CONFIG")" == 'export ENVIRONMENTS_DEVOPS=0' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case(f'[[ "$ENVIRONMENTS_DEVOPS" == {value} ]]', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_invalid_value_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            script.write_text(SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"'))
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nif source "$TEST_SCRIPT"; then exit 99; fi'],
                env=dict(os.environ, TEST_SCRIPT=str(script),
                         TEST_CONFIG=str(Path(directory) / 'environnements.env'),
                         ENVIRONMENTS_DEVOPS='invalid'), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('valeur invalide', result.stderr)

    def test_root_installer_uses_the_new_variable(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertIn('if [ "${ENVIRONMENTS_DEVOPS:-0}" -eq 1 ]', source)
        self.assertNotIn('if [ "$ENV_DEVOPS" -eq 1 ]', source)


if __name__ == '__main__':
    unittest.main()
