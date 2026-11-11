#!/usr/bin/env python3
"""Tests du stockage et de l'application opaque de la clé API CrowdSec."""
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VARIABLE = 'SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY'


class CrowdsecApiKeyTests(unittest.TestCase):
    def run_module(self, directory, body, **values):
        module = (ROOT / 'modules/diu/variables/softwares/desired_crowdsec_secret.sh').read_text()
        module = module.replace(
            'variable_config_file="/root/diu/config/${scope}.env"',
            'variable_config_file="$TEST_CONFIG"')
        script = Path(directory) / 'module.sh'
        script.write_text(module)
        env = dict(os.environ, TEST_CONFIG=str(Path(directory) / 'softwares.env'))
        env.update({name: str(value) for name, value in values.items()})
        prelude = ('set -Eeuo pipefail\nsource "$TEST_ROOT/modules/softwares/desired-state.sh"\n'
                   'source "$TEST_ROOT/modules/softwares/migration.sh"\n'
                   'source "$TEST_ROOT/modules/softwares/global-declarations.sh"\n'
                   'software_secure_sensitive_configuration "$TEST_CONFIG"\nsource "$TEST_MODULE"\n')
        return subprocess.run(['bash', '-c', prelude + body],
                              env=dict(env, TEST_MODULE=str(script), TEST_ROOT=str(ROOT)), text=True,
                              capture_output=True)

    def test_empty_default_is_persisted_without_logging(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            result = self.run_module(directory, f'[[ -z "${{{VARIABLE}}}" ]]')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((Path(directory) / 'softwares.env').read_text(),
                             f'export {VARIABLE}=\'\'\n')
            self.assertEqual(result.stdout, '')

    def test_existing_key_is_preserved_and_config_is_private(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            config = Path(directory) / 'softwares.env'
            config.write_text(f'export {VARIABLE}=synthetic-Key_123\n')
            config.chmod(0o644)
            result = self.run_module(directory, f'[[ "${{{VARIABLE}}}" == synthetic-Key_123 ]]',
                                     SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY='synthetic-Key_123')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(config.stat().st_mode & 0o777, 0o600)
            self.assertEqual(result.stdout, '')
            self.assertNotIn('synthetic-Key_123', result.stderr)

    def test_global_bouncer_hook_does_not_put_secret_in_command_arguments_or_output(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            args = Path(directory) / 'arguments'
            script = r'''
set -Eeuo pipefail
source "$TEST_ROOT/modules/softwares/crowdsec-hooks.sh"
software_apt_crowdsec_helper() { printf '%s' "$*" > "$TEST_ARGS"; }
systemctl() { :; }
service() { :; }
software_apt_configure_crowdsec_bouncer remote
'''
            result = subprocess.run(['bash', '-c', script],
                                    env=dict(os.environ, TEST_ROOT=str(ROOT), TEST_ARGS=str(args),
                                             SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY='synthetic-Key_123'),
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(args.read_text(), 'bouncer remote')
            self.assertNotIn('synthetic-Key_123', result.stdout + result.stderr)
            self.assertNotIn('crowdsec_bouncer_set_api_key()', (ROOT / 'root-install-debian.sh').read_text())


if __name__ == '__main__':
    unittest.main()
