#!/usr/bin/env python3
"""Préparation OpenSpec isolée : aucun su ni outil OpenSpec réel."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'


class DevopsOpenspecTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = SCRIPT.read_text(encoding='utf-8')
        guard_start = source.index('  if [ "$OPENSPEC" -eq 1 ]')
        start = source.index(
            '      # Initialisation ou mise à jour des commandes OpenSpec du domicile DevOps',
            guard_start)
        end = source.index('\n\tif [ "$PYTHON" -eq 1 ]', start)
        guard = source[guard_start:source.index('\n\n', guard_start)]
        cls.block = guard + '\n' + source[start:end]
        if start < source.index('echo "OPENSPEC OK ✅ ($OPENSPEC_VERSION)"', guard_start):
            raise AssertionError('Préparation placée avant la vérification du binaire')

    def run_block(self, home, *, opencode='1', enabled='1', user='devops',
                  su_status=0, tool_status=0, cd_status=0):
        code = r'''
set -Eeuo pipefail
su() {
    printf 'SU_ARG=<%s>\n' "$1" "$2" "$3"
    if [ "$#" -ne 4 ] || [ "$1" != - ] ||
       [ "$2" != "$ENV_DEVOPS_USER" ] || [ "$3" != -c ]; then
        return 90
    fi
    if [ "$TEST_SU_STATUS" -ne 0 ]; then
        return "$TEST_SU_STATUS"
    fi
    /bin/bash --noprofile --norc -c '
        cd() {
            printf "CD_ARG=<%s>\n" "$@"
            if [ "$#" -ne 1 ] || [ "$1" != "/home/$ENV_DEVOPS_USER" ]; then
                return 91
            fi
            if [ "$TEST_CD_STATUS" -ne 0 ]; then
                return "$TEST_CD_STATUS"
            fi
            builtin cd -- "$TEST_HOME"
        }
        openspec() {
            printf "OPEN_ARG=<%s>\n" "$@"
            printf "OPEN_CWD=<%s>\n" "$PWD"
            printf "OPEN_PATH=<%s>\n" "$PATH"
            if [ "$TEST_TOOL_STATUS" -ne 0 ]; then
                mkdir -p openspec
                printf "écriture partielle\n" > openspec/partial.txt
            fi
            return "$TEST_TOOL_STATUS"
        }
        eval "$1"
    ' bash "$4"
}
'''
        code += self.block + '\nprintf "AFTER_BLOCK\\n"\n'
        env = {'PATH': os.defpath, 'LC_ALL': 'C.UTF-8',
               'HOME': '/controlled/unrelated-home',
               'ENV_DEVOPS_USER': user, 'OPENSPEC': enabled,
               'TEST_HOME': str(home), 'TEST_SU_STATUS': str(su_status),
               'TEST_TOOL_STATUS': str(tool_status),
               'TEST_CD_STATUS': str(cd_status)}
        if opencode is not None:
            env['OPENCODE'] = opencode
        return subprocess.run(
            ['/bin/bash', '--noprofile', '--norc', '-c', code],
            cwd=ROOT, env=env, text=True, capture_output=True, timeout=10)

    def assert_command(self, result, home, arguments, user='devops'):
        self.assertEqual(result.returncode, 0, result.stderr)
        observed = [line for line in result.stdout.splitlines()
                    if line.startswith('OPEN_ARG=')]
        self.assertEqual(observed, [f'OPEN_ARG=<{arg}>' for arg in arguments])
        self.assertEqual(result.stdout.count('SU_ARG=<->'), 1)
        self.assertIn(f'SU_ARG=<{user}>', result.stdout)
        self.assertIn('SU_ARG=<-c>', result.stdout)
        self.assertIn(f'CD_ARG=</home/{user}>', result.stdout)
        self.assertIn(f'OPEN_CWD=<{home}>', result.stdout)
        self.assertIn(
            f'OPEN_PATH=</home/{user}/node/current/bin:'
            f'/home/{user}/.local/npm/bin:{os.defpath}>', result.stdout)
        self.assertIn('Commandes OpenSpec préparées ✅', result.stdout)
        self.assertIn('AFTER_BLOCK', result.stdout)
        self.assertEqual(result.stderr, '')

    def assert_failure(self, result):
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('préparation OpenSpec échouée', result.stderr)
        self.assertNotIn('Commandes OpenSpec préparées ✅', result.stdout)
        self.assertNotIn('AFTER_BLOCK', result.stdout)

    def test_init_with_opencode(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            home = Path(tmp)
            self.assert_command(self.run_block(home), home,
                                ['init', '--tools', 'opencode', '--profile', 'custom'])

    def test_init_without_opencode(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            home = Path(tmp)
            self.assert_command(self.run_block(home, opencode='0'), home,
                                ['init', '--profile', 'custom'])

    def test_update_ignores_opencode(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            home = Path(tmp)
            (home / 'openspec').mkdir()
            for opencode in ('0', '1', 'invalid', None):
                with self.subTest(opencode=opencode):
                    self.assert_command(self.run_block(home, opencode=opencode),
                                        home, ['update'])

    def test_disabled_block_calls_nothing(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            result = self.run_block(Path(tmp), enabled='0', opencode=None)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'AFTER_BLOCK\n')
            self.assertEqual(result.stderr, '')

    def test_invalid_or_missing_opencode_stops_initialisation(self):
        injection = "bad'$(printf INJECTION >&2)" + chr(96) + 'printf INJECTION >&2' + chr(96)
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            for value in (None, '', '2', injection):
                with self.subTest(value=value):
                    result = self.run_block(Path(tmp), opencode=value)
                    self.assert_failure(result)
                    self.assertIn('OPENCODE doit valoir 0 ou 1', result.stderr)
                    self.assertNotIn('OPEN_ARG=', result.stdout)
                    self.assertNotIn('INJECTION', result.stderr)

    def test_home_and_path_are_literal(self):
        user = "dev ops'$(printf INJECTION >&2)" + chr(96) + 'printf INJECTION >&2' + chr(96)
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            home = Path(tmp)
            self.assert_command(self.run_block(home, user=user), home,
                                ['init', '--tools', 'opencode', '--profile', 'custom'],
                                user=user)

    def test_su_failure_stops_before_tool(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            result = self.run_block(Path(tmp), su_status=23)
            self.assert_failure(result)
            self.assertNotIn('CD_ARG=', result.stdout)
            self.assertNotIn('OPEN_ARG=', result.stdout)

    def test_cd_failure_stops_before_tool(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
            result = self.run_block(Path(tmp), cd_status=24)
            self.assert_failure(result)
            self.assertNotIn('OPEN_ARG=', result.stdout)

    def test_tool_failure_preserves_partial_writes(self):
        for existing in (False, True):
            with self.subTest(existing=existing):
                with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-openspec-test-') as tmp:
                    home = Path(tmp)
                    if existing:
                        (home / 'openspec').mkdir()
                    result = self.run_block(home, tool_status=25)
                    self.assert_failure(result)
                    self.assertIn(f'OPEN_ARG=<{"update" if existing else "init"}>',
                                  result.stdout)
                    self.assertEqual((home / 'openspec/partial.txt').read_text(
                        encoding='utf-8'), 'écriture partielle\n')


if __name__ == '__main__':
    unittest.main()
