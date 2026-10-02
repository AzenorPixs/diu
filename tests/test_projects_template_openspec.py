#!/usr/bin/env python3
"""Contrat OpenSpec des projets, avec su et OpenSpec entièrement simulés."""
import os
from pathlib import Path
import shlex
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
if [ "${PWD##*/}" = "${TEST_TOOL_FAILED_PROJECT:-}" ]; then exit 7; fi
if [ "$1" = init ]; then mkdir openspec; fi
''', encoding='utf-8')
        binary.chmod(0o755)
        self.environment = dict(os.environ, ENV_DEVOPS_USER='devops-test', OPENCODE='1',
                                DEVOPS_PROJECTS_ROOT=str(self.projects),
                                TEST_FAKE_BIN=str(self.binary_directory),
                                TEST_SU_LOG=str(self.su_log), TEST_TOOL_LOG=str(self.tool_log),
                                TEST_SU_FAILURE='0', TEST_TOOL_FAILURE='0', TEST_ID_FAILURE='0')

    def run_template(self, *arguments, extra='', shell='bash', batch=False):
        script = r'''
source "$1/modules/projects/template.sh"
shift
print_error() { printf '%s\n' "$*" >&2; }
print_success() { printf '%s\n' "$*"; }
print_info() { printf '%s\n' "$*"; }
id() {
    if [[ "$1" == -un ]]; then
        printf '%s\n' "${TEST_CURRENT_USER:-$ENV_DEVOPS_USER}"
    else
        [[ "$TEST_ID_FAILURE" == 0 ]]
    fi
}
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
        function = 'projects_template_openspec_all' if batch else 'projects_template_openspec'
        return subprocess.run(['bash', '-Eeuo', 'pipefail', '-c',
                               script + extra + f'\n{function} "$@"',
                               'bash', str(ROOT), *arguments],
                              env=environment, text=True, capture_output=True, check=False)

    def calls(self):
        return self.tool_log.read_text().splitlines() if self.tool_log.exists() else []

    def configured_project(self, name):
        project = self.projects / name
        project.mkdir(exist_ok=True)
        (project / 'project.env').write_text(
            f'PROJECT_ID={shlex.quote(name)}\nPROJECT_NAME=Example\nPROJECT_TYPE=NODE\n'
            'PROJECT_DOCKERED=0\nPROJECT_DEBIAN_PACKAGE=No\n', encoding='utf-8')
        return project

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

    def test_batch_selects_same_projects_as_devops_without_recursion(self):
        selected = {'template', 'all', '.hidden', '..double', 'with spaces'}
        for name in selected:
            self.configured_project(name)
        nested = self.projects / 'template' / 'nested'
        nested.mkdir()
        (nested / 'project.env').write_text('PROJECT_ID=nested\n')
        missing = self.configured_project('missing')
        (missing / 'project.env').write_text('PROJECT_ID=missing\n')
        blank = self.configured_project('blank')
        with (blank / 'project.env').open('a') as stream:
            stream.write('PROJECT_NAME=""\n')
        wrong = self.configured_project('wrong')
        with (wrong / 'project.env').open('a') as stream:
            stream.write('PROJECT_ID=another\n')
        expression = self.configured_project('expression')
        marker = self.fixture / 'executed'
        with (expression / 'project.env').open('a') as stream:
            stream.write(f'PROJECT_NAME=$(touch {marker})\n')
        with (self.projects / 'template' / 'project.env').open('a') as stream:
            stream.write(f'touch {marker}\n')
        linked_env = self.projects / 'linked-env'
        linked_env.mkdir()
        (linked_env / 'project.env').symlink_to(self.projects / 'template' / 'project.env')
        (self.projects / 'linked-project').symlink_to(self.projects / 'template', target_is_directory=True)
        self.configured_project('bad\nname')
        self.environment.update(PROJECT_ID='application', PROJECT_NAME='Inherited',
                                PROJECT_TYPE='NODE', PROJECT_DOCKERED='0', PROJECT_DEBIAN_PACKAGE='No')
        result = self.run_template(batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual({Path(call.split('|')[0]).name for call in self.calls()}, selected)
        self.assertEqual(len(self.calls()), 5)
        self.assertIn('5 sélectionné(s), 5 réussi(s), 8 ignoré(s), 0 échoué(s)', result.stdout)
        self.assertFalse(marker.exists())
        self.assertFalse((nested / 'openspec').exists())
        self.assertTrue((self.projects / 'all' / 'openspec').is_dir())

    def test_batch_mixes_initialization_update_and_repeated_execution(self):
        for value, expected in (('0', 'init --profile custom'),
                                ('1', 'init --tools opencode --profile custom')):
            with self.subTest(opencode=value):
                self.projects = self.fixture / f'projects-{value}'
                self.projects.mkdir()
                self.environment.update(DEVOPS_PROJECTS_ROOT=str(self.projects), OPENCODE=value)
                existing = self.configured_project('existing')
                (existing / 'openspec').mkdir()
                self.configured_project('all')
                self.configured_project('.fresh')
                result = self.run_template(batch=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                calls = {Path(path).name: command for path, command in
                         (line.split('|') for line in self.calls()[-3:])}
                self.assertEqual(calls, {'existing': 'update', 'all': expected, '.fresh': expected})
                self.assertIn('3 sélectionné(s), 3 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)
                result = self.run_template(batch=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(all(line.endswith('|update') for line in self.calls()[-3:]))
                self.assertTrue(all(user == 'devops-test' for user in self.su_log.read_text().splitlines()))

    def test_batch_continues_after_failure_and_preserves_existing_files(self):
        failing = self.configured_project('a-failing')
        (failing / 'openspec').mkdir()
        document = failing / 'openspec' / 'kept.md'
        document.write_text('preserved\n')
        self.configured_project('z-success')
        self.environment['TEST_TOOL_FAILED_PROJECT'] = 'a-failing'
        result = self.run_template(batch=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual([Path(line.split('|')[0]).name for line in self.calls()],
                         ['a-failing', 'z-success'])
        self.assertIn('2 sélectionné(s), 1 réussi(s), 1 ignoré(s), 1 échoué(s)', result.stdout)
        self.assertIn('échouée pour le projet : a-failing', result.stderr)
        self.assertEqual(document.read_text(), 'preserved\n')
        self.assertTrue((self.projects / 'z-success' / 'openspec').is_dir())

    def test_batch_no_eligible_projects_returns_success_without_su(self):
        result = self.run_template(batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Aucun projet éligible', result.stdout)
        self.assertIn('0 sélectionné(s), 0 réussi(s), 1 ignoré(s), 0 échoué(s)', result.stdout)
        self.assertFalse(self.su_log.exists())
        self.project.rmdir()
        result = self.run_template(batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('0 sélectionné(s), 0 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)

    def test_batch_invalid_arguments_user_or_root_fail_before_processing(self):
        self.configured_project('application')
        self.assertNotEqual(self.run_template('extra', batch=True).returncode, 0)
        for user in ('', 'bad user', '-bad'):
            self.environment['ENV_DEVOPS_USER'] = user
            self.assertNotEqual(self.run_template(batch=True).returncode, 0)
        self.environment['ENV_DEVOPS_USER'] = 'devops-test'
        self.environment['TEST_ID_FAILURE'] = '1'
        self.assertNotEqual(self.run_template(batch=True).returncode, 0)
        self.environment['TEST_ID_FAILURE'] = '0'
        if os.geteuid() != 0:
            self.environment['TEST_CURRENT_USER'] = 'other-user'
            self.assertNotEqual(self.run_template(batch=True).returncode, 0)
            self.environment.pop('TEST_CURRENT_USER')
        self.environment['DEVOPS_PROJECTS_ROOT'] = str(self.fixture / 'absent')
        self.assertNotEqual(self.run_template(batch=True).returncode, 0)
        self.assertFalse(self.su_log.exists())
        self.assertEqual(self.calls(), [])

    def test_relative_projects_root_is_resolved_before_login(self):
        self.environment['DEVOPS_PROJECTS_ROOT'] = os.path.relpath(self.projects, ROOT)
        result = self.run_template('application')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [f'{self.project}|init --tools opencode --profile custom'])


if __name__ == '__main__':
    unittest.main()
