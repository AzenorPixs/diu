#!/usr/bin/env python3
"""Tests de la déclaration statique du compte DevOps."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/environnements/env_devops_user.sh'


class DevopsUserTests(unittest.TestCase):
    def run_case(self, existing=None):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            config = path / 'environnements.env'
            script = path / 'declaration.sh'
            script.write_text(SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"'))
            env = dict(os.environ, TEST_CONFIG=str(config), TEST_SCRIPT=str(script))
            env.pop('ENV_DEVOPS_USER', None)
            if existing is not None:
                env['ENV_DEVOPS_USER'] = existing
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_SCRIPT"; printf "%s" "$ENV_DEVOPS_USER"'],
                env=env, text=True, capture_output=True)
            return result, config.read_text() if config.exists() else None

    def test_default_root_is_persisted(self):
        result, saved = self.run_case()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'root')
        self.assertEqual(saved, 'export ENV_DEVOPS_USER=root\n')

    def test_existing_user_is_preserved(self):
        result, saved = self.run_case('devops')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'devops')
        self.assertIsNone(saved)


if __name__ == '__main__':
    unittest.main()
