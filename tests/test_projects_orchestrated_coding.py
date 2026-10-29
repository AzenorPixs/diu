#!/usr/bin/env python3
"""Mode de développement des projets, avec configurations synthétiques."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PRELUDE = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
source "$TEST_ROOT/modules/projects/git.sh"
print_error() { printf '%s\n' "$*" >&2; }
print_title() { :; }
print_info() { :; }
print_success() { printf 'SUCCESS\n'; }
chown() { :; }
DEVOPS_USER=tester
DEVOPS_GROUP=tester
DEVOPS_PROJECTS_ROOT="$1"
read() {
    if [[ "${2:-}" == -p ]]; then printf 'QUESTION:%s\n' "$3" >&2; fi
    builtin read "$@"
}
'''


class ProjectsOrchestratedCodingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT)
        self.addCleanup(self.temporary.cleanup)
        self.path = Path(self.temporary.name)
        self.project = self.path / 'project with spaces'
        self.project.mkdir()
        self.config = self.project / 'project.env'

    def run_shell(self, script, input_text='', *arguments):
        return subprocess.run(
            ['bash', '-Eeuo', 'pipefail', '-c', PRELUDE + script, 'bash',
             str(self.path), *map(str, arguments)],
            env={**{k: v for k, v in os.environ.items() if not k.startswith('GIT_')},
                 'TEST_ROOT': str(ROOT), 'HOME': str(self.path),
                 'GIT_CONFIG_SYSTEM': str(self.path / 'system.gitconfig'),
                 'GIT_CONFIG_GLOBAL': str(self.path / 'global.gitconfig')},
            input=input_text,
            text=True, capture_output=True, timeout=15, check=False,
        )

    def write_config(self, mode=None, legacy=False):
        text = ('PROJECT_ID="project with spaces"\nPROJECT_NAME="Test project"\n'
                'PROJECT_TYPE=BASH\nPROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=No\n'
                '# Other settings\nOTHER_SETTING="preserved text"\n'
                'LOCAL_DEFAULT_BRANCH=main\nGIT_USER_NAME=Tester\n'
                'GIT_USER_EMAIL=tester@example.test\n')
        if mode is not None:
            text += f'PROJECT_ORCHESTRATED_CODING={mode}\n'
        if legacy:
            text += ('REMOTE_CLONE_OWNER=owner\nREMOTE_CLONE_REPOSITORY=repository\n'
                     'REMOTE_CLONE_NAME=upstream\n')
        self.config.write_text(text, encoding='utf-8')
        return text

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_reader_missing_file_and_missing_variable_ignore_shell_value(self):
        script = 'PROJECT_ORCHESTRATED_CODING=Yes\nproject_orchestrated_coding_get "$2"\n'
        self.assertEqual(self.run_shell(script, '', self.config).stdout, 'No\n')
        self.config.write_text('OTHER_SETTING=unchanged\n', encoding='utf-8')
        before = self.config.stat()
        result = self.run_shell(script, '', self.config)
        self.assert_success(result)
        self.assertEqual(result.stdout, 'No\n')
        self.assertEqual(self.config.stat().st_mtime_ns, before.st_mtime_ns)
        self.assertEqual(self.config.stat().st_ino, before.st_ino)

    def test_reader_literal_forms_and_empty_values(self):
        for raw, expected in (('Yes', 'Yes'), ('No', 'No'), ('"Yes"', 'Yes'),
                              ("'No'", 'No'), ('', 'No'), ('""', 'No'),
                              ("''", 'No'), ('"Yes" # comment', 'Yes')):
            with self.subTest(raw=raw):
                self.config.write_text(
                    f'  export PROJECT_ORCHESTRATED_CODING= {raw}  ', encoding='utf-8')
                result = self.run_shell('project_orchestrated_coding_get "$2"', '', self.config)
                self.assert_success(result)
                self.assertEqual(result.stdout, expected + '\n')

    def test_reader_does_not_execute_other_lines_or_shell_expressions(self):
        marker = self.path / 'executed'
        for assignment, status in (('Yes', 0), ('$(touch "$TEST_MARKER")', 1)):
            with self.subTest(assignment=assignment):
                self.config.write_text(
                    f'touch "$TEST_MARKER"\nPROJECT_ORCHESTRATED_CODING={assignment}\n',
                    encoding='utf-8')
                result = self.run_shell(
                    'TEST_MARKER="$3"\nproject_orchestrated_coding_get "$2"',
                    '', self.config, marker)
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertFalse(marker.exists())
                self.assertNotIn('touch', result.stderr)

    def test_reader_rejects_invalid_values_and_non_regular_files(self):
        for raw in ('yes', '1', 'invalid-private-value', 'Yes extra', 'Yes#extra'):
            with self.subTest(raw=raw):
                self.config.write_text(f'PROJECT_ORCHESTRATED_CODING={raw}\n', encoding='utf-8')
                result = self.run_shell('project_orchestrated_coding_get "$2"', '', self.config)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, '')
                self.assertNotIn(raw, result.stderr)
        result = self.run_shell('project_orchestrated_coding_get "$2"', '', self.project)
        self.assertNotEqual(result.returncode, 0)

    def test_reader_unreadable_file_fails_without_leaking_contents(self):
        self.write_config('Yes')
        self.config.chmod(0)
        self.addCleanup(self.config.chmod, 0o600)
        result = self.run_shell('project_orchestrated_coding_get "$2"', '', self.config)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, '')
        self.assertIn('Impossible de lire', result.stderr)

    def test_prompt_keeps_default_and_retries_invalid_input(self):
        result = self.run_shell('project_orchestrated_coding_prompt Yes', '\n')
        self.assert_success(result)
        self.assertEqual(result.stdout, 'Yes\n')
        result = self.run_shell('project_orchestrated_coding_prompt No', 'yes\n1\nYes\n')
        self.assert_success(result)
        self.assertEqual(result.stdout, 'Yes\n')
        self.assertEqual(result.stderr.count('QUESTION:'), 3)
        self.assertEqual(result.stderr.count('doit valoir Yes ou No'), 2)

    def test_update_new_configuration_defaults_to_no(self):
        result = self.run_shell('update_projects "project with spaces"', 'New project\n\n\n\n\n')
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING [No]', result.stderr)
        text = self.config.read_text(encoding='utf-8')
        self.assertIn('PROJECT_ORCHESTRATED_CODING=No\n', text)
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o660)

    def test_update_preserves_existing_yes_and_other_settings(self):
        self.write_config('Yes')
        result = self.run_shell('update_projects "project with spaces"', '\n' * 5)
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING [Yes]', result.stderr)
        text = self.config.read_text(encoding='utf-8')
        self.assertIn('PROJECT_ORCHESTRATED_CODING=Yes\n', text)
        self.assertIn('# Other settings\nOTHER_SETTING="preserved text"\n', text)
        self.assertIn('GIT_USER_EMAIL=tester@example.test\n', text)

    def test_update_historical_project_ignores_inherited_yes(self):
        self.write_config()
        result = self.run_shell(
            'PROJECT_ORCHESTRATED_CODING=Yes\nupdate_projects "project with spaces"', '\n' * 5)
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING [No]', result.stderr)
        self.assertIn('PROJECT_ORCHESTRATED_CODING=No\n', self.config.read_text())

    def test_update_changes_both_modes_and_is_idempotent(self):
        self.write_config('No')
        for mode in ('Yes', 'No', 'No'):
            with self.subTest(mode=mode):
                result = self.run_shell('update_projects "project with spaces"', '\n' * 4 + mode + '\n')
                self.assert_success(result)
                text = self.config.read_text()
                self.assertIn(f'PROJECT_ORCHESTRATED_CODING={mode}\n', text)
                self.assertEqual(text.count('PROJECT_ORCHESTRATED_CODING='), 1)

    def test_update_retries_invalid_value_and_preserves_file_on_eof(self):
        before = self.write_config('No')
        result = self.run_shell('update_projects "project with spaces"', '\n' * 4 + 'invalid\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), before)
        self.assertNotIn('SUCCESS', result.stdout)
        result = self.run_shell('update_projects "project with spaces"', '\n' * 4 + 'invalid\nYes\n')
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING=Yes\n', self.config.read_text())

    def test_update_invalid_stored_mode_fails_without_rewriting(self):
        before = self.write_config('invalid-private-value')
        result = self.run_shell('update_projects "project with spaces"', '\n' * 5)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), before)
        self.assertNotIn('invalid-private-value', result.stderr)

    def test_two_updates_in_same_shell_do_not_share_mode(self):
        self.write_config('Yes')
        other = self.path / 'other'
        other.mkdir()
        (other / 'project.env').write_text('PROJECT_NAME=Other\n', encoding='utf-8')
        result = self.run_shell(
            'update_projects "project with spaces"\nupdate_projects other', '\n' * 10)
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING=No\n', (other / 'project.env').read_text())

    def test_creation_uses_real_questionnaire_and_does_not_copy_template_mode(self):
        template = self.path / 'datas' / 'template'
        template.mkdir(parents=True)
        (template / 'README.md').write_text('# Template\n', encoding='utf-8')
        (template / 'project.env').write_text('PROJECT_ORCHESTRATED_CODING=Yes\n', encoding='utf-8')
        script = r'''
DEVOPS_USER="../${DEVOPS_PROJECTS_ROOT#/}"
check_devops_user() { return 0; }
install() { mkdir -p "${!#}"; }
projects_template_openspec() { :; }
projects_template_devops() { :; }
create_project new
'''
        result = self.run_shell(script, 'New\n\n\n\n\n')
        self.assert_success(result)
        self.assertIn('PROJECT_ORCHESTRATED_CODING [No]', result.stderr)
        self.assertIn('PROJECT_ORCHESTRATED_CODING=No\n', (self.path / 'new' / 'project.env').read_text())

    def test_legacy_clone_configuration_preserves_or_changes_mode(self):
        for old, answer, expected in (('Yes', '', 'Yes'), (None, '', 'No'), ('No', 'Yes', 'Yes')):
            with self.subTest(old=old, answer=answer):
                self.write_config(old, legacy=True)
                result = self.run_shell('git_update_legacy "project with spaces" clone',
                                        '\n' * 3 + answer + '\n' + '\n' * 30)
                self.assert_success(result)
                self.assertIn(f'PROJECT_ORCHESTRATED_CODING={expected}\n', self.config.read_text())
                self.assertRegex(result.stdout, rf'PROJECT_ORCHESTRATED_CODING\s+: {expected}')
                self.assertIn('REMOTE_CLONE_OWNER=owner\n', self.config.read_text())

    def test_git_local_update_preserves_mode_without_asking(self):
        self.write_config('Yes')
        result = self.run_shell('git_update "project with spaces"', '\n' * 3)
        self.assert_success(result)
        self.assertNotIn('PROJECT_ORCHESTRATED_CODING', result.stderr)
        self.assertIn('PROJECT_ORCHESTRATED_CODING=Yes\n', self.config.read_text())

    def test_local_clone_preserves_value_or_historical_absence(self):
        for mode, destination in (('Yes', 'copy-yes'), (None, 'copy-old')):
            with self.subTest(mode=mode):
                self.write_config(mode)
                result = self.run_shell(f'clone_project "project with spaces" {destination}')
                self.assert_success(result)
                text = (self.path / destination / 'project.env').read_text()
                if mode is None:
                    self.assertNotIn('PROJECT_ORCHESTRATED_CODING=', text)
                else:
                    self.assertIn('PROJECT_ORCHESTRATED_CODING=Yes\n', text)


if __name__ == '__main__':
    unittest.main()
