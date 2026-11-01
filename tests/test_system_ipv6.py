#!/usr/bin/env python3
"""Tests isolés de la déclaration du contrôle IPv6 système."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/system/system_ipv6.sh'


class SystemIpv6Tests(unittest.TestCase):
    def run_case(self, body, prelude='', initial=None, disabled=False, extra_env=None):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text()
            declaration = declaration.replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            if disabled:
                declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'config' / 'system.env'))
            env.pop('SYSTEM_IPV6', None)
            if initial is not None:
                env['SYSTEM_IPV6'] = initial
            if extra_env:
                env.update(extra_env)
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + prelude + '\n' + body],
                env=env, capture_output=True, text=True)

    def test_sysctl_state_is_persisted_as_static_initial_value(self):
        for disabled_value, expected in (('0', '1'), ('1', '0')):
            with self.subTest(disabled_value=disabled_value):
                prelude = '''sysctl() {
    [[ "$1" == -n && "$2" == net.ipv6.conf.all.disable_ipv6 ]]
    printf '%s\\n' "$TEST_DISABLE_IPV6"
}'''
                body = '''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == system ]]
[[ "$SYSTEM_IPV6" == "$TEST_EXPECTED_IPV6" ]]
bash -c '[[ "$SYSTEM_IPV6" == "$TEST_EXPECTED_IPV6" ]]'
[[ "$(cat "$TEST_CONFIG")" == "export SYSTEM_IPV6=$TEST_EXPECTED_IPV6" ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
'''
                result = self.run_case(
                    body, prelude=prelude,
                    extra_env={'TEST_DISABLE_IPV6': disabled_value,
                               'TEST_EXPECTED_IPV6': expected})
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_existing_values_are_preserved_without_probing(self):
        prelude = 'sysctl() { return 1; }'
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case('''expected="$SYSTEM_IPV6"
source "$TEST_SCRIPT"
[[ "$SYSTEM_IPV6" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', prelude=prelude, initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_invalid_sysctl_value_fails_without_persisting(self):
        result = self.run_case('''sysctl() { printf '%s\\n' 2; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_IPV6+x}" ]]
[[ ! -e "$TEST_CONFIG" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('invalide', result.stderr)

    def test_sysctl_failure_does_not_persist_or_export(self):
        result = self.run_case('''sysctl() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_IPV6+x}" ]]
[[ ! -e "$TEST_CONFIG" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_persistence_error_does_not_export(self):
        result = self.run_case('''sysctl() { printf '%s\\n' 0; }
install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${SYSTEM_IPV6+x}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_disabled_cleanup(self):
        result = self.run_case('''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export SYSTEM_IPV6=1' 'export SYSTEM_IPV6_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${SYSTEM_IPV6+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export SYSTEM_IPV6_EXTRA=keep' ]]
''', initial='1', disabled=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_consumer_uses_new_name_with_disabled_fallback(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertEqual(source.count('if [[ "${SYSTEM_IPV6:-0}" == "1" ]]'), 1)
        self.assertNotRegex(source, r'\$(?:\{)?IPv6(?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
