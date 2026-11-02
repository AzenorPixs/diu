#!/usr/bin/env python3
"""Tests isolés de la déclaration du profil logiciels de bureau."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'DESKTOP'
SOURCE = ROOT / 'modules/diu/variables/desktop/desktop.sh'


class SoftwareAptDesktopTests(unittest.TestCase):
    def run_case(self, body, initial=None):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            module = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            script.write_text(module)
            env = dict(os.environ, TEST_CONFIG=str(Path(directory) / 'desktop.env'))
            if initial is not None:
                env[VARIABLE] = initial
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nsource "$TEST_SCRIPT"\n' + body],
                env=dict(env, TEST_SCRIPT=str(script)), text=True, capture_output=True)
            return result, Path(directory) / 'softwares.env'

    def test_default_persistence_and_contract(self):
        result, config = self.run_case('''
        [[ "$config" == STATIC && "$state" == ENABLE && "$scope" == desktop ]]
[[ "$DESKTOP" == 0 ]]
[[ "$(cat "$TEST_CONFIG")" == 'export DESKTOP=0' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result, config = self.run_case(
            f'[[ "$DESKTOP" == {value} ]]', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertFalse(config.exists())

    def test_invalid_value_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            script.write_text(SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"'))
            result = subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\nif source "$TEST_SCRIPT"; then exit 99; fi'],
                env=dict(os.environ, TEST_SCRIPT=str(script), TEST_CONFIG=str(Path(directory) / 'desktop.env'),
                         DESKTOP='invalid'), text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('valeur invalide', result.stderr)

    def test_consumers_use_the_new_toggle_with_absent_fallback(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertEqual(source.count('${DESKTOP:-0}'), 2)
        self.assertNotIn('${SOFTWARES_APT_DESKTOP:-', source)


if __name__ == '__main__':
    unittest.main()
