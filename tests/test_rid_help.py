#!/usr/bin/env python3
"""Tests des chemins d'aide rid exécutables sans configuration de production."""
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ENTRYPOINT = ROOT / 'root-install-debian.sh'


class RidHelpTests(unittest.TestCase):
    def run_rid(self, *arguments):
        return subprocess.run(
            ['bash', str(ENTRYPOINT), *arguments],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_git_commit_all(self, projects_root, failing_project=''):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
FAILING_PROJECT="$3"
git_commit() {
    printf '%s|%s|%s\\n' "$1" "$2" "$3"
    if [[ "$1" == "$FAILING_PROJECT" ]]; then
        return 1
    fi
}
DEVOPS_PROJECTS_ROOT="$2"
git_commit_all message tag
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT), str(projects_root), failing_project],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_git_commit_without_repository(self, initialization_creates_repository):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
check_devops_user() { return 0; }
git_init() {
    printf 'init\n'
    if [[ "${INITIALIZATION_CREATES_REPOSITORY}" == 'yes' ]]; then
        repository_ready='true'
    fi
}
runuser() {
    case "$*" in
        *'rev-parse'*)
            printf '%s\n' "${repository_ready:-false}"
            ;;
        *'add .'*)
            printf 'add\n'
            ;;
    esac
    return 0
}
DEVOPS_USER=devops
DEVOPS_PROJECTS_ROOT="$2"
INITIALIZATION_CREATES_REPOSITORY="$3"
repository_ready='false'
git_commit project message tag
'''
        with tempfile.TemporaryDirectory() as temporary_directory:
            project_path = Path(temporary_directory) / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\n'
                'PROJECT_NAME="Projet"\n'
                'GIT_USER_NAME="Utilisateur Git"\n'
                'GIT_USER_EMAIL=git@example.test\n',
                encoding='utf-8',
            )
            return subprocess.run(
                [
                    'bash', '-c', script, 'bash', str(ROOT),
                    temporary_directory,
                    'yes' if initialization_creates_repository else 'no',
                ],
                text=True,
                capture_output=True,
                check=False,
            )

    def run_forgejo_push_all(self, projects_root, failing_project=''):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
FAILING_PROJECT="$3"
forgejo_push() {
    printf '%s\\n' "$1"
    if [[ "$1" == "$FAILING_PROJECT" ]]; then
        return 1
    fi
}
DEVOPS_PROJECTS_ROOT="$2"
forgejo_push_all
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT), str(projects_root), failing_project],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_forgejo_push(self, projects_root):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
check_devops_user() { return 0; }
forgejo_remote_ensure() { return 0; }
_forgejo_ensure_credentials() { return 0; }
forgejo_git_fetch_named() { printf 'fetch:%s\\n' "$2"; }
forgejo_git_push_named() { printf 'push:%s\\n' "$*"; }
runuser() {
    case "$*" in
        *'git --version'*) return 0 ;;
        *'rev-parse --verify'*) return 1 ;;
        *'rev-parse --is-inside-work-tree'*) return 0 ;;
        *'branch --show-current'*) printf 'main\\n' ;;
        *'tag --points-at HEAD'*) return 0 ;;
        *'remote get-url'*) printf 'https://forgejo.example.test/owner/project.git\\n' ;;
        *) return 0 ;;
    esac
}
DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_USER=devops
DEVOPS_PROJECTS_ROOT="$2"
forgejo_push project
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT), str(projects_root)],
            input='o\n',
            text=True,
            capture_output=True,
            check=False,
        )

    def test_root_help_is_available_without_configuration(self):
        result = self.run_rid('help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares', result.stdout)
        self.assertIn('→', result.stdout)

    def test_software_help_lists_available_commands(self):
        result = self.run_rid('softwares', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares install apt <SOFTWARE>', result.stdout)
        self.assertIn('rid softwares update github [SOFTWARE]', result.stdout)
        self.assertIn('rid softwares flatpak update', result.stdout)

    def test_flatpak_help_is_available_without_configuration(self):
        result = self.run_rid('softwares', 'flatpak', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares flatpak update', result.stdout)

    def test_terminal_help_does_not_publish(self):
        result = self.run_rid('projects', 'github', 'push', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects github push <ID PROJECT>', result.stdout)

    def test_forgejo_push_help_describes_grouped_command(self):
        result = self.run_rid('projects', 'forgejo', 'push', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects forgejo push <ID PROJECT>', result.stdout)
        self.assertIn('rid projects forgejo push all', result.stdout)

    def test_projects_help_uses_canonical_git_init_command(self):
        result = self.run_rid('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git analyse <ID PROJECTS>', result.stdout)
        self.assertNotIn('rid projects gita <ID PROJECT>', result.stdout)
        self.assertIn('rid projects git commit <ID PROJECT> [COMMIT]', result.stdout)
        self.assertNotIn('rid projects gitc <ID PROJECT> [COMMIT]', result.stdout)
        self.assertIn('rid projects git init <ID PROJECT>', result.stdout)
        self.assertNotIn('rid projects giti <ID PROJECT>', result.stdout)
        self.assertIn('rid projects git status <ID PROJECTS>', result.stdout)
        self.assertNotIn('rid projects gits <ID PROJECTS>', result.stdout)
        self.assertIn('rid projects git update <ID PROJECT>', result.stdout)
        self.assertNotIn('rid projects gitu <ID PROJECT>', result.stdout)

    def test_projects_create_help_describes_template_creation(self):
        result = self.run_rid('projects', 'create', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects create <ID PROJECT>', result.stdout)
        self.assertIn('modèle local', result.stdout)

    def test_projects_clone_help_describes_clone_command(self):
        projects_result = self.run_rid('projects', 'help')
        clone_result = self.run_rid('projects', 'clone', 'help')

        self.assertEqual(projects_result.returncode, 0, projects_result.stderr)
        self.assertEqual(clone_result.returncode, 0, clone_result.stderr)
        command = 'rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>'
        self.assertIn(command, projects_result.stdout)
        self.assertIn(command, clone_result.stdout)

    def test_projects_gitlab_clone_help_does_not_start_cloning(self):
        projects_result = self.run_rid('projects', 'help')
        gitlab_result = self.run_rid('projects', 'gitlab', 'help')
        clone_result = self.run_rid('projects', 'gitlab', 'clone', 'help')
        question_result = self.run_rid('projects', 'gitlab', 'clone', '?')

        command = 'rid projects gitlab clone <ID PROJECT>'
        for result in (projects_result, gitlab_result, clone_result, question_result):
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(command, result.stdout)

    def test_projects_github_clone_help_does_not_start_cloning(self):
        projects_result = self.run_rid('projects', 'help')
        github_result = self.run_rid('projects', 'github', 'help')
        clone_result = self.run_rid('projects', 'github', 'clone', 'help')
        question_result = self.run_rid('projects', 'github', 'clone', '?')

        command = 'rid projects github clone <ID PROJECT>'
        for result in (projects_result, github_result, clone_result, question_result):
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(command, result.stdout)

    def test_projects_sync_help_describes_synchronization(self):
        projects_result = self.run_rid('projects', 'help')
        sync_result = self.run_rid('projects', 'sync', 'help')

        self.assertEqual(projects_result.returncode, 0, projects_result.stderr)
        self.assertEqual(sync_result.returncode, 0, sync_result.stderr)
        self.assertIn('rid projects sync <ID PROJECT>', projects_result.stdout)
        self.assertIn('rid projects sync all', projects_result.stdout)
        self.assertIn('rid projects sync <ID PROJECT>', sync_result.stdout)
        self.assertIn('rid projects sync all', sync_result.stdout)

    def test_projects_git_help_lists_analyse_init_and_update(self):
        result = self.run_rid('projects', 'git', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git analyse <ID PROJECTS>', result.stdout)
        self.assertIn('rid projects git init <ID PROJECT>', result.stdout)
        self.assertIn('rid projects git status <ID PROJECTS>', result.stdout)
        self.assertIn('rid projects git update <ID PROJECT>', result.stdout)

    def test_projects_git_help_lists_commit_command(self):
        result = self.run_rid('projects', 'git', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git commit <ID PROJECT> [COMMIT]', result.stdout)
        self.assertNotIn('rid projects gitc <ID PROJECT> [COMMIT]', result.stdout)

    def test_projects_git_commit_help_describes_canonical_command(self):
        result = self.run_rid('projects', 'git', 'commit', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git commit <ID PROJECT> [COMMIT]', result.stdout)

    def test_projects_help_lists_commit_all_command(self):
        result = self.run_rid('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git commit all', result.stdout)

    def test_projects_help_lists_forgejo_push_all_command(self):
        result = self.run_rid('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects forgejo push all', result.stdout)

    def test_projects_git_commit_all_help_describes_command(self):
        result = self.run_rid('projects', 'git', 'commit', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git commit all', result.stdout)

    def test_git_commit_all_selects_only_valid_configured_projects(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)
            valid_project = projects_root / 'valid'
            valid_project.mkdir()
            (valid_project / 'project.env').write_text(
                'PROJECT_ID=valid\n'
                'PROJECT_NAME="Projet valide"\n'
                'GIT_USER_NAME="Utilisateur Git"\n'
                'GIT_USER_EMAIL=git@example.test\n',
                encoding='utf-8',
            )

            incomplete_project = projects_root / 'incomplete'
            incomplete_project.mkdir()
            (incomplete_project / 'project.env').write_text(
                'PROJECT_ID=incomplete\n'
                'PROJECT_NAME="Projet incomplet"\n',
                encoding='utf-8',
            )

            (projects_root / 'without-config').mkdir()

            result = self.run_git_commit_all(projects_root)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'valid|message|tag\n')

    def test_git_commit_all_continues_after_a_commit_failure(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)

            for project_id in ('first', 'second'):
                project_path = projects_root / project_id
                project_path.mkdir()
                (project_path / 'project.env').write_text(
                    f'PROJECT_ID={project_id}\n'
                    f'PROJECT_NAME="{project_id}"\n'
                    'GIT_USER_NAME="Utilisateur Git"\n'
                    'GIT_USER_EMAIL=git@example.test\n',
                    encoding='utf-8',
                )

            result = self.run_git_commit_all(projects_root, 'first')

        self.assertEqual(result.returncode, 1)
        self.assertEqual(
            result.stdout,
            'first|message|tag\nsecond|message|tag\n',
        )

    def test_git_commit_initializes_a_missing_local_repository(self):
        result = self.run_git_commit_without_repository(True)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'init\nadd\n')

    def test_git_commit_stops_if_initialization_does_not_create_repository(self):
        result = self.run_git_commit_without_repository(False)

        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(result.stdout, 'init\n')

    def test_forgejo_push_all_selects_only_complete_configured_projects(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)
            valid_project = projects_root / 'valid'
            valid_project.mkdir()
            (valid_project / 'project.env').write_text(
                'PROJECT_ID=valid\n'
                'PROJECT_NAME="Projet valide"\n'
                'PROJECT_TYPE=application\n'
                'PROJECT_DOCKERED=No\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=valid\n'
                'REMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\n'
                'REMOTE_FORGEJO_SSL_VERIFY=Yes\n',
                encoding='utf-8',
            )

            incomplete_project = projects_root / 'incomplete'
            incomplete_project.mkdir()
            (incomplete_project / 'project.env').write_text(
                'PROJECT_ID=incomplete\n'
                'PROJECT_NAME="Projet incomplet"\n',
                encoding='utf-8',
            )

            (projects_root / 'without-config').mkdir()

            result = self.run_forgejo_push_all(projects_root)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'valid\n')

    def test_forgejo_push_all_continues_after_a_push_failure(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)

            for project_id in ('first', 'second'):
                project_path = projects_root / project_id
                project_path.mkdir()
                (project_path / 'project.env').write_text(
                    f'PROJECT_ID={project_id}\n'
                    f'PROJECT_NAME="{project_id}"\n'
                    'PROJECT_TYPE=application\n'
                    'PROJECT_DOCKERED=No\n'
                    'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
                    'REMOTE_FORGEJO_OWNER=owner\n'
                    f'REMOTE_FORGEJO_REPOSITORY={project_id}\n'
                    'REMOTE_FORGEJO_NAME=origin\n'
                    'REMOTE_FORGEJO_BRANCH=main\n'
                    'REMOTE_FORGEJO_SSL_VERIFY=Yes\n',
                    encoding='utf-8',
                )

            result = self.run_forgejo_push_all(projects_root, 'first')

        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, 'first\nsecond\n')

    def test_forgejo_push_uses_force_with_lease_for_the_branch(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)
            project_path = projects_root / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\n'
                'PROJECT_NAME="Projet"\n'
                'PROJECT_TYPE=application\n'
                'PROJECT_DOCKERED=No\n'
                'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
                'REMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=project\n'
                'REMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\n'
                'REMOTE_FORGEJO_SSL_VERIFY=Yes\n',
                encoding='utf-8',
            )

            result = self.run_forgejo_push(projects_root)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('fetch:origin', result.stdout)
        self.assertIn(
            '--force-with-lease --set-upstream origin main:main',
            result.stdout,
        )

    def test_projects_git_status_help_describes_canonical_command(self):
        result = self.run_rid('projects', 'git', 'status', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects git status <ID PROJECTS>', result.stdout)

    def test_unknown_root_command_suggests_root_help(self):
        result = self.run_rid('inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Classe d'actions inconnue : inconnue", result.stdout)
        self.assertIn('rid help', result.stdout)

    def test_unknown_software_command_suggests_contextual_help(self):
        result = self.run_rid('softwares', 'inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Action inconnue pour la classe 'softwares' : inconnue", result.stdout)
        self.assertIn('rid softwares help', result.stdout)


if __name__ == '__main__':
    unittest.main()
