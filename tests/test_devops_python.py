#!/usr/bin/env python3
"""Exécution isolée du bloc Python : aucun pip ni téléchargement réel."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'


class DevopsPythonTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = SCRIPT.read_text(encoding='utf-8')
        start = source.index('\tif [ "$PYTHON" -eq 1 ]\n\tthen\n')
        end = source.index('\n  chown -R "$ENV_DEVOPS_USER"', start)
        cls.block = source[start:end]
        parent = source.index('if [ "$ENV_DEVOPS" -eq 1 ]\nthen\n')
        cls.activation = source[parent:parent + len('if [ "$ENV_DEVOPS" -eq 1 ]\nthen\n')]

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-python-')
        self.addCleanup(self.temporary.cleanup)
        self.fixture = Path(self.temporary.name)
        self.home = self.fixture / 'homes' / 'devops-fixture'
        self.binary_directory = self.home / 'python/current/bin'
        self.binary_directory.mkdir(parents=True)
        self.tools = self.fixture / 'tools'
        self.tools.mkdir()
        self.state = self.fixture / 'packages.json'
        self.calls = self.fixture / 'calls.jsonl'
        self.profile = self.fixture / 'python-dev.sh'
        self.environment = {
            'PATH': str(self.tools) + ':' + os.defpath,
            'LC_ALL': 'C.UTF-8',
            'ENV_DEVOPS': '1', 'PYTHON': '1', 'PYTHON_SERIES': '3.14',
            'DEVOPS_USER': 'devops-fixture', 'ENV_DEVOPS_USER': 'devops-fixture',
            'TEST_STATE': str(self.state), 'TEST_CALLS': str(self.calls),
            'TEST_AVAILABLE': '3.3.5', 'TEST_FAULT': '',
        }
        self.executable(self.binary_directory / 'python3.14', r'''#!/usr/bin/python3 -B
import json
import os
from pathlib import Path
import sys

arguments = sys.argv[1:]
with Path(os.environ['TEST_CALLS']).open('a', encoding='utf-8') as stream:
    stream.write(json.dumps(arguments) + '\n')
if arguments == ['--version']:
    print('Python 3.14.8')
    sys.exit(0)
state = Path(os.environ['TEST_STATE'])
fault = os.environ['TEST_FAULT']
if arguments[:3] == ['-I', '-B', '-c'] and 'from importlib.metadata import' in arguments[3]:
    if fault == 'metadata':
        print('lecture simulée impossible', file=sys.stderr)
        sys.exit(1)
    print(json.loads(state.read_text())['psycopg'] if state.exists() else '')
    sys.exit(0)
if arguments == ['-m', 'pip', 'install', '--upgrade', '--no-user', '--quiet', 'psycopg[binary]>=3.2,<4']:
    if fault == 'pip':
        print('index simulé inaccessible', file=sys.stderr)
        sys.exit(1)
    available = os.environ['TEST_AVAILABLE']
    packages = {'psycopg': available, 'psycopg-binary': available}
    current = json.loads(state.read_text()) if state.exists() else {}
    if current != packages:
        state.write_text(json.dumps(packages), encoding='utf-8')
    sys.exit(0)
if arguments == ['-I', '-B', '-c', 'import psycopg; print(psycopg.__version__)']:
    if fault == 'import' or not state.exists():
        print('import simulé impossible', file=sys.stderr)
        sys.exit(1)
    print(json.loads(state.read_text())['psycopg'])
    sys.exit(0)
print('appel Python inattendu', file=sys.stderr)
sys.exit(90)
''')
        (self.binary_directory / 'python3').symlink_to('python3.14')
        self.executable(self.binary_directory / 'pip3.14', '#!/bin/sh\nexit 91\n')
        self.executable(self.tools / 'curl', '#!/bin/sh\nprintf "%s\\n" "3.14.8/"\n')
        # Toute tentative imprévue de compilation ou d'installation est un échec.
        for command in ('apt', 'sudo', 'wget', 'tar', 'make', 'rm'):
            self.executable(self.tools / command,
                            '#!/bin/sh\nprintf "commande interdite dans le test\\n" >&2\nexit 92\n')

    @staticmethod
    def executable(path, content):
        path.write_text(content, encoding='utf-8')
        path.chmod(0o755)

    def run_block(self, **environment):
        # Seuls les chemins de mutation sont redirigés ; le bloc exécuté est réel.
        block = self.block.replace('/home/', str(self.fixture / 'homes') + '/')
        block = block.replace('/usr/local/src/python-build', str(self.fixture / 'build'))
        block = block.replace('/etc/profile.d/python-dev.sh', str(self.profile))
        code = 'set -Eeuo pipefail\n' + self.activation + block + '\nfi\n'
        return subprocess.run(['/bin/bash', '--noprofile', '--norc', '-c', code],
                              cwd=ROOT, env=dict(self.environment, **environment),
                              text=True, capture_output=True, timeout=10)

    def observed_calls(self):
        return [json.loads(line) for line in self.calls.read_text().splitlines()] if self.calls.exists() else []

    def pip_calls(self):
        return [arguments for arguments in self.observed_calls() if arguments[:2] == ['-m', 'pip']]

    def test_first_install_in_existing_python(self):
        result = self.run_block()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads(self.state.read_text()),
                         {'psycopg': '3.3.5', 'psycopg-binary': '3.3.5'})
        self.assertEqual(len(self.pip_calls()), 1)
        self.assertIn('PSYCOPG DEVOPS OK ✅ (3.3.5)', result.stdout)
        self.assertIn('🔧 INSTALL PSYCOPG DEVOPS (3.3.5)', result.stdout)
        self.assertIn('PYTHON 3 DEV OK', result.stdout)
        self.assertNotIn('INSTALL/UPDATE PYTHON 3 DEV', result.stdout)
        self.assertTrue(self.profile.exists())

    def test_second_pass_does_not_reinstall_packages(self):
        first = self.run_block()
        self.assertEqual(first.returncode, 0, first.stderr)
        digest = hashlib.sha256(self.state.read_bytes()).digest()
        modified = self.state.stat().st_mtime_ns
        second = self.run_block()
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(len(self.pip_calls()), 2)
        self.assertEqual(hashlib.sha256(self.state.read_bytes()).digest(), digest)
        self.assertEqual(self.state.stat().st_mtime_ns, modified)
        self.assertEqual([line for line in second.stdout.splitlines() if 'PSYCOPG' in line],
                         ['PSYCOPG DEVOPS OK ✅ (3.3.5)'])

    def test_newer_version_without_python_rebuild(self):
        first = self.run_block()
        self.assertEqual(first.returncode, 0, first.stderr)
        second = self.run_block(TEST_AVAILABLE='3.3.6')
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(json.loads(self.state.read_text()),
                         {'psycopg': '3.3.6', 'psycopg-binary': '3.3.6'})
        self.assertEqual(len(self.pip_calls()), 2)
        self.assertIn('PSYCOPG DEVOPS OK ✅ (3.3.6)', second.stdout)
        self.assertIn('🔧 UPDATE PSYCOPG DEVOPS (3.3.5 → 3.3.6)', second.stdout)
        self.assertNotIn('INSTALL/UPDATE PYTHON 3 DEV', second.stdout)

    def test_disabled_blocks_do_not_install_or_import(self):
        for environment in ({'PYTHON': '0'}, {'ENV_DEVOPS': '0'}):
            with self.subTest(environment=environment):
                result = self.run_block(**environment)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.observed_calls(), [])
                self.assertFalse(self.state.exists())
                self.assertFalse(self.profile.exists())

    def test_pip_failure_stops_before_import_and_profile(self):
        result = self.run_block(TEST_FAULT='pip')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Échec de l'installation ou mise à jour de Psycopg", result.stderr)
        self.assertEqual(len(self.pip_calls()), 1)
        self.assertFalse(any('import psycopg; print(psycopg.__version__)' in arguments
                             for arguments in self.observed_calls()))
        self.assertNotIn('PSYCOPG DEVOPS OK', result.stdout)
        self.assertFalse(self.profile.exists())

    def test_import_failure_stops_before_success_and_profile(self):
        result = self.run_block(TEST_FAULT='import')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('Échec du contrôle de Psycopg', result.stderr)
        self.assertTrue(any('import psycopg; print(psycopg.__version__)' in arguments
                            for arguments in self.observed_calls()))
        self.assertNotIn('PSYCOPG DEVOPS OK', result.stdout)
        self.assertFalse(self.profile.exists())

    def test_metadata_failure_stops_before_pip(self):
        result = self.run_block(TEST_FAULT='metadata')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('Échec de la lecture de la version installée de Psycopg', result.stderr)
        self.assertEqual(self.pip_calls(), [])
        self.assertNotIn('PSYCOPG DEVOPS OK', result.stdout)
        self.assertFalse(self.profile.exists())


if __name__ == '__main__':
    unittest.main()
