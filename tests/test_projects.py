#!/usr/bin/env python3
"""Tests ciblés de création de projet depuis un modèle local."""
import os
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
    mkdir -p "${ENV_DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/replaced.txt"
    printf 'kept\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/template-only.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_update() {
    printf 'update\n'
    printf '%s\n' \
        'REMOTE_GITHUB_BASE_URL=https://github.example.test' \
        'REMOTE_GITHUB_OWNER=owner' \
        'REMOTE_GITHUB_REPOSITORY=repository' \
        'REMOTE_GITHUB_BRANCH=main' \
        > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
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
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
    mkdir -p "${ENV_DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_update() {
    printf '%s\n' \
        'REMOTE_GITHUB_BASE_URL=https://github.example.test' \
        'REMOTE_GITHUB_OWNER=owner' \
        'REMOTE_GITHUB_REPOSITORY=repository' \
        'REMOTE_GITHUB_BRANCH=main' \
        > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
github_git_clone() { [[ "$3" == merge ]] && mkdir -p "$4"; [[ "$3" != clone ]]; }
cp() { [[ "$3" != merge ]]; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
    mkdir -p "${ENV_DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/replaced.txt"
    printf 'kept\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/template-only.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf 'update\n'
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
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
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
    mkdir -p "${ENV_DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_git_clone() { return 1; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
    mkdir -p "${ENV_DEVOPS_PROJECTS_ROOT}/$1"
    printf 'template\n' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/kept.txt"
    printf 'PROJECT_ID=%s\n' "$1" > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_update() {
    printf '%s\n' \
        'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test' \
        'REMOTE_GITLAB_OWNER=owner' \
        'REMOTE_GITLAB_REPOSITORY=repository' \
        'REMOTE_GITLAB_BRANCH=main' \
        > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
gitlab_git_clone() { mkdir -p "$4"; }
cp() { return 1; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
                'PG_DATABASE=source\n'
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
ENV_DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
                'PG_DATABASE=destination\n'
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
ENV_DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
            project_path = temporary_path / 'projects' / 'projet-test'

            (template_path / 'PROMPTS' / 'nested').mkdir(parents=True)
            project_path.mkdir(parents=True)
            (template_path / 'AGENTS.md').write_text('Template template\n', encoding='utf-8')
            (template_path / 'DEVELOPMENT_MAP.md').write_text('Template template\n', encoding='utf-8')
            (template_path / 'DEVOPS.md').write_text('Template\n', encoding='utf-8')
            (template_path / '.gitignore').write_text('template\n', encoding='utf-8')
            (template_path / 'PROMPTS' / 'nested' / 'INDEX.md').write_text(
                'Template template\n', encoding='utf-8'
            )
            (project_path / 'project.env').write_text(
                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n', encoding='utf-8'
            )
            (project_path / 'README.md').write_text('Template template\n', encoding='utf-8')
            (project_path / 'AGENTS.md').write_text('ancienne version\n', encoding='utf-8')
            (project_path / 'PROMPTS' / 'nested').mkdir(parents=True)
            (project_path / 'PROMPTS' / 'nested' / 'INDEX.md').write_text(
                'ancienne version\n', encoding='utf-8'
            )
            (project_path / 'PROMPTS' / 'local.md').write_text(
                'Template template local\n', encoding='utf-8'
            )

            script = r'''
set -euo pipefail
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
chown() { :; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
sync_project projet-test
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT),
                 f'../{temporary_path.relative_to("/")}', str(project_path.parent)],
                text=True, capture_output=True, check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stderr, '')
            self.assertFalse((project_path / 'DEVOPS.md').exists())
            self.assertFalse((project_path / '.opencode').exists())
            self.assertEqual(
                (project_path / 'AGENTS.md').read_text(encoding='utf-8'),
                'Projet Test projet-test\n',
            )
            self.assertEqual(
                (project_path / '.gitignore').read_text(encoding='utf-8'), 'template\n'
            )
            self.assertEqual(
                (project_path / 'PROMPTS' / 'nested' / 'INDEX.md').read_text(encoding='utf-8'),
                'ancienne version\n',
            )
            self.assertEqual(
                (project_path / 'PROMPTS' / 'local.md').read_text(encoding='utf-8'),
                'Template template local\n',
            )
            self.assertEqual(
                (project_path / 'README.md').read_text(encoding='utf-8'),
                'Template template\n',
            )

    def test_sync_excludes_prompts_with_or_without_source_and_destination(self):
        def snapshot(path):
            if not path.exists():
                return None
            state = {}
            for item in [path, *sorted(path.rglob('*'))]:
                metadata = item.stat()
                state[str(item.relative_to(path))] = (
                    item.read_bytes() if item.is_file() else None,
                    metadata.st_mode, metadata.st_uid, metadata.st_gid,
                    metadata.st_ino, metadata.st_mtime_ns,
                )
            return state

        for operation in ('projet-test', 'all'):
            for source_type in ('absent', 'directory', 'file'):
                for destination_present in (False, True):
                    with self.subTest(operation=operation, source_type=source_type,
                                      destination_present=destination_present):
                        with tempfile.TemporaryDirectory() as temporary_directory:
                            temporary_path = Path(temporary_directory)
                            projects_root = temporary_path / 'datas'
                            template_path = projects_root / 'template'
                            template_path.mkdir(parents=True)
                            for filename in ('AGENTS.md', '.gitignore', 'DEVELOPMENT_MAP.md'):
                                (template_path / filename).write_text(
                                    'Template template\n', encoding='utf-8')
                            source = template_path / 'PROMPTS'
                            if source_type == 'directory':
                                source.mkdir()
                                (source / 'INDEX.md').write_text(
                                    'Template template source\n', encoding='utf-8')
                            elif source_type == 'file':
                                source.write_text('source\n', encoding='utf-8')
                            project_path = projects_root / 'projet-test'
                            project_path.mkdir()
                            (project_path / 'project.env').write_text(
                                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                                encoding='utf-8')
                            destination = project_path / 'PROMPTS'
                            if destination_present:
                                (destination / 'nested').mkdir(parents=True)
                                (destination / 'nested' / 'INDEX.md').write_text(
                                    'Template template local\n', encoding='utf-8')
                                (destination / 'nested' / 'INDEX.md').chmod(0o640)
                                destination.chmod(0o750)
                            before = snapshot(destination)
                            script = r'''
set -euo pipefail
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
print_info() { :; }
chown() { printf '%s\n' "$@"; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
if [[ "$4" == all ]]; then
    sync_project_all
    sync_project_all
else
    sync_project "$4"
    sync_project "$4"
fi
'''
                            result = subprocess.run(
                                ['bash', '-c', script, 'bash', str(ROOT),
                                 f'../{temporary_path.relative_to("/")}',
                                 str(projects_root), operation],
                                text=True, capture_output=True, check=False)
                            self.assertEqual(result.returncode, 0, result.stderr)
                            self.assertEqual(result.stderr, '')
                            self.assertEqual((project_path / 'AGENTS.md').read_text(),
                                             'Projet Test projet-test\n')
                            self.assertEqual(snapshot(destination), before)
                            self.assertNotIn(str(destination), result.stdout.splitlines())

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

            devops_user = f'../{temporary_path.relative_to("/")}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_success() { :; }
chown() { :; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
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

            (template_path / 'PROMPTS').mkdir(parents=True)
            for filename in ('AGENTS.md', '.gitignore', 'DEVELOPMENT_MAP.md'):
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

            devops_user = f'../{temporary_path.relative_to("/")}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_info() { :; }
sync_project() { printf '%s\n' "$1"; }
ENV_DEVOPS_USER="$2"
ENV_DEVOPS_PROJECTS_ROOT="/home/${ENV_DEVOPS_USER}/datas"
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

    def test_sync_preserves_devops_or_leaves_it_absent_with_or_without_template_document(self):
        for operation in ('projet-test', 'all'):
            for source_present in (False, True):
                for destination_present in (False, True):
                    with self.subTest(operation=operation, source_present=source_present,
                                      destination_present=destination_present):
                        with tempfile.TemporaryDirectory() as temporary_directory:
                            temporary_path = Path(temporary_directory)
                            projects_root = temporary_path / 'datas'
                            template_path = projects_root / 'template'
                            project_path = projects_root / 'projet-test'
                            (template_path / 'PROMPTS').mkdir(parents=True)
                            for filename in ('AGENTS.md', '.gitignore', 'DEVELOPMENT_MAP.md'):
                                (template_path / filename).write_text('Template template\n',
                                                                      encoding='utf-8')
                            if source_present:
                                (template_path / 'DEVOPS.md').write_text('modèle\n',
                                                                        encoding='utf-8')
                            project_path.mkdir()
                            (project_path / 'project.env').write_text(
                                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                                encoding='utf-8')
                            document = project_path / 'DEVOPS.md'
                            content = b'Template template - inventaire local\n'
                            if destination_present:
                                document.write_bytes(content)
                                document.chmod(0o640)
                                before = document.stat()

                            script = r'''
set -euo pipefail
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
print_info() { :; }
chown() { printf '%s\n' "$@"; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
if [[ "$4" == all ]]; then
    sync_project_all
    sync_project_all
else
    sync_project "$4"
    sync_project "$4"
fi
'''
                            result = subprocess.run(
                                ['bash', '-c', script, 'bash', str(ROOT),
                                 f'../{temporary_path.relative_to("/")}', str(projects_root),
                                 operation],
                                text=True, capture_output=True, check=False)
                            self.assertEqual(result.returncode, 0, result.stderr)
                            self.assertEqual(result.stderr, '')
                            self.assertNotIn(str(document), result.stdout.splitlines())
                            self.assertEqual((project_path / 'AGENTS.md').read_text(),
                                             'Projet Test projet-test\n')
                            if destination_present:
                                self.assertEqual(document.read_bytes(), content)
                                after = document.stat()
                                for attribute in ('st_mode', 'st_uid', 'st_gid',
                                                  'st_ino', 'st_mtime_ns'):
                                    self.assertEqual(getattr(after, attribute),
                                                     getattr(before, attribute))
                            else:
                                self.assertFalse(document.exists())

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

            devops_user = f'../{temporary_path.relative_to("/")}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
print_info() { :; }
sync_project_template_is_valid() { return 0; }
sync_project() { printf '%s\n' "$1"; [[ "$1" != first ]]; }
ENV_DEVOPS_USER="$2"
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

    def test_sync_preserves_or_does_not_create_excluded_opencode_and_broker_resources(self):
        def snapshot(path):
            if not path.exists():
                return None
            state = {}
            for item in [path, *sorted(path.rglob('*'))]:
                content = item.read_bytes() if item.is_file() else None
                metadata = item.stat()
                state[str(item.relative_to(path))] = (
                    content, metadata.st_mode, metadata.st_uid, metadata.st_gid,
                    metadata.st_ino, metadata.st_mtime_ns,
                )
            return state

        for operation in ('projet-test', 'all'):
            for source_present in (False, True):
                for destination_present in (False, True):
                    with self.subTest(operation=operation, source_present=source_present,
                                      destination_present=destination_present):
                        with tempfile.TemporaryDirectory() as temporary_directory:
                            temporary_path = Path(temporary_directory)
                            projects_root = temporary_path / 'datas'
                            template_path = projects_root / 'template'
                            project_path = projects_root / 'projet-test'
                            (template_path / 'PROMPTS').mkdir(parents=True)
                            for filename in ('AGENTS.md', '.gitignore', 'DEVELOPMENT_MAP.md'):
                                (template_path / filename).write_text(
                                    'Template template\n', encoding='utf-8')
                            project_path.mkdir()
                            (project_path / 'project.env').write_text(
                                'PROJECT_ID=projet-test\nPROJECT_NAME="Projet Test"\n',
                                encoding='utf-8')
                            excluded_paths = [
                                project_path / '.opencode' / name
                                for name in ('commands', 'config', 'skills', 'broker')
                            ] + [temporary_path / '.opencode' / 'broker']
                            if source_present:
                                source_paths = [
                                    template_path / '.opencode' / name
                                    for name in ('commands', 'config', 'skills')
                                ] + [temporary_path / 'cab' / 'src']
                                for path in source_paths:
                                    path.mkdir(parents=True)
                                    (path / 'resource.md').write_text(
                                        'Template template source\n', encoding='utf-8')
                            if destination_present:
                                for path in excluded_paths:
                                    (path / '__pycache__').mkdir(parents=True)
                                    (path / 'resource.md').write_text(
                                        'Template template local\n', encoding='utf-8')
                                    (path / '__pycache__' / 'old.pyc').write_bytes(b'local cache')
                                    (path / 'resource.md').chmod(0o640)
                                    path.chmod(0o750)
                            before = [snapshot(path) for path in excluded_paths]
                            script = r'''
set -euo pipefail
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
print_info() { :; }
chown() { printf '%s\n' "$@"; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
if [[ "$4" == all ]]; then
    sync_project_all
    sync_project_all
else
    sync_project "$4"
    sync_project "$4"
fi
'''
                            result = subprocess.run(
                                ['bash', '-c', script, 'bash', str(ROOT),
                                 f'../{temporary_path.relative_to("/")}', str(projects_root), operation],
                                text=True, capture_output=True, check=False)
                            self.assertEqual(result.returncode, 0, result.stderr)
                            self.assertEqual(result.stderr, '')
                            self.assertEqual(
                                (project_path / 'AGENTS.md').read_text(encoding='utf-8'),
                                'Projet Test projet-test\n')
                            self.assertEqual(
                                [snapshot(path) for path in excluded_paths], before)
                            chown_arguments = result.stdout.splitlines()
                            for path in excluded_paths:
                                self.assertNotIn(str(path), chown_arguments)
                            if not destination_present:
                                self.assertFalse((project_path / '.opencode').exists())
                                self.assertFalse((temporary_path / '.opencode').exists())

    def test_sync_all_without_valid_projects_leaves_global_broker_intact_or_absent(self):
        for destination_present in (False, True):
            with self.subTest(destination_present=destination_present):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    temporary_path = Path(temporary_directory)
                    template_path = temporary_path / 'datas' / 'template'
                    (template_path / 'PROMPTS').mkdir(parents=True)
                    for filename in ('AGENTS.md', '.gitignore', 'DEVELOPMENT_MAP.md'):
                        (template_path / filename).write_text('source\n', encoding='utf-8')
                    broker_path = temporary_path / '.opencode' / 'broker'
                    if destination_present:
                        (broker_path / '__pycache__').mkdir(parents=True)
                        (broker_path / 'local.md').write_text('local\n', encoding='utf-8')
                        (broker_path / '__pycache__' / 'old.pyc').write_bytes(b'local cache')
                        before = broker_path.stat()
                    script = r'''
set -euo pipefail
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
ENV_DEVOPS_USER="$2"
sync_project_all
'''
                    result = subprocess.run(
                        ['bash', '-c', script, 'bash', str(ROOT),
                         f'../{temporary_path.relative_to("/")}'],
                        text=True, capture_output=True, check=False)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stderr, '')
                    self.assertIn('Aucun projet valide à synchroniser', result.stdout)
                    if destination_present:
                        self.assertEqual((broker_path / 'local.md').read_text(), 'local\n')
                        self.assertEqual(
                            (broker_path / '__pycache__' / 'old.pyc').read_bytes(), b'local cache')
                        after = broker_path.stat()
                        for attribute in ('st_mode', 'st_uid', 'st_gid', 'st_ino', 'st_mtime_ns'):
                            self.assertEqual(getattr(after, attribute), getattr(before, attribute))
                    else:
                        self.assertFalse((temporary_path / '.opencode').exists())

    def test_create_project_leaves_no_directory_when_template_is_missing(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            missing_template_user = f'../{temporary_path.relative_to("/")}/missing'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { :; }
check_devops_user() { return 0; }
install() { printf 'install-called\n'; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
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
            (template_path / '.git').mkdir()
            (template_path / '.git' / 'template-marker').write_text(
                'template repository\n', encoding='utf-8'
            )
            (template_path / '.gitignore').write_text(
                'ignored-file\n', encoding='utf-8'
            )
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

            devops_user = f'../{temporary_path.relative_to("/")}'
            script = r'''
source "$1/modules/projects/projects.sh"
print_error() { printf 'ERREUR:%s\n' "$*"; }
print_success() { :; }
check_devops_user() { return 0; }
install() { mkdir -p "${!#}"; }
chown() { :; }
update_projects() {
    printf 'PROJECT_ID=%q\nPROJECT_NAME=%q\n' "$1" 'Projet & modèle' > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
projects_template_openspec() { printf 'openspec:%s\n' "$1"; }
projects_template_devops() { printf 'generation:%s\n' "$1"; }
git() { printf 'unexpected-git-call\n'; return 99; }
ENV_DEVOPS_USER="$2"
DEVOPS_GROUP=devops
ENV_DEVOPS_PROJECTS_ROOT="$3"
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
            self.assertEqual(result.stdout, 'openspec:projet-test\ngeneration:projet-test\n')
            self.assertFalse((project_path / '.git').exists())
            self.assertEqual(
                (template_path / '.git' / 'template-marker').read_text(encoding='utf-8'),
                'template repository\n',
            )
            self.assertEqual(
                (project_path / '.gitignore').read_text(encoding='utf-8'),
                'ignored-file\n',
            )
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

    def test_gitlab_release_reconfigures_missing_registry_and_preserves_its_port(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            project_path = projects_root / 'pfd'
            binary_path = temporary_path / 'bin'
            binary_path.mkdir(parents=True)
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=pfd\n'
                'PROJECT_NAME=PFD\n'
                'PROJECT_TYPE=docker\n'
                'PROJECT_DOCKERED=Yes\n'
                'PROJECT_DEBIAN_PACKAGE=No\n'
                'REMOTE_GITLAB_BASE_URL=https://git.ec-nantes.fr\n'
                'REMOTE_GITLAB_OWNER=adema261\n'
                'REMOTE_GITLAB_REPOSITORY=pfd\n'
                'REMOTE_GITLAB_NAME=origin\n'
                'REMOTE_GITLAB_BRANCH=main\n'
                'REMOTE_GITLAB_SSL_VERIFY=No\n',
                encoding='utf-8',
            )
            (binary_path / 'git').write_text(
                '#!/usr/bin/env bash\n'
                'case "$*" in\n'
                '  *"rev-parse --is-inside-work-tree"*) exit 0 ;;\n'
                '  *"tag --points-at HEAD"*) printf "v2026.09.16.16.38\\n"; exit 0 ;;\n'
                'esac\n'
                'exit 1\n',
                encoding='utf-8',
            )
            (binary_path / 'docker').write_text(
                '#!/usr/bin/env bash\n'
                'printf "%s\\n" "$*" >> "$DOCKER_LOG"\n'
                'if [[ "$1" == login ]]; then cat >/dev/null; fi\n'
                'if [[ "$1" == push && "$2" == "git.ec-nantes.fr:5050/adema261/pfd:2026.09.16.16.38" && ! -f "$DOCKER_PUSH_STATE" ]]; then\n'
                '  : > "$DOCKER_PUSH_STATE"\n'
                '  printf "%s\\n" "error from registry: blob unknown to registry" >&2\n'
                '  exit 1\n'
                'fi\n',
                encoding='utf-8',
            )
            for binary in ('git', 'docker'):
                (binary_path / binary).chmod(0o755)

            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { :; }
print_success() { :; }
gitlab_update() {
    printf 'gitlab_update\n'
    cat > "${ENV_DEVOPS_PROJECTS_ROOT}/$1/project.env" <<'EOF'
PROJECT_ID=pfd
PROJECT_NAME=PFD
PROJECT_TYPE=docker
PROJECT_DOCKERED=Yes
PROJECT_DEBIAN_PACKAGE=No
REMOTE_GITLAB_BASE_URL=https://git.ec-nantes.fr
REMOTE_GITLAB_REGISTRY=git.ec-nantes.fr:5050
REMOTE_GITLAB_OWNER=adema261
REMOTE_GITLAB_REPOSITORY=pfd
REMOTE_GITLAB_NAME=origin
REMOTE_GITLAB_BRANCH=main
REMOTE_GITLAB_SSL_VERIFY=No
EOF
}
_gitlab_read_username() { gitlab_username=user; }
_gitlab_read_token() { gitlab_token=token; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
sleep() { :; }
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
PATH="$3:$PATH"
export PATH
export DOCKER_LOG="$4"
export DOCKER_PUSH_STATE="$5"
projects_gitlab_release pfd
'''
            docker_log = temporary_path / 'docker.log'
            docker_push_state = temporary_path / 'docker-push-state'
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root), str(binary_path), str(docker_log), str(docker_push_state)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'gitlab_update\n')
            self.assertIn('blob unknown to registry', result.stderr)
            self.assertEqual(
                docker_log.read_text(encoding='utf-8').splitlines(),
                [
                    'image inspect pfd:latest',
                    'image inspect pfd:latest',
                    'tag pfd:latest git.ec-nantes.fr:5050/adema261/pfd:2026.09.16.16.38',
                    'tag pfd:latest git.ec-nantes.fr:5050/adema261/pfd:latest',
                    'login git.ec-nantes.fr:5050 --username user --password-stdin',
                    'push git.ec-nantes.fr:5050/adema261/pfd:2026.09.16.16.38',
                    'push git.ec-nantes.fr:5050/adema261/pfd:2026.09.16.16.38',
                    'push git.ec-nantes.fr:5050/adema261/pfd:latest',
                ],
            )

    def test_cicd_calls_eligible_operations_in_order(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            project_path = projects_root / 'project'
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Project\nPROJECT_TYPE=docker\n'
                'PROJECT_DOCKERED=Yes\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\nREMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=project\nREMOTE_FORGEJO_NAME=forgejo\n'
                'REMOTE_FORGEJO_BRANCH=main\nREMOTE_FORGEJO_SSL_VERIFY=Yes\n'
                'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test\nREMOTE_GITLAB_REGISTRY=registry.example.test\n'
                'REMOTE_GITLAB_OWNER=owner\nREMOTE_GITLAB_REPOSITORY=project\nREMOTE_GITLAB_NAME=gitlab\n'
                'REMOTE_GITLAB_BRANCH=main\nREMOTE_GITLAB_SSL_VERIFY=Yes\n'
                'REMOTE_GITHUB_BASE_URL=https://github.com\nREMOTE_GITHUB_OWNER=owner\n'
                'REMOTE_GITHUB_REPOSITORY=project\nREMOTE_GITHUB_NAME=github\nREMOTE_GITHUB_BRANCH=main\n',
                encoding='utf-8',
            )
            script = r'''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_error() { :; }
cicd_project_print_summary() { :; }
git_commit() { printf 'commit\n'; }
forgejo_push() { printf 'forgejo_push\n'; }
gitlab_push() { printf 'gitlab_push\n'; }
github_push() { printf 'github_push\n'; }
projects_docker_build() { printf 'docker_build\n'; }
projects_forgejo_release() { printf 'forgejo_release\n'; }
projects_gitlab_release() { printf 'gitlab_release\n'; }
projects_github_release() { printf 'github_release\n'; }
ENV_DEVOPS_PROJECTS_ROOT="$2"
cicd_project project commit vcommit
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), [
                'commit', 'forgejo_push', 'gitlab_push', 'github_push',
                'docker_build', 'forgejo_release', 'gitlab_release', 'github_release',
            ])

    def test_cicd_silently_skips_unconfigured_providers_and_docker(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            project_path = projects_root / 'project'
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Project\nPROJECT_TYPE=generic\nPROJECT_DOCKERED=No\n',
                encoding='utf-8',
            )
            script = r'''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_error() { :; }
cicd_project_print_summary() { :; }
git_commit() { printf 'commit\n'; }
forgejo_push() { printf 'unexpected\n'; }
gitlab_push() { printf 'unexpected\n'; }
github_push() { printf 'unexpected\n'; }
projects_docker_build() { printf 'unexpected\n'; }
projects_forgejo_release() { printf 'unexpected\n'; }
projects_gitlab_release() { printf 'unexpected\n'; }
projects_github_release() { printf 'unexpected\n'; }
ENV_DEVOPS_PROJECTS_ROOT="$2"
cicd_project project commit vcommit
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'commit\n')

    def test_cicd_summary_lists_completed_and_skipped_operations(self):
        script = r'''
source "$1/modules/projects/git.sh"
print_title() { :; }
cicd_project_print_summary project commit v1.2.3 réussi \
  'publié vers origin/main' 'non configuré, ignoré' 'non configuré, ignoré' \
  'project:latest (version 1.2.3)' 'forgejo/project:1.2.3 et latest' \
  'non Dockerisé ou non configuré, ignoré' 'non Dockerisé ou non configuré, ignoré'
'''
        result = subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('État global : réussi', result.stdout)
        self.assertIn('Message : commit', result.stdout)
        self.assertIn('Forgejo : publié vers origin/main', result.stdout)
        self.assertIn('GitLab  : non configuré, ignoré', result.stdout)
        self.assertIn('Build   : project:latest (version 1.2.3)', result.stdout)

    def test_cicd_summary_uses_the_tag_effectively_pointing_at_head(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            project_path = projects_root / 'project'
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Project\nPROJECT_TYPE=docker\n'
                'PROJECT_DOCKERED=Yes\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\nREMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=project\nREMOTE_FORGEJO_NAME=forgejo\n'
                'REMOTE_FORGEJO_BRANCH=main\nREMOTE_FORGEJO_SSL_VERIFY=Yes\n'
                'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test\nREMOTE_GITLAB_REGISTRY=registry.example.test\n'
                'REMOTE_GITLAB_OWNER=owner\nREMOTE_GITLAB_REPOSITORY=project\nREMOTE_GITLAB_NAME=gitlab\n'
                'REMOTE_GITLAB_BRANCH=main\nREMOTE_GITLAB_SSL_VERIFY=Yes\n'
                'REMOTE_GITHUB_BASE_URL=https://github.com\nREMOTE_GITHUB_OWNER=AzenorPixs\n'
                'REMOTE_GITHUB_REPOSITORY=PKeycloak\nREMOTE_GITHUB_NAME=github\n'
                'REMOTE_GITHUB_BRANCH=main\n',
                encoding='utf-8',
            )
            script = r'''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_error() { :; }
git_commit() { :; }
git() { printf 'v2026.09.23.13.17\n'; }
runuser() { shift 3; "$@"; }
forgejo_push() { :; }
gitlab_push() { :; }
github_push() { :; }
projects_docker_build() { :; }
projects_forgejo_release() { :; }
projects_gitlab_release() { :; }
projects_github_release() { :; }
ENV_DEVOPS_USER=test
ENV_DEVOPS_PROJECTS_ROOT="$2"
cicd_project project 2026.09.23.13.38 v2026.09.23.13.38
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('Tag     : v2026.09.23.13.17', result.stdout)
            self.assertIn('Version : 2026.09.23.13.17', result.stdout)
            self.assertIn('Build   : project:latest (version 2026.09.23.13.17)', result.stdout)
            self.assertIn('Forgejo : forgejo.example.test/owner/project:2026.09.23.13.17 et latest', result.stdout)
            self.assertIn('GitLab  : registry.example.test/owner/project:2026.09.23.13.17 et latest', result.stdout)
            self.assertIn('GitHub  : ghcr.io/azenorpixs/pkeycloak:2026.09.23.13.17 et latest', result.stdout)

    def test_cicd_summary_is_printed_before_a_push_failure(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory) / 'projects'
            project_path = projects_root / 'project'
            project_path.mkdir(parents=True)
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Project\nPROJECT_TYPE=generic\nPROJECT_DOCKERED=No\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\nREMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=project\nREMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\nREMOTE_FORGEJO_SSL_VERIFY=Yes\n',
                encoding='utf-8',
            )
            script = r'''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_error() { :; }
git_commit() { :; }
forgejo_push() { return 1; }
ENV_DEVOPS_PROJECTS_ROOT="$2"
cicd_project project commit v1.2.3
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn('État global : échec', result.stdout)
            self.assertIn('Forgejo : échec', result.stdout)

    def test_github_release_publishes_existing_image_without_building(self):
        cases = (
            ('owner', 'project', 'v1.2.3'),
            ('AzenorPixs', 'pkeycloak', 'v1.2.3'),
            ('owner', 'PKeycloak', 'v1.2.3'),
            ('AzenorPixs', 'PKeycloak', 'v1.2.3-RC1'),
        )
        for owner, repository, git_tag in cases:
            with self.subTest(owner=owner, repository=repository, git_tag=git_tag):
                self._check_github_release_image_case(owner, repository, git_tag)

    def _check_github_release_image_case(self, owner, repository, git_tag):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            projects_root = temporary_path / 'projects'
            project_path = projects_root / 'project'
            binary_path = temporary_path / 'bin'
            project_path.mkdir(parents=True)
            binary_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_DOCKERED=Yes\n'
                'REMOTE_GITHUB_BASE_URL=https://github.com\n'
                f'REMOTE_GITHUB_OWNER={owner}\nREMOTE_GITHUB_REPOSITORY={repository}\n'
                'REMOTE_GITHUB_NAME=origin\nREMOTE_GITHUB_BRANCH=main\n',
                encoding='utf-8',
            )
            original_configuration = (project_path / 'project.env').read_bytes()
            (binary_path / 'git').write_text(
                '#!/usr/bin/env bash\n'
                f'case "$*" in *"tag --points-at HEAD"*) printf "%s\\n" "{git_tag}";; esac\n',
                encoding='utf-8',
            )
            (binary_path / 'docker').write_text(
                '#!/usr/bin/env bash\nprintf "%s\\n" "$*" >> "$DOCKER_LOG"\n'
                '[[ "$1" == login ]] && cat >/dev/null\nexit 0\n',
                encoding='utf-8',
            )
            for binary in ('git', 'docker'):
                (binary_path / binary).chmod(0o755)
            docker_log = temporary_path / 'docker.log'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_success() { :; }
_github_read_username() { github_username=GitHubUser; }
_github_read_token() { github_token=token; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
ENV_DEVOPS_USER="$(id -un)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
PATH="$3:$PATH"
export PATH DOCKER_LOG="$4"
projects_github_release project || exit $?
[[ "$REMOTE_GITHUB_OWNER" == "$5" && "$REMOTE_GITHUB_REPOSITORY" == "$6" ]] || exit 42
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(projects_root), str(binary_path), str(docker_log), owner, repository],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((project_path / 'project.env').read_bytes(), original_configuration)
            remote_image = f'ghcr.io/{owner.lower()}/{repository.lower()}'
            version = git_tag[1:]
            self.assertEqual(docker_log.read_text(encoding='utf-8').splitlines(), [
                'image inspect project:latest',
                f'tag project:latest {remote_image}:{version}',
                f'tag project:latest {remote_image}:latest',
                'login ghcr.io --username GitHubUser --password-stdin',
                f'push {remote_image}:{version}',
                f'push {remote_image}:latest',
            ])

    def test_gitlab_docker_push_retries_blob_unknown_to_registry(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            binary_path = temporary_path / 'bin'
            docker_config = temporary_path / 'docker-config'
            binary_path.mkdir()
            docker_config.mkdir()
            (binary_path / 'docker').write_text(
                '#!/usr/bin/env bash\n'
                'printf "%s\\n" "$*" >> "$DOCKER_LOG"\n'
                'if [[ "$1" == push && ! -f "$DOCKER_PUSH_STATE" ]]; then\n'
                '  : > "$DOCKER_PUSH_STATE"\n'
                '  printf "%s\\n" "error from registry: blob unknown to registry" >&2\n'
                '  exit 1\n'
                'fi\n',
                encoding='utf-8',
            )
            (binary_path / 'docker').chmod(0o755)

            docker_log = temporary_path / 'docker.log'
            push_state = temporary_path / 'push-state'
            sleep_log = temporary_path / 'sleep.log'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
sleep() { printf '%s\n' "$1" >> "$SLEEP_LOG"; }
ENV_DEVOPS_USER="$(id -un)"
PATH="$2:$PATH"
export PATH DOCKER_LOG DOCKER_PUSH_STATE SLEEP_LOG
_gitlab_docker_push_with_retry 'git.ec-nantes.fr:5050/adema261/pfd:1.0' "$3"
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(binary_path), str(docker_config)],
                text=True,
                capture_output=True,
                check=False,
                env={
                    **os.environ,
                    'DOCKER_LOG': str(docker_log),
                    'DOCKER_PUSH_STATE': str(push_state),
                    'SLEEP_LOG': str(sleep_log),
                },
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('blob unknown to registry', result.stderr)
            self.assertEqual(
                docker_log.read_text(encoding='utf-8').splitlines(),
                [
                    'push git.ec-nantes.fr:5050/adema261/pfd:1.0',
                    'push git.ec-nantes.fr:5050/adema261/pfd:1.0',
                ],
            )
            self.assertEqual(sleep_log.read_text(encoding='utf-8'), '2\n')

    def test_gitlab_docker_push_does_not_retry_another_error(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            binary_path = temporary_path / 'bin'
            docker_config = temporary_path / 'docker-config'
            binary_path.mkdir()
            docker_config.mkdir()
            (binary_path / 'docker').write_text(
                '#!/usr/bin/env bash\n'
                'printf "%s\\n" "$*" >> "$DOCKER_LOG"\n'
                'printf "%s\\n" "denied: requested access to the resource is denied" >&2\n'
                'exit 42\n',
                encoding='utf-8',
            )
            (binary_path / 'docker').chmod(0o755)

            docker_log = temporary_path / 'docker.log'
            script = r'''
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
runuser() { shift 2; [[ "${1:-}" == "--" ]] && shift; "$@"; }
sleep() { printf '%s\n' "$1" >> "$SLEEP_LOG"; }
ENV_DEVOPS_USER="$(id -un)"
PATH="$2:$PATH"
export PATH DOCKER_LOG SLEEP_LOG
_gitlab_docker_push_with_retry 'git.ec-nantes.fr:5050/adema261/pfd:1.0' "$3"
push_rc=$?
[[ "${push_rc}" -eq 42 ]]
'''
            result = subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), str(binary_path), str(docker_config)],
                text=True,
                capture_output=True,
                check=False,
                env={
                    **os.environ,
                    'DOCKER_LOG': str(docker_log),
                    'SLEEP_LOG': str(temporary_path / 'sleep.log'),
                },
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('requested access to the resource is denied', result.stderr)
            self.assertEqual(
                docker_log.read_text(encoding='utf-8').splitlines(),
                ['push git.ec-nantes.fr:5050/adema261/pfd:1.0'],
            )

    def test_gitlab_registry_validation_rejects_a_protocol_or_path(self):
        script = r'''
source "$1/modules/projects/git.sh"
_gitlab_registry_is_valid git.ec-nantes.fr:5050 || exit 1
! _gitlab_registry_is_valid https://git.ec-nantes.fr:5050 || exit 1
! _gitlab_registry_is_valid git.ec-nantes.fr:5050/v2 || exit 1
'''
        result = subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT)],
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stderr)



class GitlabDebianLinkTests(unittest.TestCase):
    def run_release(self, http_code='201', transport_code='0', existing_asset=False, mismatched_commit=False):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.gitlab-link-fixture-') as directory:
            base = Path(directory)
            project = base / 'project'
            (project / 'dist').mkdir(parents=True)
            (project / 'dist/project_1.0_all.deb').write_bytes(b'synthetic-debian-fixture')
            (project / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_TYPE=BASH\n'
                'PROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=Yes\n'
                'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test\n'
                'REMOTE_GITLAB_OWNER=owner\nREMOTE_GITLAB_REPOSITORY=project\n'
                'REMOTE_GITLAB_NAME=origin\nREMOTE_GITLAB_BRANCH=main\n'
                'REMOTE_GITLAB_SSL_VERIFY=Yes\n')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
print_info() { printf 'INFO:%s\n' "$*"; }
print_success() { printf 'SUCCES:%s\n' "$*"; }
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { if [[ "$*" == *'rev-parse --verify HEAD'* ]]; then printf '%s\n' "$LOCAL_HEAD"; else printf 'v1.0\n'; fi; }
_gitlab_ensure_credentials() { return 0; }
_gitlab_read_username() { gitlab_username=fixture-user; }
_gitlab_read_token() { gitlab_token=fixture-token; }
curl() {
    case "$*" in
        *'/assets/links'*)
            printf 'LINK\n' >> "$CALLS"
            [[ "$LINK_TRANSPORT" == 0 ]] || return "$LINK_TRANSPORT"
            printf '{"message":"fixture-response-private"}\n%s' "$LINK_HTTP"
            ;;
        *'/uploads'*) printf '{"url":"/uploads/fixture/project.deb"}\n201' ;;
        *'/releases/'*)
            if [[ "$EXISTING_ASSET" == yes ]]; then
                printf '{"tag_name":"v1.0","commit":{"id":"fixture-head"},"assets":{"links":[{"name":"project_1.0_all.deb"}]}}\n200'
            else printf '{"tag_name":"v1.0","commit":{"id":"fixture-head"},"assets":{"links":[]}}\n200'; fi ;;
        *) return 89 ;;
    esac
}
projects_gitlab_release_debian project
'''
            result = subprocess.run(
                ['bash', '-c', script, 'fixture', str(ROOT), str(base)],
                env={**os.environ, 'TMPDIR': str(base), 'CALLS': str(base/'calls'),
                     'LINK_HTTP': http_code, 'LINK_TRANSPORT': transport_code,
                     'EXISTING_ASSET': 'yes' if existing_asset else 'no',
                     'LOCAL_HEAD': 'other-head' if mismatched_commit else 'fixture-head'},
                text=True, capture_output=True, check=False)
            self.assertNotIn('fixture-token', result.stdout + result.stderr)
            self.assertNotIn('fixture-response-private', result.stdout + result.stderr)
            if existing_asset or mismatched_commit:
                self.assertFalse((base/'calls').exists())
            else:
                self.assertEqual((base/'calls').read_text(), 'LINK\n')
            return result

    def test_existing_asset_is_informational_without_upload(self):
        result = self.run_release(existing_asset=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('ERREUR:', result.stderr)
        self.assertIn('GitLab : identifiants disponibles.', result.stdout)
        self.assertIn('tag v1.0 de la release cohérent', result.stdout)
        self.assertIn('déjà publié sur GitLab pour v1.0', result.stdout)
        self.assertNotIn('synchronisé avec', result.stdout)
        labels = ('Projet', 'ID projet', 'Répertoire', 'Type distant', 'Dépôt distant', 'Branche distante', 'Tag')
        rows = [line for line in result.stdout.splitlines() if ' : ' in line and line.split(' : ', 1)[0].strip() in labels]
        self.assertEqual(len(rows), len(labels))
        self.assertEqual({line.index(' : ') for line in rows}, {16})

    def test_existing_release_on_another_commit_is_rejected(self):
        result = self.run_release(existing_asset=True, mismatched_commit=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('incohérente', result.stderr)

    def test_success_is_announced_only_for_http_success(self):
        for code in ('200', '201', '204'):
            with self.subTest(code=code):
                result = self.run_release(code)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('Paquet Debian publié', result.stdout)

    def test_http_errors_and_malformed_responses_cannot_announce_success(self):
        for code in ('400', '401', '403', '409', '500', '000', 'malformed'):
            with self.subTest(code=code):
                result = self.run_release(code)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Échec HTTP', result.stderr)
                self.assertNotIn('Paquet Debian publié', result.stdout)

    def test_transport_error_is_propagated_without_success(self):
        result = self.run_release(transport_code='7')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('Paquet Debian publié', result.stdout)


if __name__ == '__main__':
    unittest.main()
