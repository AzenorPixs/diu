#!/usr/bin/env python3
"""Provisionnement isolé des comptes techniques sans mot de passe."""
import os
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'


class TechnicalAccountPasswordsTests(unittest.TestCase):
    def test_account_provisioning_does_not_set_password(self):
        source = SCRIPT.read_text()
        for kind in ('DEVOPS', 'DOCKER', 'IA'):
            with self.subTest(account=kind):
                marker = f'if id -u "$ENV_{kind}_USER"'
                start = source.index(marker)
                closing = '\n  fi' if kind == 'DOCKER' else '\n\tfi'
                end = source.index(closing, start)
                fragment = source[start:end + len(closing)]
                for existing in (True, False):
                    with self.subTest(existing=existing):
                        env = dict(os.environ, ACCOUNT_EXISTS='1' if existing else '0')
                        for account in ('DEVOPS', 'DOCKER', 'IA'):
                            env.pop(f'ENV_{account}_PASSWORD', None)
                        env[f'ENV_{kind}_USER'] = 'test-user'
                        env[f'ENV_{kind}_GROUP'] = 'test-group'
                        harness = '''set -eu
id() { [ "$ACCOUNT_EXISTS" = 1 ]; }
useradd() { printf 'created:%s\\n' "$*"; }
chpasswd() { printf 'unexpected chpasswd\\n' >&2; return 42; }
''' + fragment
                        result = subprocess.run(['bash', '-c', harness], env=env,
                                                text=True, capture_output=True)
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assertNotIn('chpasswd', result.stderr)
                        self.assertEqual('created:' in result.stdout, not existing)
                        if not existing:
                            self.assertIn('test-user --gid test-group -s /bin/bash', result.stdout)


if __name__ == '__main__':
    unittest.main()
