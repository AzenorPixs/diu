#!/usr/bin/env python3
"""Tests de la déclaration logicielle et de l'installation APT du bouncer."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'SOFTWARES_APT_CROWDSEC_BOUNCER'
SOURCE = ROOT / 'modules/diu/variables/softwares/software_apt_crowdsec_bouncer.sh'


class CrowdsecBouncerTests(unittest.TestCase):
    def run_case(self, body, initial=None, source=True):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            script = Path(directory) / 'variable.sh'
            module = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            script.write_text(module)
            env = dict(os.environ, TEST_CONFIG=str(Path(directory) / 'softwares.env'))
            if initial is not None:
                env[VARIABLE] = initial
            prefix = 'set -Eeuo pipefail\n' + ('source "$TEST_SCRIPT"\n' if source else '')
            return subprocess.run(['bash', '-c', prefix + body],
                                  env=dict(env, TEST_SCRIPT=str(script)), text=True,
                                  capture_output=True)

    def test_default_persistence_and_contract(self):
        result = self.run_case('''
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == softwares ]]
[[ "$SOFTWARES_APT_CROWDSEC_BOUNCER" == 0 ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SOFTWARES_APT_CROWDSEC_BOUNCER=0' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case(f'[[ "$SOFTWARES_APT_CROWDSEC_BOUNCER" == {value} ]]',
                                       initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_invalid_value_is_rejected(self):
        result = self.run_case('if source "$TEST_SCRIPT"; then exit 99; fi',
                               initial='invalid', source=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('valeur invalide', result.stderr)

    def test_installer_uses_apt_and_the_software_variable(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertIn('if [[ "${SOFTWARES_APT_CROWDSEC_BOUNCER:-0}" == "1" ]]', source)
        self.assertIn('apt install crowdsec-firewall-bouncer-iptables -y', source)
        self.assertNotIn('${CROWDSEC_BOUNCER:-', source)


if __name__ == '__main__':
    unittest.main()
