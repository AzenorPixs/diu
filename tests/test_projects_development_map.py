#!/usr/bin/env python3
"""Initialisation sans écrasement de la carte de développement des projets."""
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
DEVOPS_USER="../${TEST_CASE_ROOT#/}"
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
        (self.template / '.gitignore').write_text('ignored\n', encoding='utf-8')
        (self.template / 'ORCHESTRATED_CODING.md').write_text('Template\n', encoding='utf-8')
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

    def test_missing_map_is_personalized_and_owned_in_every_mode(self):
        for index, mode in enumerate(('Yes', 'No', '')):
            with self.subTest(mode=mode):
                project = self.project(f'project {index}', mode)
                self.assert_success(self.run_shell(f'sync_project "project {index}"'))
                destination = project / 'DEVELOPMENT_MAP.md'
                self.assertEqual(destination.read_text(), f'Projet & Test project {index}\n')
                self.assertIn(str(destination), (self.path / 'owners.txt').read_text())

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

    def test_second_sync_preserves_new_map_after_model_changes(self):
        project = self.project()
        self.assert_success(self.run_shell('sync_project "project with spaces"'))
        destination = project / 'DEVELOPMENT_MAP.md'
        before = self.attributes(destination)
        (self.path / 'owners.txt').write_text('', encoding='utf-8')
        self.source.write_text('nouveau modèle\n', encoding='utf-8')
        self.assert_success(self.run_shell('sync_project "project with spaces"'))
        self.assertEqual(destination.read_text(), 'Projet & Test project with spaces\n')
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

    def test_missing_or_directory_source_fails_before_copy(self):
        self.source.unlink()
        for kind in ('missing', 'directory'):
            with self.subTest(kind=kind):
                if kind == 'directory':
                    self.source.mkdir()
                project = self.project(kind)
                result = self.run_shell(f'sync_project {kind}')
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('DEVELOPMENT_MAP.md', result.stderr)
                self.assertEqual((project / 'AGENTS.md').read_text(), 'original\n')
                self.assertFalse((project / '.gitignore').exists())
                self.assertFalse((project / 'DEVELOPMENT_MAP.md').exists())
                self.assertFalse((self.path / 'owners.txt').exists())

    def test_grouped_sync_initializes_only_missing_maps_and_is_repeatable(self):
        missing = self.project('a-missing', 'Yes')
        present = self.project('b-present')
        destination = present / 'DEVELOPMENT_MAP.md'
        destination.write_text('local\n', encoding='utf-8')
        before = self.attributes(destination)
        self.assert_success(self.run_shell('sync_project_all'))
        new_map = missing / 'DEVELOPMENT_MAP.md'
        self.assertEqual(new_map.read_text(), 'Projet & Test a-missing\n')
        new_before = self.attributes(new_map)
        self.source.unlink()
        self.assert_success(self.run_shell('sync_project_all'))
        self.assertEqual(self.attributes(new_map), new_before)
        self.assertEqual(destination.read_text(), 'local\n')
        self.assertEqual(self.attributes(destination), before)
        self.assertNotIn(str(destination), (self.path / 'owners.txt').read_text())

    def test_grouped_failure_does_not_block_later_project_with_existing_map(self):
        self.source.unlink()
        missing = self.project('a-missing')
        present = self.project('b-present')
        destination = present / 'DEVELOPMENT_MAP.md'
        destination.write_text('local\n', encoding='utf-8')
        before = self.attributes(destination)
        result = self.run_shell('sync_project_all')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('DEVELOPMENT_MAP.md', result.stderr)
        self.assertEqual((missing / 'AGENTS.md').read_text(), 'original\n')
        self.assertEqual((present / 'AGENTS.md').read_text(), 'Projet & Test b-present\n')
        self.assertEqual(destination.read_text(), 'local\n')
        self.assertEqual(self.attributes(destination), before)

    def test_copy_failure_is_reported_without_false_success(self):
        project = self.project()
        result = self.run_shell(r'''
cp() {
    if [[ "$3" == */DEVELOPMENT_MAP.md && "$4" == "$ENV_DEVOPS_PROJECTS_ROOT/project with spaces/" ]]; then
        return 1
    fi
    command cp "$@"
}
sync_project "project with spaces"
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de synchroniser le fichier : DEVELOPMENT_MAP.md', result.stderr)
        self.assertNotIn('synchronisé avec succès', result.stdout)
        self.assertFalse((project / 'DEVELOPMENT_MAP.md').exists())


if __name__ == '__main__':
    unittest.main()
