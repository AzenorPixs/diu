#!/usr/bin/env python3
"""Préservation de la carte de développement et du dossier local de tests."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PRELUDE = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { :; }
print_success() { printf '%s\n' "$*"; }
chown() { printf '%s\n' "$@" >> "$TEST_CASE_ROOT/owners.txt"; }
ENV_DEVOPS_USER="../${TEST_CASE_ROOT#/}"
DEVOPS_GROUP=tester
ENV_DEVOPS_PROJECTS_ROOT="$TEST_CASE_ROOT/datas"
'''


class ProjectsDevelopmentMapTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(dir=ROOT)
        self.addCleanup(temporary.cleanup)
        self.path = Path(temporary.name)
        self.projects = self.path / 'datas'
        self.template = self.projects / 'template'
        self.template.mkdir(parents=True)
        (self.template / 'AGENTS.md').write_text('Template template\n', encoding='utf-8')
        (self.template / 'CODING_RULES.md').write_text('Template template\n', encoding='utf-8')
        (self.template / '.gitignore').write_text('ignored\n', encoding='utf-8')
        (self.template / 'synthetic-document.md').write_text('Template\n', encoding='utf-8')
        self.source = self.template / 'DEVELOPMENT_MAP.md'
        self.source.write_text('Template template\n', encoding='utf-8')

    def project(self, name='project with spaces', mode='No'):
        project = self.projects / name
        project.mkdir()
        (project / 'project.env').write_text(
            f'PROJECT_ID="{name}"\nPROJECT_NAME="Projet & Test"\n'
            f'PROJECT_ORCHESTRATED_CODING={mode}\n', encoding='utf-8')
        (project / 'AGENTS.md').write_text('original\n', encoding='utf-8')
        return project

    def run_shell(self, script):
        return subprocess.run(
            ['bash', '-Eeuo', 'pipefail', '-c', PRELUDE + script],
            env=dict(os.environ, TEST_ROOT=str(ROOT), TEST_CASE_ROOT=str(self.path),
                     TMPDIR=str(self.path)),
            text=True, capture_output=True, timeout=15, check=False)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    @staticmethod
    def attributes(path):
        metadata = path.lstat()
        return tuple(getattr(metadata, name) for name in
                     ('st_ino', 'st_mode', 'st_uid', 'st_gid', 'st_mtime_ns'))

    def test_missing_map_is_not_created_in_any_mode(self):
        for index, mode in enumerate(('Yes', 'No', '')):
            with self.subTest(mode=mode):
                project = self.project(f'project {index}', mode)
                self.assert_success(self.run_shell(f'sync_project "project {index}"'))
                self.assertFalse((project / 'DEVELOPMENT_MAP.md').exists())

    def test_cab_tests_created_empty_without_copying_template(self):
        source = self.template / '.cab-tests'
        source.mkdir()
        (source / 'source.txt').write_text('source', encoding='utf-8')
        project = self.project()
        self.assert_success(self.run_shell('sync_project "project with spaces"'))
        destination = project / '.cab-tests'
        self.assertTrue(destination.is_dir())
        self.assertEqual(list(destination.iterdir()), [])
        self.assertIn(str(destination), (self.path / 'owners.txt').read_text())

    def test_cab_tests_preserved_and_created_in_group_sync(self):
        existing = self.project('existing') / '.cab-tests'
        existing.mkdir()
        existing.chmod(0o750)
        data = existing / 'local.txt'
        data.write_text('local', encoding='utf-8')
        before = self.attributes(existing)
        missing = self.project('missing') / '.cab-tests'
        self.assert_success(self.run_shell('sync_project_all'))
        self.assertEqual(data.read_text(), 'local')
        self.assertEqual(self.attributes(existing), before)
        self.assertTrue(missing.is_dir())
        self.assertEqual(list(missing.iterdir()), [])
        self.assertNotIn(str(existing), (self.path / 'owners.txt').read_text())

    def test_cab_tests_file_reports_error(self):
        project = self.project()
        destination = project / '.cab-tests'
        destination.write_text('local', encoding='utf-8')
        result = self.run_shell('sync_project "project with spaces"')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de créer le répertoire .cab-tests', result.stderr)
        self.assertEqual(destination.read_text(), 'local')

    def test_changelog_and_devops_are_preserved_or_absent_in_both_modes(self):
        for filename in ('CHANGELOG.md', 'DEVOPS.md'):
            (self.template / filename).write_text('modèle\n', encoding='utf-8')
        present = self.project('present')
        absent = self.project('absent')
        for filename in ('CHANGELOG.md', 'DEVOPS.md'):
            (present / filename).write_text('local\n', encoding='utf-8')
        before = {name: self.attributes(present / name) for name in ('CHANGELOG.md', 'DEVOPS.md')}
        self.assert_success(self.run_shell('sync_project present'))
        self.assert_success(self.run_shell('sync_project_all'))
        for filename in ('CHANGELOG.md', 'DEVOPS.md'):
            self.assertEqual((present / filename).read_text(), 'local\n')
            self.assertEqual(self.attributes(present / filename), before[filename])
            self.assertFalse((absent / filename).exists())

    def test_unmanaged_directories_are_preserved_or_absent_in_both_modes(self):
        names = ('.git', '.worktree', 'output')
        present = self.project('present')
        absent = self.project('absent')
        for name in names:
            (self.template / name).mkdir()
            (self.template / name / 'source').write_text('source', encoding='utf-8')
            (present / name).mkdir()
            (present / name / 'local').write_text('local', encoding='utf-8')
        before = {name: self.attributes(present / name) for name in names}
        self.assert_success(self.run_shell('sync_project present'))
        self.assert_success(self.run_shell('sync_project_all'))
        for name in names:
            self.assertEqual((present / name / 'local').read_text(), 'local')
            self.assertEqual(self.attributes(present / name), before[name])
            self.assertFalse((absent / name).exists())

    def test_existing_map_preserves_content_and_attributes_without_source(self):
        project = self.project()
        destination = project / 'DEVELOPMENT_MAP.md'
        destination.write_text('Template template local\n', encoding='utf-8')
        destination.chmod(0o640)
        before = self.attributes(destination)
        for source_present in (True, False):
            with self.subTest(source_present=source_present):
                if not source_present:
                    self.source.unlink()
                self.assert_success(self.run_shell('sync_project "project with spaces"'))
                self.assertEqual(destination.read_text(), 'Template template local\n')
                self.assertEqual(self.attributes(destination), before)
                self.assertNotIn(str(destination), (self.path / 'owners.txt').read_text())

    def test_directory_and_symlinks_are_preserved_even_without_source(self):
        self.source.unlink()
        target = self.path / 'local.md'
        target.write_text('Template template local\n', encoding='utf-8')
        target_before = self.attributes(target)
        for kind in ('directory', 'symlink', 'dangling'):
            with self.subTest(kind=kind):
                project = self.project(kind)
                destination = project / 'DEVELOPMENT_MAP.md'
                if kind == 'directory':
                    destination.mkdir()
                    (destination / 'local.md').write_text('local\n', encoding='utf-8')
                else:
                    destination.symlink_to(target if kind == 'symlink' else self.path / 'absent')
                before = self.attributes(destination)
                self.assert_success(self.run_shell(f'sync_project {kind}'))
                self.assertEqual(self.attributes(destination), before)
                self.assertNotIn(str(destination), (self.path / 'owners.txt').read_text())
                if kind == 'directory':
                    self.assertEqual((destination / 'local.md').read_text(), 'local\n')
                else:
                    self.assertEqual(destination.readlink(), target if kind == 'symlink'
                                     else self.path / 'absent')
        self.assertEqual(target.read_text(), 'Template template local\n')
        self.assertEqual(self.attributes(target), target_before)

    def test_group_sync_does_not_require_or_copy_source(self):
        self.source.unlink()
        missing = self.project('a-missing')
        present = self.project('b-present')
        destination = present / 'DEVELOPMENT_MAP.md'
        destination.write_text('local\n', encoding='utf-8')
        before = self.attributes(destination)
        self.assert_success(self.run_shell('sync_project_all'))
        self.assertFalse((missing / 'DEVELOPMENT_MAP.md').exists())
        self.assertEqual(destination.read_text(), 'local\n')
        self.assertEqual(self.attributes(destination), before)
        self.assertEqual((missing / 'AGENTS.md').read_text(), 'Projet & Test a-missing\n')
        self.assertEqual((present / 'AGENTS.md').read_text(), 'Projet & Test b-present\n')


if __name__ == '__main__':
    unittest.main()
