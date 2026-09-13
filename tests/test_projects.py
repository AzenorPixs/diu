#!/usr/bin/env python3
"""Tests ciblés de création de projet depuis un modèle local."""
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ProjectCreationTests(unittest.TestCase):
    def test_sync_project_copies_only_managed_resources_and_personalizes_markdown(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            template_path = temporary_path / 'datas' / 'template'
            project_path = temporary_path / 'projects' / 'projet-test'

            (template_path / '.opencode' / 'commands').mkdir(parents=True)
            (template_path / '.opencode' / 'config').mkdir()
            (template_path / '.opencode' / 'skills').mkdir()
            (template_path / 'PROMPTS').mkdir()
            project_path.mkdir(parents=True)

            (template_path / 'AGENTS.md').write_text('Template template\n', encoding='utf-8')
            (template_path / 'DEVOPS.md').write_text('Template\n', encoding='utf-8')
            (template_path / '.gitignore').write_text('template\n', encoding='utf-8')
            (template_path / '.opencode' / 'commands' / 'command.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (template_path / '.opencode' / 'config' / 'config.txt').write_text(
                'source\n', encoding='utf-8'
            )
            (template_path / '.opencode' / 'skills' / 'SKILL.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (template_path / 'PROMPTS' / 'INDEX.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (project_path / 'project.env').write_text(
                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                encoding='utf-8',
            )
            (project_path / 'README.md').write_text('Template template\n', encoding='utf-8')
            (project_path / 'AGENTS.md').write_text('ancienne version\n', encoding='utf-8')

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*"; }
print_success() { :; }
chown() { :; }
DEVOPS_USER="$2"
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$3"
sync_project projet-test
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), devops_user, str(project_path.parent)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (project_path / 'AGENTS.md').read_text(encoding='utf-8'),
                'Projet Test projet-test\n',
            )
            self.assertEqual(
                (project_path / '.opencode' / 'commands' / 'command.md').read_text(encoding='utf-8'),
                'Projet Test projet-test\n',
            )
            self.assertEqual(
                (project_path / 'PROMPTS' / 'INDEX.md').read_text(encoding='utf-8'),
                'Projet Test projet-test\n',
            )
            self.assertEqual(
                (project_path / 'README.md').read_text(encoding='utf-8'),
                'Template template\n',
            )

    def test_sync_project_leaves_destination_unchanged_when_template_is_missing(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            project_path = temporary_path / 'projects' / 'projet-test'
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                encoding='utf-8',
            )
            (project_path / 'AGENTS.md').write_text('ancienne version\n', encoding='utf-8')

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_success() { :; }
chown() { :; }
DEVOPS_USER="$2"
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$3"
sync_project projet-test
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), devops_user, str(project_path.parent)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(
                (project_path / 'AGENTS.md').read_text(encoding='utf-8'),
                'ancienne version\n',
            )

    def test_sync_project_all_selects_valid_projects_and_excludes_template(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'datas'
            template_path = projects_root / 'template'

            for directory in ('commands', 'config', 'skills'):
                (template_path / '.opencode' / directory).mkdir(parents=True, exist_ok=True)
            (template_path / 'PROMPTS').mkdir()
            for filename in ('AGENTS.md', 'DEVOPS.md', '.gitignore'):
                (template_path / filename).write_text('source\n', encoding='utf-8')

            for project_id in ('first', 'second'):
                project_path = projects_root / project_id
                project_path.mkdir()
                (project_path / 'project.env').write_text(
                    f'PROJECT_ID={project_id}\nPROJECT_NAME="{project_id}"\n',
                    encoding='utf-8',
                )

            invalid_project = projects_root / 'invalid'
            invalid_project.mkdir()
            (invalid_project / 'project.env').write_text(
                'PROJECT_ID=other\nPROJECT_NAME="Invalid"\n', encoding='utf-8'
            )

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_info() { :; }
sync_project() { printf '%s\n' "$1"; }
DEVOPS_USER="$2"
DEVOPS_PROJECTS_ROOT="/home/${DEVOPS_USER}/datas"
sync_project_all
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), devops_user],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'first\nsecond\n')

    def test_sync_project_all_continues_after_a_project_failure(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'datas'

            for project_id in ('first', 'second'):
                project_path = projects_root / project_id
                project_path.mkdir(parents=True)
                (project_path / 'project.env').write_text(
                    f'PROJECT_ID={project_id}\nPROJECT_NAME="{project_id}"\n',
                    encoding='utf-8',
                )

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_info() { :; }
sync_project_template_is_valid() { return 0; }
sync_project() { printf '%s\n' "$1"; [[ "$1" != first ]]; }
DEVOPS_USER="$2"
sync_project_all
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), devops_user],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(result.stdout, 'first\nsecond\n')

    def test_create_project_leaves_no_directory_when_template_is_missing(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            missing_template_user = f'../tmp/{temporary_path.name}/missing'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
check_devops_user() { return 0; }
install() { printf 'install-called\n'; }
DEVOPS_USER="$2"
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$3"
create_project projet-test
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), missing_template_user, str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(result.stdout, '')
            self.assertFalse((projects_root / 'projet-test').exists())

    def test_create_project_copies_template_and_personalizes_markdown(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            template_path = temporary_path / 'datas' / 'template'
            projects_root = temporary_path / 'projects'
            template_path.mkdir(parents=True)
            (template_path / 'README.md').write_text(
                '# Template\ntemplate\n', encoding='utf-8'
            )
            (template_path / 'project.env').write_text(
                'PROJECT_NAME="Ignoré"\n', encoding='utf-8'
            )
            nested_path = template_path / 'documentation'
            nested_path.mkdir()
            (nested_path / 'guide.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (template_path / 'script.sh').write_text(
                'Template template\n', encoding='utf-8'
            )

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*"; }
print_success() { :; }
check_devops_user() { return 0; }
install() { mkdir -p "${!#}"; }
chown() { :; }
update_projects() {
    printf 'PROJECT_ID=%q\nPROJECT_NAME=%q\n' "$1" 'Projet & modèle' > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
DEVOPS_USER="$2"
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$3"
create_project projet-test
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), devops_user, str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            project_path = projects_root / 'projet-test'
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (project_path / 'README.md').read_text(encoding='utf-8'),
                '# Projet & modèle\nprojet-test\n',
            )
            self.assertEqual(
                (project_path / 'documentation' / 'guide.md').read_text(encoding='utf-8'),
                'Projet & modèle projet-test\n',
            )
            self.assertEqual(
                (project_path / 'script.sh').read_text(encoding='utf-8'),
                'Template template\n',
            )
            project_env = (project_path / 'project.env').read_text(encoding='utf-8')
            self.assertIn('PROJECT_NAME=', project_env)
            self.assertNotIn('Ignoré', project_env)


if __name__ == '__main__':
    unittest.main()
