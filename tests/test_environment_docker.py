#!/usr/bin/env python3
"""Tests de la déclaration de provisionnement de l'environnement Docker."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'ENVIRONMENT_DOCKER'
SOURCE = ROOT / 'modules/diu/variables/environnements/environment_docker.sh'


class EnvironmentDockerTests(unittest.TestCase):
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
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nsource "$TEST_SCRIPT"\n' + body],
                env=dict(env, TEST_SCRIPT=str(script)), text=True, capture_output=True)

    def test_static_enabled_scope_and_default(self):
        result = self.run_case('''
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == environnements ]]
[[ "$ENVIRONMENT_DOCKER" == 0 ]]
[[ "$(cat "$TEST_CONFIG")" == 'export ENVIRONMENT_DOCKER=0' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case(f'[[ "$ENVIRONMENT_DOCKER" == {value} ]]', initial=value)
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
                         ENVIRONMENT_DOCKER='invalid'), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('valeur invalide', result.stderr)

    def test_root_installer_uses_new_flag_and_fallback(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertIn('if [ "${ENVIRONMENT_DOCKER:-0}" -eq 1 ]', source)
        self.assertNotIn('if [ "$ENV_DOCKER" -eq 1 ]', source)


if __name__ == '__main__':
    unittest.main()
