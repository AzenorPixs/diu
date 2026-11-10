#!/usr/bin/env python3
"""Vérifie la dépendance de la racine des projets au chargement."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/config.sh'


class EnvironmentLoadOrderTests(unittest.TestCase):
    def run_case(self, contents):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            config = path / 'environnements.env'
            config.write_text(contents)
            script = path / 'config.sh'
            script.write_text(SOURCE.read_text().replace(
                'local config_file_environnements="/root/diu/config/environnements.env"',
                'local config_file_environnements="$TEST_CONFIG"'))
            env = dict(os.environ, TEST_CONFIG=str(config), TEST_SCRIPT=str(script))
            env.pop('ENV_DEVOPS_USER', None)
            env.pop('ENV_DEVOPS_PROJECTS_ROOT', None)
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_SCRIPT"; '
                 'config_load_environments; config_load_environments; '
                 'printf "%s" "$ENV_DEVOPS_PROJECTS_ROOT"'],
                env=env, text=True, capture_output=True)
            return result, config.read_text()

    def test_sorted_root_before_user_loads_twice(self):
        contents = ('export ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"\n'
                    'export ENV_DEVOPS_USER=devops\n')
        result, saved = self.run_case(contents)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '/home/devops/datas')
        self.assertEqual(saved, contents)

    def test_missing_user_fails_without_changing_file(self):
        contents = 'export ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"\n'
        result, saved = self.run_case(contents)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('ENV_DEVOPS_USER est absent', result.stderr)
        self.assertEqual(saved, contents)

    def test_ambiguous_user_fails_without_execution(self):
        contents = ('export ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"\n'
                    'export ENV_DEVOPS_USER="$(false)"\n')
        result, saved = self.run_case(contents)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('déclaration ambiguë', result.stderr)
        self.assertEqual(saved, contents)

    def test_legacy_projects_root_loads_after_legacy_user(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            config = path / 'environnements.env'
            contents = ('export DEVOPS_PROJECTS_ROOT="/home/${DEVOPS_USER}/datas"\n'
                        'export DEVOPS_USER=devops\n')
            config.write_text(contents)
            script = path / 'config.sh'
            script.write_text(SOURCE.read_text().replace(
                'local config_file_environnements="/root/diu/config/environnements.env"',
                'local config_file_environnements="$TEST_CONFIG"'))
            env = dict(os.environ, TEST_CONFIG=str(config), TEST_SCRIPT=str(script))
            env.pop('DEVOPS_USER', None)
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_SCRIPT"; '
                 'config_load_environments; printf "%s" "$DEVOPS_PROJECTS_ROOT"'],
                env=env, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, '/home/devops/datas')
            self.assertEqual(config.read_text(), contents)

    def test_generator_loads_user_once_before_projects_root(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            variables = path / 'modules/diu/variables/environnements'
            variables.mkdir(parents=True)
            (variables / 'env_devops_user.sh').write_text(
                'printf "user\\n" >> "$TEST_LOG"\nexport ENV_DEVOPS_USER=devops\n')
            (variables / 'env_devops_projects_root.sh').write_text(
                '[[ "$ENV_DEVOPS_USER" == devops ]]\nprintf "root\\n" >> "$TEST_LOG"\n')
            log = path / 'order.txt'
            env = dict(os.environ, BASH_SCRIPT_PATH=str(path), TEST_LOG=str(log),
                       TEST_CONFIG_SCRIPT=str(SOURCE))
            env.pop('ENV_DEVOPS_USER', None)
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_CONFIG_SCRIPT"; config_generator'],
                env=env, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(log.read_text(), 'user\nroot\n')

    def test_generator_uses_preloaded_user_when_file_is_absent(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            variables = path / 'modules/diu/variables/environnements'
            variables.mkdir(parents=True)
            (variables / 'env_devops_projects_root.sh').write_text(
                '[[ "$ENV_DEVOPS_USER" == devops ]]\n')
            env = dict(os.environ, BASH_SCRIPT_PATH=str(path),
                       ENV_DEVOPS_USER='devops', TEST_CONFIG_SCRIPT=str(SOURCE))
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_CONFIG_SCRIPT"; config_generator'],
                env=env, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_user_is_initialized_before_interpolated_scope(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            variables = path / 'modules/diu/variables/environnements'
            variables.mkdir(parents=True)
            config = path / 'environnements.env'
            config.write_text('export ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"\n')
            user_source = ROOT / 'modules/diu/variables/environnements/env_devops_user.sh'
            user_content = user_source.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            (variables / 'env_devops_user.sh').write_text(
                'printf "user\\n" >> "$TEST_LOG"\n' + user_content)
            (variables / 'env_devops_projects_root.sh').write_text(
                '[[ "$ENV_DEVOPS_PROJECTS_ROOT" == /home/root/datas ]]\n'
                'printf "root\\n" >> "$TEST_LOG"\n')
            script = path / 'config.sh'
            script.write_text(SOURCE.read_text().replace(
                'local config_file_environnements="/root/diu/config/environnements.env"',
                'local config_file_environnements="$TEST_CONFIG"'))
            log = path / 'order.txt'
            env = dict(os.environ, BASH_SCRIPT_PATH=str(path), TEST_CONFIG=str(config),
                       TEST_LOG=str(log), TEST_SCRIPT=str(script))
            env.pop('ENV_DEVOPS_USER', None)
            env.pop('ENV_DEVOPS_PROJECTS_ROOT', None)
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_SCRIPT"; '
                 'diu_env_devops_user_loaded=0; config_load_environments; config_generator; '
                 'printf "%s" "$ENV_DEVOPS_PROJECTS_ROOT"'],
                env=env, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, '/home/root/datas')
            self.assertEqual(log.read_text(), 'user\nroot\n')

    def test_full_loading_survives_sort_and_restart(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory)
            variables = path / 'modules/diu/variables/environnements'
            variables.mkdir(parents=True)
            config_dir = path / 'config'
            config_dir.mkdir()
            config = config_dir / 'environnements.env'
            config.write_text('export ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"\n')
            for name in ('env_devops_user.sh', 'env_devops_projects_root.sh'):
                original = ROOT / 'modules/diu/variables/environnements' / name
                (variables / name).write_text(original.read_text().replace(
                    '/root/diu/config', '$TEST_CONFIG_DIR'))
            script = path / 'config.sh'
            script.write_text(SOURCE.read_text().replace('/root/diu/config', '$TEST_CONFIG_DIR'))
            env = dict(os.environ, BASH_SCRIPT_PATH=str(path),
                       TEST_CONFIG_DIR=str(config_dir), TEST_SCRIPT=str(script), TEST_ROOT=str(ROOT))
            for name in ('ENV_DEVOPS_USER', 'ENV_DEVOPS_PROJECTS_ROOT', 'DEVOPS_PROJECTS_ROOT'):
                env.pop(name, None)
            command = ['bash', '-c', 'set -Eeuo pipefail; source "$TEST_ROOT/modules/softwares/desired-state.sh"; '
                       'source "$TEST_ROOT/modules/softwares/migration.sh"; source "$TEST_SCRIPT"; '
                       'config_load; printf "%s|%s" "$ENV_DEVOPS_USER" "$ENV_DEVOPS_PROJECTS_ROOT"']
            for _ in range(2):
                result = subprocess.run(command, env=env, text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, 'root|/home/root/datas')


if __name__ == '__main__':
    unittest.main()
