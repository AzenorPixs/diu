#!/usr/bin/env python3
"""Tests isolés du contrôle de la stack Docker Traefik/Dockhand."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'modules/diu/variables/docker/docker_stack_traefik_dockhand.sh'
VARIABLE = 'DOCKER_STACK_TRAEFIK_DOCKHAND'


class DockerStackTraefikDockhandTests(unittest.TestCase):
    def run_case(self, body, initial=None, disabled=False):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            target = Path(directory)
            declaration = SOURCE.read_text().replace(
                'variable_config_file="/root/diu/config/${scope}.env"',
                'variable_config_file="$TEST_CONFIG"')
            if disabled:
                declaration = declaration.replace('state="ENABLE"', 'state="DISABLE"')
            script = target / 'declaration.sh'
            script.write_text(declaration)
            env = dict(os.environ, TEST_SCRIPT=str(script),
                       TEST_CONFIG=str(target / 'config' / 'docker.env'))
            env.pop(VARIABLE, None)
            if initial is not None:
                env[VARIABLE] = initial
            return subprocess.run(
                ['bash', '-c', 'set -Eeuo pipefail\n' + body],
                env=env, capture_output=True, text=True)

    def test_default_persistence_export_and_idempotence(self):
        result = self.run_case('''source "$TEST_SCRIPT"
[[ "$config" == STATIC && "$state" == ENABLE && "$scope" == docker ]]
[[ "$DOCKER_STACK_TRAEFIK_DOCKHAND" == 0 ]]
bash -c '[[ "$DOCKER_STACK_TRAEFIK_DOCKHAND" == 0 ]]'
[[ "$(cat "$TEST_CONFIG")" == 'export DOCKER_STACK_TRAEFIK_DOCKHAND=0' ]]
source "$TEST_SCRIPT"
[[ "$(wc -l < "$TEST_CONFIG")" == 1 ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_values_are_preserved(self):
        for value in ('0', '1'):
            with self.subTest(value=value):
                result = self.run_case('''expected="$DOCKER_STACK_TRAEFIK_DOCKHAND"
source "$TEST_SCRIPT"
[[ "$DOCKER_STACK_TRAEFIK_DOCKHAND" == "$expected" ]]
[[ ! -e "$TEST_CONFIG" ]]
''', initial=value)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stderr, '')

    def test_invalid_existing_value_is_rejected(self):
        result = self.run_case('''if source "$TEST_SCRIPT"; then exit 99; fi
[[ "$DOCKER_STACK_TRAEFIK_DOCKHAND" == invalid ]]
''', initial='invalid')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('invalide', result.stderr)

    def test_persistence_errors_do_not_export(self):
        result = self.run_case('''install() { return 1; }
if source "$TEST_SCRIPT"; then exit 99; fi
[[ -z "${DOCKER_STACK_TRAEFIK_DOCKHAND+x}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('impossible', result.stderr)

    def test_disabled_cleanup(self):
        result = self.run_case('''mkdir -p "$(dirname "$TEST_CONFIG")"
printf '%s\\n' 'export DOCKER_STACK_TRAEFIK_DOCKHAND=1' 'export DOCKER_STACK_TRAEFIK_DOCKHAND_EXTRA=keep' > "$TEST_CONFIG"
source "$TEST_SCRIPT"
[[ -z "${DOCKER_STACK_TRAEFIK_DOCKHAND+x}" ]]
[[ "$(cat "$TEST_CONFIG")" == 'export DOCKER_STACK_TRAEFIK_DOCKHAND_EXTRA=keep' ]]
''', initial='1', disabled=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, '')

    def test_existing_consumers_keep_the_declared_name(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertGreaterEqual(source.count(VARIABLE), 4)
        self.assertNotRegex(source, r'\$(?:\{)?DOCKER_STACK_TRAEFIK_DOCKHAND_ENABLED(?:\})?(?![A-Z0-9_])')


if __name__ == '__main__':
    unittest.main()
