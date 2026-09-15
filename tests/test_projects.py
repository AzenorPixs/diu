#!/usr/bin/env python3
"""Tests ciblés de création de projet depuis un modèle local."""
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ProjectCreationTests(unittest.TestCase):
    def test_github_clone_calls_creation_update_then_clone_and_merges_remote_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
create_project() {
    printf 'create\n'
    mkdir -p "${DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${DEVOPS_PROJECTS_ROOT}/$1/replaced.txt"
    printf 'kept\n' > "${DEVOPS_PROJECTS_ROOT}/$1/template-only.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_update() {
    printf 'update\n'
    printf '%s\n' \
        'REMOTE_GITHUB_BASE_URL=https://github.example.test' \
        'REMOTE_GITHUB_OWNER=owner' \
        'REMOTE_GITHUB_REPOSITORY=repository' \
        'REMOTE_GITHUB_BRANCH=main' \
        > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_git_clone() {
    printf 'clone\n'
    mkdir -p "$4/.git" "$4/nested/.git" "$4/worktree"
    printf 'remote\n' > "$4/replaced.txt"
    printf 'hidden\n' > "$4/.hidden"
    printf 'nested git\n' > "$4/nested/.git/config"
    printf 'gitdir: elsewhere\n' > "$4/worktree/.git"
}
chown() { :; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$2"
github_clone project
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            project_path = projects_root / 'project'
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'create\nupdate\nclone\n')
            self.assertEqual((project_path / 'replaced.txt').read_text(encoding='utf-8'), 'remote\n')
            self.assertEqual((project_path / 'template-only.txt').read_text(encoding='utf-8'), 'kept\n')
            self.assertEqual((project_path / '.hidden').read_text(encoding='utf-8'), 'hidden\n')
            self.assertFalse((project_path / '.git').exists())
            self.assertFalse((project_path / 'nested' / '.git').exists())
            self.assertFalse((project_path / 'worktree' / '.git').exists())

    def test_github_clone_preserves_initialized_project_when_clone_or_merge_fails(self):
        for failing_step in ('clone', 'merge'):
            with self.subTest(failing_step=failing_step), tempfile.TemporaryDirectory() as temporary_directory:
                projects_root = Path(temporary_directory) / 'projects'
                script = r'''
source "$1/modules/projects/git.sh"
print_error() { :; }
print_success() { :; }
create_project() {
    mkdir -p "${DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_update() {
    printf '%s\n' \
        'REMOTE_GITHUB_BASE_URL=https://github.example.test' \
        'REMOTE_GITHUB_OWNER=owner' \
        'REMOTE_GITHUB_REPOSITORY=repository' \
        'REMOTE_GITHUB_BRANCH=main' \
        > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_git_clone() { [[ "$3" == merge ]] && mkdir -p "$4"; [[ "$3" != clone ]]; }
cp() { [[ "$3" != merge ]]; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$2"
github_clone project
'''.replace('$3', failing_step)
                result = subprocess.run(
                    ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                    text=True,
                    capture_output=True,
                    check=False,
                )

                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertEqual(
                    (projects_root / 'project' / 'kept.txt').read_text(encoding='utf-8'),
                    'template\n',
                )

    def test_gitlab_clone_calls_creation_update_then_clone_and_merges_remote_files(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
create_project() {
    printf 'create\n'
    mkdir -p "${DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${DEVOPS_PROJECTS_ROOT}/$1/replaced.txt"
    printf 'kept\n' > "${DEVOPS_PROJECTS_ROOT}/$1/template-only.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf 'update\n'
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_git_clone() {
    printf 'clone\n'
    mkdir -p "$4/.git" "$4/nested/.git" "$4/worktree"
    printf 'remote\n' > "$4/replaced.txt"
    printf 'hidden\n' > "$4/.hidden"
    printf 'nested git\n' > "$4/nested/.git/config"
    printf 'gitdir: elsewhere\n' > "$4/worktree/.git"
}
chown() { :; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$2"
gitlab_clone project
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            project_path = projects_root / 'project'
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'create\nupdate\nclone\n')
            self.assertEqual((project_path / 'replaced.txt').read_text(encoding='utf-8'), 'remote\n')
            self.assertEqual((project_path / 'template-only.txt').read_text(encoding='utf-8'), 'kept\n')
            self.assertEqual((project_path / '.hidden').read_text(encoding='utf-8'), 'hidden\n')
            self.assertFalse((project_path / '.git').exists())
            self.assertFalse((project_path / 'nested' / '.git').exists())
            self.assertFalse((project_path / 'worktree' / '.git').exists())

    def test_gitlab_clone_preserves_initialized_project_when_remote_clone_fails(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { :; }
print_success() { :; }
create_project() {
    mkdir -p "${DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_git_clone() { return 1; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$2"
gitlab_clone project
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(
                (projects_root / 'project' / 'kept.txt').read_text(encoding='utf-8'),
                'template\n',
            )

    def test_gitlab_clone_preserves_initialized_project_when_merge_preparation_fails(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { :; }
print_success() { :; }
create_project() {
    mkdir -p "${DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_git_clone() { mkdir -p "$4"; }
cp() { return 1; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$2"
gitlab_clone project
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(
                (projects_root / 'project' / 'kept.txt').read_text(encoding='utf-8'),
                'template\n',
            )

    def test_clone_project_copies_content_without_git_and_updates_project_identifiers(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            source_path = projects_root / 'source'
            source_path.mkdir(parents=True)
            (source_path / '.git').mkdir()
            (source_path / '.git' / 'config').write_text('source git\n', encoding='utf-8')
            (source_path / '.hidden').write_text('hidden\n', encoding='utf-8')
            (source_path / 'project.env').write_text(
                '# Configuration\n'
                'PROJECT_ID=source\n'
                'PROJECT_NAME="Projet source"\n'
                'REMOTE_REPOSITORY=source\n'
                'REMOTE_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_OWNER=rootforgejo\n'
                'REMOTE_NAME=origin\n'
                'REMOTE_DEFAULT_BRANCH=main\n'
                'REMOTE_FORGEJO_REPOSITORY=source\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_FORGEJO_OWNER=rootforgejo\n'
                'REMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\n'
                'REMOTE_FORGEJO_SSL_VERIFY=No\n'
                'REMOTE_GITLAB_REPOSITORY=source\n'
                'REMOTE_GITHUB_REPOSITORY=source\n'
                'CUSTOM=value\n',
                encoding='utf-8',
            )
            nested_path = source_path / 'nested'
            nested_path.mkdir()
            (nested_path / 'file.txt').write_text('content\n', encoding='utf-8')
            (nested_path / '.git').mkdir()
            (nested_path / '.git' / 'config').write_text('nested git\n', encoding='utf-8')

            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*"; }
print_success() { :; }
chown() { :; }
DEVOPS_USER=devops
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$2"
clone_project source destination
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            destination_path = projects_root / 'destination'
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((destination_path / '.hidden').read_text(encoding='utf-8'), 'hidden\n')
            self.assertEqual(
                (destination_path / 'nested' / 'file.txt').read_text(encoding='utf-8'),
                'content\n',
            )
            self.assertFalse((destination_path / '.git').exists())
            self.assertFalse((destination_path / 'nested' / '.git').exists())
            self.assertEqual(
                (destination_path / 'project.env').read_text(encoding='utf-8'),
                '# Configuration\n'
                'PROJECT_ID=destination\n'
                'PROJECT_NAME="Projet source"\n'
                'REMOTE_REPOSITORY=destination\n'
                'REMOTE_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_OWNER=rootforgejo\n'
                'REMOTE_NAME=origin\n'
                'REMOTE_DEFAULT_BRANCH=main\n'
                'REMOTE_FORGEJO_REPOSITORY=destination\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_FORGEJO_OWNER=rootforgejo\n'
                'REMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\n'
                'REMOTE_FORGEJO_SSL_VERIFY=No\n'
                'REMOTE_GITLAB_REPOSITORY=destination\n'
                'REMOTE_GITHUB_REPOSITORY=destination\n'
                'CUSTOM=value\n',
            )

            (source_path / 'project.env').write_text(
                'PROJECT_ID=source\nCUSTOM=value\n', encoding='utf-8'
            )
            result = subprocess.run(
                [
                    'bash',
                    '-c',
                    script.replace('source destination', 'source without-remote'),
                    'bash',
                    str(ROOT),
                    str(projects_root),
                ],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (projects_root / 'without-remote' / 'project.env').read_text(encoding='utf-8'),
                'PROJECT_ID=without-remote\nCUSTOM=value\n',
            )

    def test_clone_project_refuses_invalid_preconditions_without_destination(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            source_path = projects_root / 'source'
            source_path.mkdir(parents=True)
            (source_path / 'project.env').write_text('PROJECT_ID=source\n', encoding='utf-8')

            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_success() { :; }
chown() { :; }
DEVOPS_USER=devops
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$2"
clone_project source destination
'''
            destination_path = projects_root / 'destination'
            destination_path.mkdir()
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertFalse((destination_path / 'project.env').exists())

    def test_sync_project_copies_only_managed_resources_and_personalizes_markdown(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            template_path = temporary_path / 'datas' / 'template'
            broker_source_path = temporary_path / 'cab' / 'src'
            project_path = temporary_path / 'projects' / 'projet-test'

            (template_path / '.opencode' / 'commands').mkdir(parents=True)
            (template_path / '.opencode' / 'config').mkdir()
            (template_path / '.opencode' / 'skills').mkdir()
            (template_path / 'PROMPTS').mkdir()
            project_path.mkdir(parents=True)
            (broker_source_path / 'nested').mkdir(parents=True)
            (broker_source_path / '__pycache__').mkdir()

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
            (broker_source_path / 'nested' / 'broker.py').write_text(
                'source CAB\n', encoding='utf-8'
            )
            (broker_source_path / 'README.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (broker_source_path / '__pycache__' / 'broker.pyc').write_text(
                'cache source\n', encoding='utf-8'
            )
            (project_path / 'project.env').write_text(
                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                encoding='utf-8',
            )
            (project_path / 'README.md').write_text('Template template\n', encoding='utf-8')
            (project_path / 'AGENTS.md').write_text('ancienne version\n', encoding='utf-8')
            (project_path / '.opencode' / 'broker' / 'nested').mkdir(parents=True)
            (project_path / '.opencode' / 'broker' / '__pycache__').mkdir()
            (project_path / '.opencode' / 'broker' / 'nested' / 'broker.py').write_text(
                'ancienne version CAB\n', encoding='utf-8'
            )
            (project_path / '.opencode' / 'broker' / '__pycache__' / 'stale.pyc').write_text(
                'cache destination\n', encoding='utf-8'
            )

            devops_user = f'../tmp/{temporary_path.name}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*"; }
print_success() { :; }
chown() { :; }
BROKER_SOURCE_PATH="$4"
sync_project_broker_source_path() { printf '%s\n' "${BROKER_SOURCE_PATH}"; }
DEVOPS_USER="$2"
DEVOPS_GROUP=devops
DEVOPS_PROJECTS_ROOT="$3"
sync_project projet-test
'''
            result = subprocess.run(
                [
                    'bash',
                    '-c',
                    script,
                    'bash',
                    str(ROOT),
                    devops_user,
                    str(project_path.parent),
                    str(broker_source_path),
                ],
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
            self.assertEqual(
                (project_path / '.opencode' / 'broker' / 'nested' / 'broker.py').read_text(
                    encoding='utf-8'
                ),
                'source CAB\n',
            )
            self.assertFalse((project_path / '.opencode' / 'broker' / '__pycache__').exists())
            self.assertEqual(
                (project_path / '.opencode' / 'broker' / 'README.md').read_text(encoding='utf-8'),
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
