#!/usr/bin/env python3
"""Exécution isolée du bloc Python : aucun pip ni téléchargement réel."""
import hashlib
import json
import os
import shlex
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
        start = source.index('launch_ocrw() {')
        end = source.index('\nmanage_devops_action() {', start)
        cls.launch = source[start:end]
        parent = source.index('if [ "${ENVIRONMENTS_DEVOPS:-0}" -eq 1 ]\nthen\n')
        cls.activation = source[parent:parent + len('if [ "${ENVIRONMENTS_DEVOPS:-0}" -eq 1 ]\nthen\n')]

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
            'ENVIRONMENTS_DEVOPS': '1', 'PYTHON': '1', 'PYTHON_SERIES': '3.14',
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

    def assert_python_prepared_without_psycopg(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.observed_calls(), [['--version']])
        self.assertEqual(self.pip_calls(), [])
        self.assertNotIn('PSYCOPG', result.stdout)
        self.assertIn('PYTHON 3 DEV OK', result.stdout)
        self.assertNotIn('INSTALL/UPDATE PYTHON 3 DEV', result.stdout)
        self.assertTrue((self.binary_directory / 'python3').is_symlink())
        self.assertEqual((self.binary_directory / 'python3').resolve(),
                         self.binary_directory / 'python3.14')
        self.assertEqual((self.binary_directory / 'pip3').resolve(),
                         self.binary_directory / 'pip3.14')
        self.assertIn(str(self.home / 'python/current'), self.profile.read_text())
        self.assertEqual(self.profile.stat().st_mode & 0o777, 0o644)

    def test_absent_psycopg_is_not_installed(self):
        self.assert_python_prepared_without_psycopg(self.run_block())
        self.assertFalse(self.state.exists())

    def test_second_pass_preserves_existing_packages(self):
        self.state.write_text(json.dumps({'psycopg': '3.3.5', 'psycopg-binary': '3.3.5'}))
        digest = hashlib.sha256(self.state.read_bytes()).digest()
        modified = self.state.stat().st_mtime_ns
        for _ in range(2):
            result = self.run_block()
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('PSYCOPG', result.stdout)
            self.assertTrue(self.profile.exists())
            self.assertEqual(hashlib.sha256(self.state.read_bytes()).digest(), digest)
            self.assertEqual(self.state.stat().st_mtime_ns, modified)
        self.assertEqual(self.observed_calls(), [['--version'], ['--version']])

    def test_newer_version_does_not_update_packages(self):
        self.state.write_text(json.dumps({'psycopg': '3.3.5', 'psycopg-binary': '3.3.5'}))
        before = self.state.read_bytes()
        modified = self.state.stat().st_mtime_ns
        self.assert_python_prepared_without_psycopg(self.run_block(TEST_AVAILABLE='3.3.6'))
        self.assertEqual(self.state.read_bytes(), before)
        self.assertEqual(self.state.stat().st_mtime_ns, modified)

    def test_disabled_blocks_do_not_install_or_import(self):
        for environment in ({'PYTHON': '0'}, {'ENVIRONMENTS_DEVOPS': '0'}):
            with self.subTest(environment=environment):
                result = self.run_block(**environment)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.observed_calls(), [])
                self.assertFalse(self.state.exists())
                self.assertFalse(self.profile.exists())

    def test_unavailable_pip_does_not_block_profile(self):
        self.assert_python_prepared_without_psycopg(self.run_block(TEST_FAULT='pip'))
        self.assertFalse(self.state.exists())

    def test_failed_import_does_not_block_profile(self):
        self.assert_python_prepared_without_psycopg(self.run_block(TEST_FAULT='import'))

    def test_failed_metadata_does_not_block_profile(self):
        self.assert_python_prepared_without_psycopg(self.run_block(TEST_FAULT='metadata'))

    def test_opencode_launch_preserves_tools_and_exec_without_psycopg(self):
        project = self.fixture / 'projects' / 'demo'
        (project / '.opencode/share').mkdir(parents=True)
        code = 'set -Eeuo pipefail\n' + self.launch + r'''
id() { printf '1001\n'; }
stat() { printf '999\n'; }
ensure_docker_image() { [[ "$1" == fixture-image && "$2" == never ]]; }
su() { [[ "$1" == - && "$2" == devops-fixture && "$3" == -c ]]; printf '%s\n' "$4"; }
launch_ocrw demo
'''
        result = subprocess.run(['/bin/bash', '--noprofile', '--norc', '-c', code],
                                cwd=ROOT, env=dict(self.environment,
                                ENV_DEVOPS_PROJECTS_ROOT=str(project.parent),
                                ENV_DOCKER_IMAGE_OPENCODE='fixture-image',
                                ENV_DOCKER_IMAGE_OPENCODE_UPDATE_POLICY='never'),
                                text=True, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = shlex.split(result.stdout)
        self.assertEqual(arguments[:5], ['docker', 'run', '--rm', '-it', '--hostname'])
        self.assertEqual(arguments[arguments.index('--security-opt') + 1],
                         'no-new-privileges:true')
        self.assertEqual(arguments[arguments.index('--group-add') + 1], '999')
        mounts = [arguments[i + 1] for i, value in enumerate(arguments) if value == '-v']
        self.assertEqual(mounts, [
            '/var/run/docker.sock:/var/run/docker.sock',
            '/home/devops/datas/demo:/workspace:rw',
            '/home/devops/datas/demo/.opencode/cache:/home/opencode/.cache/opencode:rw',
            '/home/devops/datas/demo/.opencode/config:/home/opencode/.config/opencode:rw',
            '/home/devops/datas/demo/.opencode/share:/home/opencode/.local/share:rw',
            '/home/devops/datas/demo/.opencode/state:/home/opencode/.local/state/opencode:rw',
            '/home/devops/datas/demo/.opencode/broker:/opt/tools/cab:ro',
            '/home/devops/.local/npm:/opt/devops/npm:ro',
        ])
        container_code = arguments[-1]
        self.assertEqual(arguments[-2], '-c')
        self.assertNotIn('psycopg', container_code.lower())
        self.assertNotIn('pip install', container_code)
        # Exécuter la chaîne interne avec des outils factices, sans conteneur.
        for name in ('apk', 'setpriv', 'opencode'):
            self.executable(self.tools / name, r'''#!/usr/bin/python3 -B
import json
import os
from pathlib import Path
import sys
with Path(os.environ['TEST_CALLS']).open('a', encoding='utf-8') as stream:
    stream.write(json.dumps([Path(sys.argv[0]).name] + sys.argv[1:]) + '\n')
if Path(sys.argv[0]).name == 'setpriv':
    command = sys.argv[sys.argv.index('--') + 1:]
    os.execvp(command[0], command)
''')
        result = subprocess.run(['/bin/sh', '-c', container_code], cwd=ROOT,
                                env=dict(self.environment, OPENCODE_UID='1001',
                                         OPENCODE_GID='1001', DOCKER_GID='999'),
                                text=True, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.observed_calls(), [
            ['apk', 'add', '--no-cache', 'bash', 'build-base', 'ca-certificates',
             'curl', 'docker', 'docker-cli-compose', 'git', 'go', 'libffi-dev',
             'libpq', 'nodejs', 'npm', 'openssl', 'openssl-dev', 'postgresql17-client',
             'python3', 'py3-pip', 'py3-virtualenv', 'py3-pytest', 'ripgrep',
             'shellcheck', 'util-linux'],
            ['setpriv', '--reuid=1001', '--regid=1001', '--groups=999', '--',
             'opencode', '--hostname', '0.0.0.0', '--port', '4096'],
            ['opencode', '--hostname', '0.0.0.0', '--port', '4096'],
        ])


if __name__ == '__main__':
    unittest.main()
