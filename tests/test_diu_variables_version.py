#!/usr/bin/env python3
"""Tests isolés de la version dynamique des variables DIU."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/diu/diu_variables_version.sh'


class DiuVariablesVersionTests(unittest.TestCase):
    def run_case(self, body, version='2026.11.02.14.10', initial=None,
                 unavailable=False, source_first=True):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'diu.env'),
                       TEST_VERSION=version,
                       TEST_UNAVAILABLE='1' if unavailable else '0')
            env.pop('DIU_VARIABLES_VERSION', None)
            if initial is not None:
                env['DIU_VARIABLES_VERSION'] = initial
            prelude = '''
dpkg-query() {
    [[ "$1" == -W && "$2" == '-f=${Version}' && "$3" == diu ]] || return 90
    [[ "$TEST_UNAVAILABLE" == 0 ]] || return 1
    printf '%s' "$TEST_VERSION"
}
'''
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + prelude +
                 ('source "$TEST_SCRIPT"\n' if source_first else '') + body],
                env=env, capture_output=True, text=True)

    def test_dynamic_version_comes_from_installed_package(self):
        result = self.run_case('''
[[ "$config" == DYNAMIC && "$state" == ENABLE && "$scope" == diu ]]
[[ "$DIU_VARIABLES_VERSION" == 2026.11.02.14.10 ]]
bash -c '[[ "$DIU_VARIABLES_VERSION" == 2026.11.02.14.10 ]]'
[[ ! -e "$TEST_CONFIG" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_value_is_preserved_without_query(self):
        result = self.run_case('''
dpkg-query() { return 99; }
[[ "$DIU_VARIABLES_VERSION" == supplied ]]
''', initial='supplied')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_missing_package_version_fails_without_export(self):
        result = self.run_case('''
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${DIU_VARIABLES_VERSION+x}" ]]
''', unavailable=True, source_first=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('indisponible', result.stderr)

    def test_disabled_cleanup_preserves_neighboring_variables(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            config = target / 'diu.env'
            config.write_text(
                'export DIU_VARIABLES_VERSION=old\nexport DIU_VERSION=keep\n')
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nsource "$TEST_SCRIPT"\n'
                 '[[ -z "${DIU_VARIABLES_VERSION+x}" ]]\n'],
                env=dict(os.environ, TEST_SCRIPT=str(script), TEST_CONFIG=str(config)),
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(config.read_text(), 'export DIU_VERSION=keep\n')


if __name__ == '__main__':
    unittest.main()
