#!/usr/bin/env python3
"""Copies du protocole piloté sur des projets et modèles synthétiques."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PRELUDE = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_title() { :; }
print_info() { :; }
print_success() { printf '%s\n' "$*"; }
chown() { printf '%s\n' "$@" >> "$TEST_CASE_ROOT/owners.txt"; }
check_devops_user() { return 0; }
install() { mkdir -p -- "${!#}"; }
projects_template_openspec() { :; }
projects_template_devops() { :; }
ENV_DEVOPS_USER="../${TEST_CASE_ROOT#/}"
DEVOPS_GROUP=tester
ENV_DEVOPS_PROJECTS_ROOT="$TEST_CASE_ROOT/datas"
PROJECT_ORCHESTRATED_CODING=Yes
'''


class ProjectsOrchestratedCopyTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT)
        self.addCleanup(self.temporary.cleanup)
        self.path = Path(self.temporary.name)
        self.projects = self.path / 'datas'
        self.template = self.projects / 'template'
        (self.template / 'PROMPTS').mkdir(parents=True)
        (self.template / 'AGENTS.md').write_text('Template template\n', encoding='utf-8')
        (self.template / 'CODING_RULES.md').write_text('Template template\n', encoding='utf-8')
        (self.template / 'DEVELOPMENT_MAP.md').write_text('Template template\n', encoding='utf-8')
        (self.template / '.gitignore').write_text('ignored\n', encoding='utf-8')
        (self.template / 'README.md').write_text('Template template\n', encoding='utf-8')
        (self.template / 'pyproject.toml').write_text('[project]\n', encoding='utf-8')
        self.source = self.template / 'synthetic-document.md'
        self.source.write_text('Template template\n', encoding='utf-8')
        (self.template / 'project.env').write_text(
            'PROJECT_ORCHESTRATED_CODING=Yes\n', encoding='utf-8')

    def run_shell(self, script, answers=''):
        return subprocess.run(
            ['bash', '-Eeuo', 'pipefail', '-c', PRELUDE + script],
            env=dict(os.environ, TEST_ROOT=str(ROOT), TEST_CASE_ROOT=str(self.path),
                     TMPDIR=str(self.path)),
            input=answers, text=True, capture_output=True, timeout=15, check=False,
        )

    def project(self, name, mode):
        path = self.projects / name
        path.mkdir()
        text = f'PROJECT_ID="{name}"\nPROJECT_NAME="Projet Test"\n'
        if mode is not None:
            text += f'PROJECT_ORCHESTRATED_CODING={mode}\n'
        (path / 'project.env').write_text(text, encoding='utf-8')
        (path / 'AGENTS.md').write_text('original\n', encoding='utf-8')
        return path

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_sync_yes_preserves_existing_document(self):
        project = self.project('project with spaces', "'Yes'")
        destination = project / 'synthetic-document.md'
        destination.write_text('old\n', encoding='utf-8')
        result = self.run_shell('sync_project "project with spaces"')
        self.assert_success(result)
        self.assertEqual(destination.read_text(), 'old\n')
        self.assertNotIn(str(destination), (self.path / 'owners.txt').read_text())
        self.assertEqual((project / 'project.env').read_text().count('PROJECT_ORCHESTRATED_CODING='), 1)

    def test_sync_no_absent_empty_preserve_existing_document_and_attributes(self):
        for index, mode in enumerate(('No', None, '', '""')):
            with self.subTest(mode=mode):
                project = self.project(f'project-{index}', mode)
                destination = project / 'synthetic-document.md'
                destination.write_text('Template template local\n', encoding='utf-8')
                destination.chmod(0o640)
                before = destination.stat()
                config = (project / 'project.env').read_bytes()
                result = self.run_shell(f'sync_project project-{index}')
                self.assert_success(result)
                after = destination.stat()
                self.assertEqual(destination.read_text(), 'Template template local\n')
                for field in ('st_ino', 'st_mode', 'st_uid', 'st_gid', 'st_mtime_ns'):
                    self.assertEqual(getattr(before, field), getattr(after, field), field)
                self.assertNotIn(str(destination), (self.path / 'owners.txt').read_text())
                self.assertEqual((project / 'project.env').read_bytes(), config)

    def test_sync_no_or_historical_never_creates_document_even_without_source(self):
        for source_exists in (True, False):
            if not source_exists:
                self.source.unlink()
            for index, mode in enumerate(('No', None, '')):
                with self.subTest(source=source_exists, mode=mode):
                    name = f'project-{source_exists}-{index}'
                    project = self.project(name, mode)
                    self.assert_success(self.run_shell(f'sync_project {name}'))
                    self.assertFalse((project / 'synthetic-document.md').exists())

    def test_sync_yes_accepts_missing_or_directory_source(self):
        self.source.unlink()
        for directory in (False, True):
            with self.subTest(directory=directory):
                if directory:
                    self.source.mkdir()
                name = f'project-{directory}'
                project = self.project(name, 'Yes')
                result = self.run_shell(f'sync_project {name}')
                self.assert_success(result)
                self.assertEqual((project / 'AGENTS.md').read_text(), f'Projet Test {name}\n')
                self.assertFalse((project / 'synthetic-document.md').exists())

    def test_sync_invalid_mode_fails_before_copy_or_shell_evaluation(self):
        project = self.project('invalid', '$(touch "$TEST_CASE_ROOT/marker")')
        result = self.run_shell('sync_project invalid')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('doit valoir Yes ou No', result.stderr)
        self.assertNotIn('touch', result.stderr)
        self.assertEqual((project / 'AGENTS.md').read_text(), 'original\n')
        self.assertFalse((self.path / 'marker').exists())

    def test_sync_all_decides_per_project_and_continues_after_failure(self):
        bad = self.project('a-invalid', 'invalid')
        yes = self.project('b-piloted', 'Yes')
        no = self.project('c-autonomous', 'No')
        old = self.project('d-historical', None)
        result = self.run_shell('sync_project_all')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((bad / 'AGENTS.md').read_text(), 'original\n')
        self.assertFalse((yes / 'synthetic-document.md').exists())
        for project in (no, old):
            self.assertFalse((project / 'synthetic-document.md').exists())
            self.assertEqual((project / 'AGENTS.md').read_text(), f'Projet Test {project.name}\n')

    def test_sync_all_missing_source_updates_both_modes(self):
        self.source.unlink()
        yes = self.project('a-piloted', 'Yes')
        no = self.project('b-autonomous', 'No')
        result = self.run_shell('sync_project_all')
        self.assert_success(result)
        self.assertEqual((yes / 'AGENTS.md').read_text(), 'Projet Test a-piloted\n')
        self.assertEqual((no / 'AGENTS.md').read_text(), 'Projet Test b-autonomous\n')
        self.assertFalse((no / 'synthetic-document.md').exists())

    def test_creation_real_questionnaire_controls_copy_and_keeps_python_exclusion(self):
        for mode in ('Yes', 'No', ''):
            for project_type in ('BASH', 'PYTHON'):
                with self.subTest(mode=mode, project_type=project_type):
                    name = f'new-{mode}-{project_type}'
                    result = self.run_shell(f'create_project {name}',
                                            f'New\n{project_type}\n\n\n{mode}\n1.0.0\n')
                    self.assert_success(result)
                    project = self.projects / name
                    destination = project / 'synthetic-document.md'
                    self.assertEqual(destination.read_text(), f'New {name}\n')
                    self.assertIn(f'PROJECT_ORCHESTRATED_CODING={mode or "No"}\n',
                                  (project / 'project.env').read_text())
                    self.assertEqual((project / 'pyproject.toml').exists(), project_type == 'PYTHON')

    def test_creation_missing_or_directory_source_only_fails_for_yes(self):
        self.source.unlink()
        for directory in (False, True):
            if directory:
                self.source.mkdir()
            for mode in ('Yes', 'No'):
                with self.subTest(mode=mode, directory=directory):
                    name = f'new-{mode}-{directory}'
                    result = self.run_shell(f'create_project {name}', f'New\n\n\n\n{mode}\n1.0.0\n')
                    project = self.projects / name
                    self.assertTrue((project / 'project.env').exists())
                    self.assertEqual((project / 'synthetic-document.md').is_dir(), directory)
                    self.assert_success(result)

    def test_creation_invalid_persisted_mode_is_rejected_before_copy(self):
        script = r'''
update_projects() {
    printf 'PROJECT_ID=new\nPROJECT_NAME=New\nPROJECT_ORCHESTRATED_CODING=invalid\n' \
        > "$ENV_DEVOPS_PROJECTS_ROOT/new/project.env"
}
create_project new
'''
        result = self.run_shell(script)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('doit valoir Yes ou No', result.stderr)
        self.assertFalse((self.projects / 'new' / 'AGENTS.md').exists())


if __name__ == '__main__':
    unittest.main()
