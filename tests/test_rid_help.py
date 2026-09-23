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

    def run_git_init_without_input(self):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
check_devops_user() { return 0; }
runuser() {
    shift 2
    shift
    "$@"
}
DEVOPS_USER=devops
DEVOPS_PROJECTS_ROOT="$2"
if ! git_init project; then
    exit 1
fi
if ! git -C "$DEVOPS_PROJECTS_ROOT/project" rev-parse --verify HEAD >/dev/null; then
    exit 1
fi
printf 'complete\\n'
'''
        with tempfile.TemporaryDirectory() as temporary_directory:
            project_path = Path(temporary_directory) / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\n'
                'PROJECT_NAME="Projet"\n'
                'LOCAL_DEFAULT_BRANCH=main\n'
                'GIT_USER_NAME="Utilisateur Git"\n'
                'GIT_USER_EMAIL=git@example.test\n',
                encoding='utf-8',
            )
            return subprocess.run(
                ['bash', '-c', script, 'bash', str(ROOT), temporary_directory],
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

    def run_forgejo_push(self, projects_root, repository_status=0):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
check_devops_user() { return 0; }
forgejo_remote_ensure() { return 0; }
_forgejo_ensure_credentials() { return 0; }
forgejo_repository_ensure() {
    printf 'ensure:%s\\n' "$2"
    return "${FORGEJO_REPOSITORY_STATUS}"
}
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
FORGEJO_REPOSITORY_STATUS="$3"
forgejo_push project
'''
        return subprocess.run(
            [
                'bash', '-c', script, 'bash', str(ROOT), str(projects_root),
                str(repository_status),
            ],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_provider_push(self, projects_root, provider):
        script = '''
source "$1/modules/projects/git.sh"
print_title() { :; }
print_info() { :; }
print_error() { :; }
print_success() { :; }
check_devops_user() { return 0; }
forgejo_remote_ensure() { return 0; }
gitlab_remote_ensure() { return 0; }
github_repository_ensure() { return 0; }
github_remote_ensure() { return 0; }
_forgejo_ensure_credentials() { return 0; }
forgejo_repository_ensure() { :; }
_gitlab_ensure_credentials() { return 0; }
_github_ensure_credentials() { return 0; }
forgejo_git_fetch_named() { :; }
forgejo_git_push_named() { printf 'push:%s\\n' "$*"; }
gitlab_git_push() { printf 'push:%s\\n' "$*"; }
github_git_push() { printf 'push:%s\\n' "$*"; }
PUSH_PROVIDER="$3"
runuser() {
    case "$*" in
        *'git --version'*) return 0 ;;
        *'rev-parse --verify'*) return 1 ;;
        *'rev-parse --is-inside-work-tree'*) return 0 ;;
        *'branch --show-current'*) printf 'main\\n' ;;
        *'tag --points-at HEAD'*) return 0 ;;
        *'remote get-url'*)
            printf 'https://%s.example.test/owner/project.git\\n' "$PUSH_PROVIDER"
            ;;
        *) return 0 ;;
    esac
}
DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_USER=devops
DEVOPS_PROJECTS_ROOT="$2"
git_push_provider project "$PUSH_PROVIDER"
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT), str(projects_root), provider],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_forgejo_repository_ensure(
        self, owner, authenticated_user, organization_status, expected_endpoint,
        repository_initial_status='404',
    ):
        script = '''
source "$1/lib/forgejo-auth.sh"
print_error() { printf 'error:%s\\n' "$*" >&2; }
print_success() { printf 'success:%s\\n' "$*"; }
_forgejo_prepare_context() {
    forgejo_owner="$OWNER"
    forgejo_repo=project
    forgejo_username="$AUTHENTICATED_USER"
}
state_file="$(mktemp)"
trap 'rm -f "${state_file}"' EXIT
forgejo_api_get() {
    case "$2" in
        "/repos/$OWNER/project")
            if [[ ! -s "${state_file}" ]]; then
                printf '{}\\n%s' "$REPOSITORY_INITIAL_STATUS"
            else
                printf '{}\\n200'
            fi
            ;;
        /user)
            printf '{"login":"%s"}\\n200' "$AUTHENTICATED_USER"
            ;;
        "/orgs/$OWNER")
            printf '{}\\n%s' "$ORGANIZATION_STATUS"
            ;;
        *)
            printf '{}\\n500'
            ;;
    esac
}
forgejo_api_post_json() {
    if [[ "$2" == "$EXPECTED_ENDPOINT" ]]; then
        printf created > "${state_file}"
        printf '{}\\n201'
    else
        printf '{}\\n403'
    fi
}
forgejo_repository_ensure /tmp origin
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT)],
            env={
                'OWNER': owner,
                'AUTHENTICATED_USER': authenticated_user,
                'ORGANIZATION_STATUS': organization_status,
                'EXPECTED_ENDPOINT': expected_endpoint,
                'REPOSITORY_INITIAL_STATUS': repository_initial_status,
            },
            text=True,
            capture_output=True,
            check=False,
        )

    def run_forgejo_api_get(self):
        script = '''
source "$1/lib/forgejo-auth.sh"
print_error() { printf 'error:%s\\n' "$*" >&2; }
_forgejo_prepare_context() {
    forgejo_base=https://forgejo.example.test
    forgejo_token=token
}
api_config="$(mktemp)"
trap 'rm -f "${api_config}"' EXIT
_forgejo_create_api_curl_config() { printf '%s' "${api_config}"; }
_forgejo_curl() {
    local response_file=""
    local index=1

    while [[ "${index}" -le "$#" ]]; do
        if [[ "${!index}" == '-o' ]]; then
            index=$((index + 1))
            response_file="${!index}"
            break
        fi
        index=$((index + 1))
    done

    printf '%s\\0' "${!#}" > "${response_file}"
    printf '200'
}
forgejo_api_get /tmp /repos/owner/project
'''
        return subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT)],
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

    def test_cicd_help_does_not_start_the_flow(self):
        for arguments in (('projects', 'cicd', 'help'), ('projects', 'cicd', 'project', 'help')):
            with self.subTest(arguments=arguments):
                result = self.run_rid(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('rid projects cicd <ID PROJECT>', result.stdout)

    def test_github_release_help_is_available(self):
        result = self.run_rid('projects', 'github', 'release', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects github release <ID PROJECT>', result.stdout)

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

    def test_git_init_creates_the_first_commit_without_input_or_output(self):
        result = self.run_git_init_without_input()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'complete\n')

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
        self.assertLess(
            result.stdout.index('ensure:origin'),
            result.stdout.index('fetch:origin'),
        )
        self.assertIn('fetch:origin', result.stdout)
        self.assertIn(
            '--force-with-lease --set-upstream origin main:main',
            result.stdout,
        )

    def test_forgejo_push_skips_fetch_when_repository_is_absent(self):
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

            result = self.run_forgejo_push(projects_root, 2)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('ensure:origin', result.stdout)
        self.assertNotIn('fetch:origin', result.stdout)
        self.assertIn('push:', result.stdout)

    def test_forgejo_push_does_not_require_confirmation(self):
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
        self.assertIn('push:', result.stdout)

    def test_forgejo_repository_ensure_defers_an_absent_repository_to_first_push(self):
        result = self.run_forgejo_repository_ensure(
            'alice', 'alice', '404', '/user/repos',
        )

        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertNotIn('success:', result.stdout)

    def test_forgejo_repository_ensure_keeps_an_existing_repository(self):
        result = self.run_forgejo_repository_ensure(
            'alice', 'alice', '404', '/unexpected', '200',
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '')

    def test_forgejo_api_get_uses_the_api_v1_prefix(self):
        result = self.run_forgejo_api_get()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout,
            'https://forgejo.example.test/api/v1/repos/owner/project\n200',
        )
        self.assertNotIn('octet nul', result.stderr)

    def test_forgejo_repository_ensure_defers_an_organization_repository_to_first_push(self):
        result = self.run_forgejo_repository_ensure(
            'engineering', 'alice', '200', '/orgs/engineering/repos',
        )

        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertNotIn('success:', result.stdout)

    def test_forgejo_repository_ensure_does_not_check_owner_type_when_absent(self):
        result = self.run_forgejo_repository_ensure(
            'bob', 'alice', '404', '/user/repos',
        )

        self.assertEqual(result.returncode, 2, result.stderr)

    def test_provider_pushes_do_not_require_confirmation(self):
        provider_settings = {
            'forgejo': 'REMOTE_FORGEJO_SSL_VERIFY=Yes\n',
            'gitlab': '',
            'github': '',
        }

        for provider, extra_settings in provider_settings.items():
            with self.subTest(provider=provider), tempfile.TemporaryDirectory() as temporary_directory:
                projects_root = Path(temporary_directory)
                project_path = projects_root / 'project'
                project_path.mkdir()
                provider_upper = provider.upper()
                (project_path / 'project.env').write_text(
                    'PROJECT_ID=project\n'
                    'PROJECT_NAME="Projet"\n'
                    'PROJECT_TYPE=application\n'
                    'PROJECT_DOCKERED=No\n'
                    f'REMOTE_{provider_upper}_BASE_URL=https://{provider}.example.test\n'
                    f'REMOTE_{provider_upper}_OWNER=owner\n'
                    f'REMOTE_{provider_upper}_REPOSITORY=project\n'
                    f'REMOTE_{provider_upper}_NAME=origin\n'
                    f'REMOTE_{provider_upper}_BRANCH=main\n'
                    f'{extra_settings}',
                    encoding='utf-8',
                )

                result = self.run_provider_push(projects_root, provider)

                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('push:', result.stdout)

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
