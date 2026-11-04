#!/usr/bin/env python3
"""Vérifie l'initialisation isolée de la racine des projets DevOps."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/environnements/env_devops_projects_root.sh'


class DevopsProjectsRootTests(unittest.TestCase):
    def run_case(self, values):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            script = path / 'declaration.sh'
            config = path / 'environnements.env'
            script.write_text(SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"'))
            env = dict(os.environ, TEST_CONFIG=str(config), TEST_SCRIPT=str(script))
            for key in ('ENV_DEVOPS_PROJECTS_ROOT', 'DEVOPS_PROJECTS_ROOT', 'ENV_DEVOPS_USER'):
                env.pop(key, None)
            env.update(values)
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_SCRIPT"; '
                 'printf "%s" "$ENV_DEVOPS_PROJECTS_ROOT"'],
                env=env, text=True, capture_output=True)
            saved = config.read_text() if config.exists() else None
            return result, saved

    def test_default_is_expanded_and_persisted_as_literal(self):
        result, saved = self.run_case({'ENV_DEVOPS_USER': 'devops'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '/home/devops/datas')
        self.assertEqual(saved, 'export ENV_DEVOPS_PROJECTS_ROOT=/home/devops/datas\n')

    def test_legacy_value_is_preserved(self):
        result, saved = self.run_case({'DEVOPS_PROJECTS_ROOT': '/srv/projets spéciaux'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '/srv/projets spéciaux')
        self.assertIn('ENV_DEVOPS_PROJECTS_ROOT=', saved)

    def test_explicit_empty_legacy_value_is_preserved(self):
        result, saved = self.run_case({'DEVOPS_PROJECTS_ROOT': ''})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '')
        self.assertEqual(saved, "export ENV_DEVOPS_PROJECTS_ROOT=''\n")

    def test_new_value_takes_precedence(self):
        result, saved = self.run_case({'ENV_DEVOPS_PROJECTS_ROOT': '/srv/new',
                                       'DEVOPS_PROJECTS_ROOT': '/srv/old'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '/srv/new')
        self.assertIsNone(saved)

    def test_missing_user_fails_without_persistence(self):
        result, saved = self.run_case({})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('ENV_DEVOPS_USER est absent', result.stderr)
        self.assertIsNone(saved)


if __name__ == '__main__':
    unittest.main()
