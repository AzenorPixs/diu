#!/usr/bin/env python3
"""Tests de la déclaration du compte propriétaire des stacks Docker."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'ENVIRONMENT_DOCKER_USER'
SOURCE = ROOT / 'modules/diu/variables/docker/docker_user.sh'


class DockerUserEnvironmentTests(unittest.TestCase):
    def run_case(self, body, initial=None):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            module = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            script.write_text(module)
            env = dict(os.environ, TEST_CONFIG=str(Path(directory) / 'docker.env'))
            if initial is not None:
                env[VARIABLE] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nsource "$TEST_SCRIPT"\n' + body],
                env=dict(env, TEST_SCRIPT=str(script)), text=True, capture_output=True)

    def test_static_enabled_docker_scope_and_default(self):
        result = self.run_case('''
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == docker ]]
[[ "$ENVIRONMENT_DOCKER_USER" == docker ]]
[[ "$(cat "$TEST_CONFIG")" == 'export ENVIRONMENT_DOCKER_USER=docker' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_username_is_preserved(self):
        result = self.run_case('[[ "$ENVIRONMENT_DOCKER_USER" == dock_user1 ]]',
                               initial='dock_user1')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_invalid_username_is_rejected_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            script.write_text(SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"'))
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nif source "$TEST_SCRIPT"; then exit 99; fi'],
                env=dict(os.environ, TEST_SCRIPT=str(script),
                         TEST_CONFIG=str(Path(directory) / 'docker.env'),
                         ENVIRONMENT_DOCKER_USER='bad user'), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('nom de compte invalide', result.stderr)
        self.assertNotIn('bad user', result.stderr)

    def test_all_stack_owner_consumers_use_the_new_name(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertNotRegex(source, r'(?<![A-Z0-9_])DOCKER_USER(?![A-Z0-9_])')
        self.assertIn('"$ENVIRONMENT_DOCKER_USER"', source)


if __name__ == '__main__':
    unittest.main()
