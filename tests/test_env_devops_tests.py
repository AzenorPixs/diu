#!/usr/bin/env python3
"""Indicateurs de tests DevOps, sans accès à la configuration réelle."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
DECLARATIONS = ROOT / 'modules/diu/variables/environnements'
VARIABLES = ('ENV_DEVOPS_TESTS_DOCKER', 'ENV_DEVOPS_TESTS_LXC')


class EnvDevopsTests(unittest.TestCase):
    def run_case(self, body, disabled=None):
        with tempfile.TemporaryDirectory(prefix='tests devops ', dir=ROOT) as directory:
            target = Path(directory)
            app = target / 'app'
            declarations = app / 'modules/diu/variables/environnements'
            declarations.mkdir(parents=True)
            for variable in VARIABLES:
                name = variable.lower() + '.sh'
                content = (DECLARATIONS / name).read_text(encoding='utf-8')
                original = 'variable_config_file="/root/diu/config/${scope}.env"'
                self.assertEqual(content.count(original), 1)
                content = content.replace(original, 'variable_config_file="$TEST_CONFIG"')
                if variable == disabled:
                    content = content.replace('state="ENABLE"', 'state="DISABLE"')
                (declarations / name).write_text(content, encoding='utf-8')
            loader = (ROOT / 'modules/diu/config.sh').read_text(encoding='utf-8')
            loader = loader.replace('/root/diu/config', '${TEST_CONFIG_DIR}')
            (app / 'config.sh').write_text(loader, encoding='utf-8')
            env = dict(os.environ, BASH_SCRIPT_PATH=str(app),
                       TEST_CONFIG_DIR=str(target / 'config'),
                       TEST_CONFIG=str(target / 'config/environnements.env'),
                       TEST_DECLARATIONS=str(declarations))
            for variable in VARIABLES:
                env.pop(variable, None)
            prelude = '''set -Eeuo pipefail
docker() { echo 'Docker interdit dans ce test' >&2; return 99; }
lxc() { echo 'LXC interdit dans ce test' >&2; return 99; }
lxc-start() { echo 'LXC interdit dans ce test' >&2; return 99; }
source "$BASH_SCRIPT_PATH/config.sh"
'''
            return subprocess.run(['bash', '-c', prelude + body], env=env,
                                  capture_output=True, text=True, timeout=15)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, '')

    def test_first_initialization_discovery_and_export(self):
        result = self.run_case('''config_load
[[ "$ENV_DEVOPS_TESTS_DOCKER" == 0 && "$ENV_DEVOPS_TESTS_LXC" == 0 ]]
bash -c '[[ "$ENV_DEVOPS_TESTS_DOCKER" == 0 && "$ENV_DEVOPS_TESTS_LXC" == 0 ]]'
[[ "$(cat "$TEST_CONFIG")" == $'        export ENV_DEVOPS_TESTS_DOCKER=0\\n        export ENV_DEVOPS_TESTS_LXC=0' ]]
[[ "$(find "$TEST_CONFIG_DIR" -type f | wc -l)" == 1 ]]
''')
        self.assert_success(result)

    def test_repeated_generation_and_reload_are_idempotent(self):
        result = self.run_case('''config_load
before="$(cat "$TEST_CONFIG")"
config_update
[[ "$(cat "$TEST_CONFIG")" == "$before" ]]
unset ENV_DEVOPS_TESTS_DOCKER ENV_DEVOPS_TESTS_LXC
config_load
config_update
[[ "$(cat "$TEST_CONFIG")" == "$before" ]]
[[ "$(wc -l < "$TEST_CONFIG")" == 2 ]]
''')
        self.assert_success(result)

    def test_defined_shell_values_preserved_without_writing(self):
        for value in ('0', '1', '', 'custom'):
            with self.subTest(value=value):
                result = self.run_case('''ENV_DEVOPS_TESTS_DOCKER=''' + repr(value) + '''
ENV_DEVOPS_TESTS_LXC="$ENV_DEVOPS_TESTS_DOCKER"
expected="$ENV_DEVOPS_TESTS_DOCKER"
source "$TEST_DECLARATIONS/env_devops_tests_docker.sh"
source "$TEST_DECLARATIONS/env_devops_tests_lxc.sh"
[[ "$ENV_DEVOPS_TESTS_DOCKER" == "$expected" && "$ENV_DEVOPS_TESTS_LXC" == "$expected" ]]
export expected
bash -c '[[ "${ENV_DEVOPS_TESTS_DOCKER+x}" == x && "${ENV_DEVOPS_TESTS_LXC+x}" == x
           && "$ENV_DEVOPS_TESTS_DOCKER" == "$expected" && "$ENV_DEVOPS_TESTS_LXC" == "$expected" ]]'
[[ ! -e "$TEST_CONFIG_DIR" ]]
''')
                self.assert_success(result)

    def test_partial_persistent_configuration_and_other_lines_preserved(self):
        for variable in VARIABLES:
            with self.subTest(variable=variable):
                result = self.run_case('''mkdir -p "$TEST_CONFIG_DIR"
printf '%s\\n' '# configuration contrôlée' 'export NEIGHBOR=keep' \\
    'export ''' + variable + '''=1' > "$TEST_CONFIG"
config_load
[[ "$''' + variable + '''" == 1 && "$NEIGHBOR" == keep ]]
[[ "$(grep -c '^[[:blank:]]*export ENV_DEVOPS_TESTS_.*=0$' "$TEST_CONFIG")" == 1 ]]
[[ "$(grep -c '^export ENV_DEVOPS_TESTS_.*=1$' "$TEST_CONFIG")" == 1 ]]
grep -qx '# configuration contrôlée' "$TEST_CONFIG"
grep -qx 'export NEIGHBOR=keep' "$TEST_CONFIG"
[[ "$(wc -l < "$TEST_CONFIG")" == 4 ]]
''')
                self.assert_success(result)

    def test_persisted_empty_and_enabled_values_survive_reload(self):
        result = self.run_case('''mkdir -p "$TEST_CONFIG_DIR"
printf '%s\\n' 'export ENV_DEVOPS_TESTS_DOCKER=' 'export ENV_DEVOPS_TESTS_LXC=1' > "$TEST_CONFIG"
before="$(cat "$TEST_CONFIG")"
config_load
[[ "${ENV_DEVOPS_TESTS_DOCKER+x}" == x && -z "$ENV_DEVOPS_TESTS_DOCKER" ]]
[[ "$ENV_DEVOPS_TESTS_LXC" == 1 ]]
config_update
[[ "$(cat "$TEST_CONFIG")" == "$before" ]]
''')
        self.assert_success(result)

    def test_directory_creation_failure_does_not_define_variable(self):
        for variable in VARIABLES:
            with self.subTest(variable=variable):
                result = self.run_case('''install() { return 1; }
if source "$TEST_DECLARATIONS/''' + variable.lower() + '''.sh"; then exit 99; fi
[[ -z "${''' + variable + '''+x}" && ! -e "$TEST_CONFIG" ]]
''')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(variable + ' : création du répertoire de configuration impossible.',
                              result.stderr)

    def test_persistence_failure_does_not_define_variable(self):
        for variable in VARIABLES:
            with self.subTest(variable=variable):
                result = self.run_case('''mkdir -p "$TEST_CONFIG"
if source "$TEST_DECLARATIONS/''' + variable.lower() + '''.sh"; then exit 99; fi
[[ -z "${''' + variable + '''+x}" ]]
''')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(variable + ' : persistance impossible.', result.stderr)

    def test_disabled_declaration_preserves_other_variable_and_neighbor(self):
        for variable in VARIABLES:
            other = next(name for name in VARIABLES if name != variable)
            with self.subTest(variable=variable):
                result = self.run_case('''mkdir -p "$TEST_CONFIG_DIR"
printf '%s\\n' 'export ENV_DEVOPS_TESTS_DOCKER=1' 'export ENV_DEVOPS_TESTS_LXC=1' \\
    'export ''' + variable + '''_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_CONFIG"
source "$TEST_DECLARATIONS/''' + variable.lower() + '''.sh"
[[ -z "${''' + variable + '''+x}" && "$''' + other + '''" == 1 ]]
grep -qx 'export ''' + other + '''=1' "$TEST_CONFIG"
grep -qx 'export ''' + variable + '''_EXTRA=keep' "$TEST_CONFIG"
[[ "$(wc -l < "$TEST_CONFIG")" == 2 ]]
source "$TEST_DECLARATIONS/''' + variable.lower() + '''.sh"
[[ "$(wc -l < "$TEST_CONFIG")" == 2 ]]
''', disabled=variable)
                self.assert_success(result)

    def test_disabled_cleanup_accepts_indented_lines(self):
        for variable in VARIABLES:
            other = next(name for name in VARIABLES if name != variable)
            for prefix in ('        ', '\t'):
                with self.subTest(variable=variable, prefix=prefix):
                    result = self.run_case('''mkdir -p "$TEST_CONFIG_DIR"
printf '%s\\n' 'PREEXISTING=keep' \\
    '        export __OTHER__=1' \\
    '__PREFIX__export __VARIABLE__=1' \\
    '__PREFIX__export __VARIABLE___EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_CONFIG"
source "$TEST_DECLARATIONS/__DECLARATION__.sh"
[[ -z "${__VARIABLE__+x}" && "$__OTHER__" == 1 ]]
grep -qx '        export __OTHER__=1' "$TEST_CONFIG"
grep -qx 'PREEXISTING=keep' "$TEST_CONFIG"
grep -qx '__PREFIX__export __VARIABLE___EXTRA=keep' "$TEST_CONFIG"
[[ "$(wc -l < "$TEST_CONFIG")" == 3 ]]
'''.replace('__VARIABLE__', variable).replace('__OTHER__', other)
                       .replace('__PREFIX__', prefix)
                       .replace('__DECLARATION__', variable.lower()), disabled=variable)
                    self.assert_success(result)

    def test_disabled_cleanup_failure_is_reported(self):
        for variable in VARIABLES:
            with self.subTest(variable=variable):
                result = self.run_case('''mkdir -p "$TEST_CONFIG_DIR"
printf '%s\\n' 'export ''' + variable + '''=1' > "$TEST_CONFIG"
sed() { return 1; }
if source "$TEST_DECLARATIONS/''' + variable.lower() + '''.sh"; then exit 99; fi
[[ -z "${''' + variable + '''+x}" ]]
grep -qx 'export ''' + variable + '''=1' "$TEST_CONFIG"
''', disabled=variable)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(variable + ' : suppression de la déclaration impossible.',
                              result.stderr)


if __name__ == '__main__':
    unittest.main()
