#!/usr/bin/env python3
"""Contrat OpenSpec des projets, avec su et OpenSpec entièrement simulés."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ProjectsTemplateOpenspecTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-openspec-')
        self.addCleanup(self.temporary.cleanup)
        self.fixture = Path(self.temporary.name)
        self.projects = self.fixture / 'projects'
        self.project = self.projects / 'application'
        self.project.mkdir(parents=True)
        self.binary_directory = self.fixture / 'bin'
        self.binary_directory.mkdir()
        self.su_log = self.fixture / 'su-calls'
        self.tool_log = self.fixture / 'openspec-calls'
        binary = self.binary_directory / 'openspec'
        binary.write_text('''#!/bin/sh
printf '%s|%s\\n' "$PWD" "$*" >> "$TEST_TOOL_LOG"
if [ "$TEST_TOOL_FAILURE" != 0 ]; then exit "$TEST_TOOL_FAILURE"; fi
if [ "$1" = init ]; then mkdir openspec; fi
''', encoding='utf-8')
        binary.chmod(0o755)
        self.environment = dict(os.environ, ENV_DEVOPS_USER='devops-test', OPENCODE='1',
                                DEVOPS_PROJECTS_ROOT=str(self.projects),
                                TEST_FAKE_BIN=str(self.binary_directory),
                                TEST_SU_LOG=str(self.su_log), TEST_TOOL_LOG=str(self.tool_log),
                                TEST_SU_FAILURE='0', TEST_TOOL_FAILURE='0', TEST_ID_FAILURE='0')

    def run_template(self, *arguments, extra='', shell='bash'):
        script = r'''
source "$1/modules/projects/template.sh"
shift
print_error() { printf '%s\n' "$*" >&2; }
print_success() { printf '%s\n' "$*"; }
id() { [[ "$TEST_ID_FAILURE" == 0 ]]; }
su() {
    [[ "$#" == 4 && "$1" == - && "$2" == "$ENV_DEVOPS_USER" && "$3" == -c ]] || return 90
    printf '%s\n' "$2" >> "$TEST_SU_LOG"
    if [[ "$TEST_SU_FAILURE" != 0 ]]; then return "$TEST_SU_FAILURE"; fi
    (
        cd -- "$TEST_FAKE_BIN" || return 91
        PATH="$TEST_FAKE_BIN:$PATH" "$TEST_LOGIN_SHELL" -c "$4"
    )
}
'''
        environment = dict(self.environment, TEST_LOGIN_SHELL=shell)
        return subprocess.run(['bash', '-Eeuo', 'pipefail', '-c',
                               script + extra + '\nprojects_template_openspec "$@"',
                               'bash', str(ROOT), *arguments],
                              env=environment, text=True, capture_output=True, check=False)

    def calls(self):
        return self.tool_log.read_text().splitlines() if self.tool_log.exists() else []

    def test_initialization_options_and_repeated_call_updates(self):
        for opencode, expected in (('1', 'init --tools opencode --profile custom'),
                                   ('0', 'init --profile custom')):
            with self.subTest(opencode=opencode):
                project = self.projects / f'app-{opencode}'
                project.mkdir()
                self.environment['OPENCODE'] = opencode
                result = self.run_template(project.name)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.calls()[-1], f'{project}|{expected}')
                self.assertEqual(self.su_log.read_text().splitlines()[-1], 'devops-test')
                self.assertTrue((project / 'openspec').is_dir())
                result = self.run_template(project.name)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.calls()[-1], f'{project}|update')
        self.assertEqual(len(self.calls()), 4)

    def test_existing_openspec_updates_independently_of_opencode(self):
        (self.project / 'openspec').mkdir()
        for value in ('0', '1', 'invalid', None):
            with self.subTest(value=value):
                if value is None:
                    self.environment.pop('OPENCODE', None)
                else:
                    self.environment['OPENCODE'] = value
                result = self.run_template('application')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.calls()[-1], f'{self.project}|update')

    def test_special_characters_remain_literal_in_login_shell(self):
        project = self.projects / "projet d'essai $(touch injected) `touch injected` & $PATH"
        project.mkdir()
        for shell in ('bash', 'dash'):
            with self.subTest(shell=shell):
                result = self.run_template(project.name, shell=shell)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.calls()[-1].split('|')[0], str(project))
                self.assertFalse((self.binary_directory / 'injected').exists())

    def test_invalid_arguments_do_not_switch_user(self):
        for arguments in ((), ('',), ('.',), ('..',), ('../elsewhere',),
                          ('line\nbreak',), ('application', 'extra'), ('missing',)):
            with self.subTest(arguments=arguments):
                result = self.run_template(*arguments)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.su_log.exists())
                self.assertEqual(self.calls(), [])

    def test_invalid_opencode_and_user_do_not_switch_user(self):
        for value in ('invalid', '', None):
            with self.subTest(opencode=value):
                if value is None:
                    self.environment.pop('OPENCODE', None)
                else:
                    self.environment['OPENCODE'] = value
                self.assertNotEqual(self.run_template('application').returncode, 0)
                self.assertFalse(self.su_log.exists())
        self.environment['OPENCODE'] = '1'
        for user in ('', 'bad user', '-bad', 'root;touch injected'):
            self.environment['ENV_DEVOPS_USER'] = user
            self.assertNotEqual(self.run_template('application').returncode, 0)
            self.assertFalse(self.su_log.exists())
        self.environment['ENV_DEVOPS_USER'] = 'devops-test'
        self.environment['TEST_ID_FAILURE'] = '1'
        self.assertNotEqual(self.run_template('application').returncode, 0)
        self.assertFalse(self.su_log.exists())

    def test_symbolic_or_non_directory_targets_are_rejected(self):
        link = self.projects / 'linked'
        link.symlink_to(self.project, target_is_directory=True)
        self.assertNotEqual(self.run_template('linked').returncode, 0)
        target = self.project / 'openspec'
        target.symlink_to(self.fixture / 'missing')
        self.assertNotEqual(self.run_template('application').returncode, 0)
        target.unlink()
        target.write_text('ordinary file\n')
        self.assertNotEqual(self.run_template('application').returncode, 0)
        self.assertFalse(self.su_log.exists())

    def test_su_tool_and_missing_binary_failures_do_not_announce_success(self):
        for variable in ('TEST_SU_FAILURE', 'TEST_TOOL_FAILURE'):
            with self.subTest(variable=variable):
                self.environment[variable] = '7'
                result = self.run_template('application')
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('OpenSpec échouée', result.stderr)
                self.assertNotIn('OpenSpec préparé', result.stdout)
                self.assertTrue(self.project.exists())
                self.environment[variable] = '0'
        result = self.run_template('application', extra="su() { return 127; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('OpenSpec préparé', result.stdout)

    def test_all_is_a_single_project_and_configuration_is_not_sourced(self):
        project = self.projects / 'all'
        project.mkdir()
        (project / 'project.env').write_text('exit 99\n', encoding='utf-8')
        result = self.run_template('all')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [f'{project}|init --tools opencode --profile custom'])
        self.assertFalse((self.project / 'openspec').exists())

    def test_relative_projects_root_is_resolved_before_login(self):
        self.environment['DEVOPS_PROJECTS_ROOT'] = os.path.relpath(self.projects, ROOT)
        result = self.run_template('application')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [f'{self.project}|init --tools opencode --profile custom'])


if __name__ == '__main__':
    unittest.main()
