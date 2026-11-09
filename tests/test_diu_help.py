#!/usr/bin/env python3
"""Tests des chemins d'aide diu exécutables sans configuration de production."""
from pathlib import Path
import os
import re
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ENTRYPOINT = ROOT / 'root-install-debian.sh'


class DiuHelpTests(unittest.TestCase):
    def run_diu(self, *arguments):
        return subprocess.run(
            ['bash', str(ENTRYPOINT), *arguments],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_diu_update_help(self):
        for arguments in (('diu', 'help'), ('diu', 'update', 'help'), ('update', 'help'), ('update', 'diu', 'help')):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu diu update', result.stdout)

    def test_update_help_describes_independent_softwares(self):
        for arguments in (("update", "help"), ("softwares", "update", "help"), ("softwares", "help")):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("diu softwares update", result.stdout)
                self.assertIn("diu update", result.stdout)

    def test_system_engine_help_hierarchy(self):
        commands = [f"diu system engine {engine} update" for engine in ("apt", "github", "flatpak")]
        for args in (("system", "help"), ("system", "engine", "help")):
            result = self.run_diu(*args)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("diu system engine update", result.stdout)
            for command in commands:
                self.assertIn(command, result.stdout)
            for engine in ("apt", "github", "flatpak"):
                self.assertNotIn(f"diu system {engine} update", result.stdout)
        for engine in ("apt", "github", "flatpak"):
            result = self.run_diu("system", "engine", engine, "update", "help")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn(f"diu system engine {engine} update", result.stdout)
            self.assertNotEqual(self.run_diu("system", engine, "update", "help").returncode, 0)

    def test_diu_update_version_help_and_dispatch(self):
        result = self.run_diu('diu', 'update', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu diu update <VERSION>', result.stdout)
        self.assertIn('diu diu update 1.1.7', result.stdout)
        source = ENTRYPOINT.read_text(encoding='utf-8')
        dispatch = source.split('dispatch_arguments() {', 1)[1].split('\n}\n', 1)[0]
        script = 'dispatch_arguments() {' + dispatch + '\n}\n' + r'''
diu_update() { printf 'ARG:%s\n' "$@"; }
dispatch_arguments "$@"
'''
        for args, expected in ((('diu', 'update', '1.1.7'), 0), (('diu', 'update', '1.1.7', 'extra'), 2)):
            with self.subTest(args=args):
                result = subprocess.run(['bash', '-c', script, 'bash', *args], text=True, capture_output=True, check=False)
                self.assertEqual(result.returncode, expected, result.stderr)
                if expected == 0:
                    self.assertEqual(result.stdout.strip(), 'ARG:1.1.7')

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
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
ENV_DEVOPS_USER=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
ENV_DEVOPS_USER=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
if ! git_init project; then
    exit 1
fi
if ! git -C "$ENV_DEVOPS_PROJECTS_ROOT/project" rev-parse --verify HEAD >/dev/null; then
    exit 1
fi
printf 'complete\\n'
'''
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-git-init-') as temporary_directory:
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
                env={
                    **{key: value for key, value in os.environ.items()
                       if not key.startswith('GIT_')},
                    'HOME': temporary_directory,
                    'XDG_CONFIG_HOME': temporary_directory,
                    'GIT_CONFIG_GLOBAL': str(Path(temporary_directory) / 'global.gitconfig'),
                    'GIT_CONFIG_SYSTEM': str(Path(temporary_directory) / 'system.gitconfig'),
                },
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
ENV_DEVOPS_PROJECTS_ROOT="$2"
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
ENV_DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_USER=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
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

    def run_provider_push(self, projects_root, provider, github_fetch_status='0', cicd=False):
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
github_git_fetch() {
    printf 'fetch:%s\\n' "$*"
    return "${GITHUB_FETCH_STATUS}"
}
github_git_push() { printf 'push:%s\\n' "$*"; }
PUSH_PROVIDER="$3"
GITHUB_FETCH_STATUS="$4"
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
ENV_DEVOPS_USER=devops
DEVOPS_GROUP=devops
ENV_DEVOPS_USER=devops
ENV_DEVOPS_PROJECTS_ROOT="$2"
if [[ "$5" == 1 ]]; then
    PROJECTS_CICD_RECONCILE=1
    project_version_get() { printf '1.0.0\\n'; }
    project_version_tag_for_head() { printf 'v1.0.0\\n'; }
    projects_cicd_replay_git_provider() {
        printf 'reconcile:%s\\n' "$*"
        PROJECTS_GIT_PUSH_STATUS=publié
        PROJECTS_CICD_REPLAY_GIT_STATUS='branche réconciliée'
    }
fi
git_push_provider project "$PUSH_PROVIDER" || exit $?
printf 'cicd-status:%s\\n' "${PROJECTS_GIT_CICD_STATUS:-}"
'''
        return subprocess.run(
            [
                'bash', '-c', script, 'bash', str(ROOT), str(projects_root),
                provider, github_fetch_status, '1' if cicd else '0',
            ],
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
        result = self.run_diu('help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu softwares', result.stdout)
        self.assertIn('→', result.stdout)

    def test_software_help_lists_available_commands(self):
        result = self.run_diu('softwares', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('diu softwares apt update', result.stdout)
        self.assertIn('diu softwares install apt <SOFTWARE>', result.stdout)
        self.assertIn('diu softwares update github [SOFTWARE]', result.stdout)
        self.assertIn('diu softwares flatpak update', result.stdout)

    def test_flatpak_help_is_available_without_configuration(self):
        result = self.run_diu('softwares', 'flatpak', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu softwares flatpak update', result.stdout)

    def test_terminal_help_does_not_publish(self):
        result = self.run_diu('projects', 'github', 'push', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects github push <ID PROJECT>', result.stdout)

    def test_cicd_help_does_not_start_the_flow(self):
        for arguments in (('projects', 'cicd', 'help'), ('projects', 'cicd', 'project', 'help')):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu projects cicd <ID PROJECT>', result.stdout)

    def test_github_release_help_is_available(self):
        result = self.run_diu('projects', 'github', 'release', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects github release <ID PROJECT>', result.stdout)

    def test_forgejo_push_help_describes_grouped_command(self):
        result = self.run_diu('projects', 'forgejo', 'push', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects forgejo push <ID PROJECT>', result.stdout)
        self.assertIn('diu projects forgejo push all', result.stdout)

    def test_projects_help_uses_canonical_git_init_command(self):
        result = self.run_diu('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git analyse <ID PROJECTS>', result.stdout)
        self.assertNotIn('diu projects gita <ID PROJECT>', result.stdout)
        self.assertIn('diu projects git commit <ID PROJECT> [COMMIT]', result.stdout)
        self.assertNotIn('diu projects gitc <ID PROJECT> [COMMIT]', result.stdout)
        self.assertIn('diu projects git init <ID PROJECT>', result.stdout)
        self.assertNotIn('diu projects giti <ID PROJECT>', result.stdout)
        self.assertIn('diu projects git status <ID PROJECTS>', result.stdout)
        self.assertNotIn('diu projects gits <ID PROJECTS>', result.stdout)
        self.assertIn('diu projects git update <ID PROJECT>', result.stdout)
        self.assertNotIn('diu projects gitu <ID PROJECT>', result.stdout)

    def test_projects_template_devops_help_does_not_generate_document(self):
        for arguments in (
            ('projects', 'help'),
            ('projects', 'template', 'help'),
            ('projects', 'template', '?'),
            ('projects', 'template', 'devops', 'help'),
            ('projects', 'template', 'devops', '?'),
            ('projects', 'template', 'devops', 'application', 'help'),
            ('projects', 'template', 'devops', 'application', '?'),
            ('projects', 'template', 'devops', 'template', 'help'),
            ('projects', 'template', 'devops', 'devops', 'help'),
            ('projects', 'template', 'devops', 'openspec', '?'),
        ):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                expected = arguments[3] if len(arguments) == 5 else '<ID PROJECT>'
                self.assertIn(f'diu projects template devops {expected}', result.stdout)
                self.assertNotIn('diu projects template <ID PROJECT> devops', result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_unknown_template_help_suggests_template_context(self):
        result = self.run_diu('projects', 'template', 'application', 'unknown', 'help')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('diu projects template help', result.stdout)

    def test_template_all_help_lists_selection_criteria_without_configuration(self):
        for ending in ('help', '?'):
            arguments = ('projects', 'template', 'devops', 'all', ending)
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu projects template devops all', result.stdout)
                self.assertIn('tous les projets configurés', result.stdout)
                for key in ('PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE',
                            'PROJECT_DOCKERED', 'PROJECT_DEBIAN_PACKAGE'):
                    self.assertIn(key, result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_and_template_help_advertise_individual_and_all_commands(self):
        for arguments in (('projects', 'help'), ('projects', 'template', 'help'),
                          ('projects', 'template', '?'),
                          ('projects', 'template', 'devops', 'help'),
                          ('projects', 'template', 'devops', '?')):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu projects template devops <ID PROJECT>', result.stdout)
                self.assertIn('diu projects template devops all', result.stdout)

    def test_template_all_help_rejects_extra_arguments_and_unknown_operation(self):
        for arguments, suggestion in (
                (('projects', 'template', 'devops', 'all', 'extra', 'help'),
                 'diu projects template devops help'),
                (('projects', 'template', 'unknown', 'all', '?'),
                 'diu projects template help')):
            with self.subTest(arguments=arguments):
                result = self.run_diu(*arguments)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertIn(suggestion, result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_template_devops_help_rejects_extra_arguments(self):
        result = self.run_diu('projects', 'template', 'devops', 'application', 'extra', 'help')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('diu projects template devops help', result.stdout)

    def test_template_help_rejects_invalid_project_paths(self):
        for project in ('../elsewhere', '.', '..', 'line\nbreak'):
            with self.subTest(project=project):
                result = self.run_diu('projects', 'template', 'devops', project, '?')
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertIn('diu projects template devops help', result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_old_devops_help_contexts_are_rejected(self):
        for ending in ('help', '?'):
            for arguments in (('application', 'devops'), ('all', 'devops'),
                              ('application',)):
                with self.subTest(arguments=arguments, ending=ending):
                    result = self.run_diu('projects', 'template', *arguments, ending)
                    self.assertEqual(result.returncode, 2, result.stderr)
                    context = 'diu projects template all help' if arguments[0] == 'all' else 'diu projects template help'
                    self.assertIn(context, result.stdout)
                    self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_create_help_describes_template_creation(self):
        result = self.run_diu('projects', 'create', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects create <ID PROJECT>', result.stdout)
        self.assertIn('modèle local', result.stdout)
        self.assertIn('génère DEVOPS.md', result.stdout)
        self.assertIn('prépare OpenSpec puis génère DEVOPS.md', result.stdout)

    def test_projects_template_openspec_help_without_configuration(self):
        for ending in ('help', '?'):
            for project in ('application', 'devops', 'openspec', "projet d'essai"):
                with self.subTest(project=project, ending=ending):
                    result = self.run_diu('projects', 'template', 'openspec', project, ending)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn(f'diu projects template openspec {project}', result.stdout)
                    self.assertIn('profil custom', result.stdout)
                    self.assertIn('OPENCODE=1', result.stdout)
                    self.assertIn('dossier .opencode présent', result.stdout)
                    self.assertIn('équivalent à OPENCODE=0', result.stdout)
                    self.assertIn('openspec update', result.stdout)
                    self.assertNotIn('variables.sh', result.stdout + result.stderr)
                    self.assertNotIn('tous les projets', result.stdout)
        for ending in ('help', '?'):
            for context in (('projects',), ('projects', 'template'),
                            ('projects', 'template', 'openspec'),
                            ('projects', 'template', 'openspec', 'application')):
                with self.subTest(context=context, ending=ending):
                    result = self.run_diu(*context, ending)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    project = 'application' if 'application' in context else '<ID PROJECT>'
                    self.assertIn(f'diu projects template openspec {project}', result.stdout)
                    self.assertIn(f'via ENV_DEVOPS_USER pour le projet {project}', result.stdout)

    def test_openspec_all_help_and_discovery_without_configuration(self):
        for ending in ('help', '?'):
            result = self.run_diu('projects', 'template', 'openspec', 'all', ending)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('diu projects template openspec all', result.stdout)
            self.assertIn('tous les projets configurés', result.stdout)
            self.assertIn('poursuit après un échec', result.stdout)
            self.assertIn('bilan', result.stdout)
            for key in ('PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE',
                        'PROJECT_DOCKERED', 'PROJECT_DEBIAN_PACKAGE'):
                self.assertIn(key, result.stdout)
            self.assertNotIn('variables.sh', result.stdout + result.stderr)
            self.assertNotIn('pour le projet all', result.stdout)
            for context in (('projects',), ('projects', 'template'),
                            ('projects', 'template', 'openspec')):
                result = self.run_diu(*context, ending)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu projects template openspec all', result.stdout)

    def test_projects_template_openspec_help_rejects_invalid_arguments(self):
        for arguments in (('openspec', 'application', 'extra', 'help'),
                          ('openspec', 'all', 'extra', '?'),
                          ('openspec', '../elsewhere', '?'),
                          ('openspec', '.', 'help'),
                          ('openspec', '..', '?'),
                          ('openspec', 'line\nbreak', 'help'),
                          ('application', 'openspec', 'help'),
                          ('all', 'openspec', '?')):
            with self.subTest(arguments=arguments):
                result = self.run_diu('projects', 'template', *arguments)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_all_models_help_and_discovery_without_configuration(self):
        for ending in ('help', '?'):
            for context in (('projects', 'template', 'all'),
                            ('projects', 'template', 'all', 'all')):
                with self.subTest(context=context, ending=ending):
                    result = self.run_diu(*context, ending)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    for text in ('diu projects template all all', 'Premier all', 'second all',
                                 'OpenSpec puis DevOps en dernier pour chaque projet',
                                 'échec OpenSpec empêche DevOps', 'poursuit', 'bilan',
                                 'PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE',
                                 'PROJECT_DOCKERED', 'PROJECT_DEBIAN_PACKAGE'):
                        self.assertIn(text, result.stdout)
                    self.assertNotIn('variables.sh', result.stdout + result.stderr)
            for context in (('projects',), ('projects', 'template')):
                result = self.run_diu(*context, ending)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('diu projects template all all', result.stdout)

    def test_all_models_help_rejects_individual_targets_and_extra_arguments(self):
        for ending in ('help', '?'):
            for arguments in (('all', 'application'), ('all', 'devops'),
                              ('all', 'openspec'), ('all', '../elsewhere'),
                              ('all', 'all', 'extra')):
                result = self.run_diu('projects', 'template', *arguments, ending)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertIn('diu projects template all help', result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_update_help_distinguishes_general_and_targeted_updates(self):
        for ending in ('help', '?'):
            result = self.run_diu('projects', 'update', ending)
            self.assertEqual(result.returncode, 0, result.stderr)
            for text in ('diu projects update', 'diu projects update <ID PROJECT>',
                         'tous les modèles', 'OpenSpec puis DevOps en dernier',
                         'diu projects template all all', 'variables générales'):
                self.assertIn(text, result.stdout)
            self.assertNotIn('variables.sh', result.stdout + result.stderr)
            for project in ('application', 'all', 'project with spaces'):
                result = self.run_diu('projects', 'update', project, ending)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f'diu projects update {project}', result.stdout)
                self.assertIn('variables générales de ce seul projet', result.stdout)
                self.assertNotIn('tous les modèles', result.stdout)
                self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_and_global_update_help_advertise_models(self):
        for ending in ('help', '?'):
            result = self.run_diu('projects', ending)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('diu projects update <ID PROJECT>', result.stdout)
            self.assertIn('diu projects update ', result.stdout)
            self.assertIn('tous les modèles', result.stdout)
            result = self.run_diu('update', ending)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('via diu projects update', result.stdout)
            self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_update_help_rejects_extra_arguments(self):
        for ending in ('help', '?'):
            result = self.run_diu('projects', 'update', 'application', 'extra', ending)
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertIn('diu projects update help', result.stdout)
            self.assertNotIn('variables.sh', result.stdout + result.stderr)

    def test_projects_clone_help_describes_clone_command(self):
        projects_result = self.run_diu('projects', 'help')
        clone_result = self.run_diu('projects', 'clone', 'help')

        self.assertEqual(projects_result.returncode, 0, projects_result.stderr)
        self.assertEqual(clone_result.returncode, 0, clone_result.stderr)
        command = 'diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>'
        self.assertIn(command, projects_result.stdout)
        self.assertIn(command, clone_result.stdout)

    def test_projects_gitlab_clone_help_does_not_start_cloning(self):
        projects_result = self.run_diu('projects', 'help')
        gitlab_result = self.run_diu('projects', 'gitlab', 'help')
        clone_result = self.run_diu('projects', 'gitlab', 'clone', 'help')
        question_result = self.run_diu('projects', 'gitlab', 'clone', '?')

        command = 'diu projects gitlab clone <ID PROJECT>'
        for result in (projects_result, gitlab_result, clone_result, question_result):
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(command, result.stdout)

    def test_projects_github_clone_help_does_not_start_cloning(self):
        projects_result = self.run_diu('projects', 'help')
        github_result = self.run_diu('projects', 'github', 'help')
        clone_result = self.run_diu('projects', 'github', 'clone', 'help')
        question_result = self.run_diu('projects', 'github', 'clone', '?')

        command = 'diu projects github clone <ID PROJECT>'
        for result in (projects_result, github_result, clone_result, question_result):
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(command, result.stdout)

    def test_projects_sync_help_describes_synchronization(self):
        projects_result = self.run_diu('projects', 'help')
        sync_result = self.run_diu('projects', 'sync', 'help')

        self.assertEqual(projects_result.returncode, 0, projects_result.stderr)
        self.assertEqual(sync_result.returncode, 0, sync_result.stderr)
        self.assertIn('diu projects sync <ID PROJECT>', projects_result.stdout)
        self.assertIn('diu projects sync all', projects_result.stdout)
        self.assertIn('diu projects sync <ID PROJECT>', sync_result.stdout)
        self.assertIn('diu projects sync all', sync_result.stdout)

    def test_projects_git_help_lists_analyse_init_and_update(self):
        result = self.run_diu('projects', 'git', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git analyse <ID PROJECTS>', result.stdout)
        self.assertIn('diu projects git init <ID PROJECT>', result.stdout)
        self.assertIn('diu projects git status <ID PROJECTS>', result.stdout)
        self.assertIn('diu projects git update <ID PROJECT>', result.stdout)

    def test_projects_git_help_lists_commit_command(self):
        result = self.run_diu('projects', 'git', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git commit <ID PROJECT> [COMMIT]', result.stdout)
        self.assertNotIn('diu projects gitc <ID PROJECT> [COMMIT]', result.stdout)

    def test_projects_git_commit_help_describes_canonical_command(self):
        result = self.run_diu('projects', 'git', 'commit', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git commit <ID PROJECT> [COMMIT]', result.stdout)

    def test_projects_help_lists_commit_all_command(self):
        result = self.run_diu('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git commit all', result.stdout)

    def test_projects_help_lists_forgejo_push_all_command(self):
        result = self.run_diu('projects', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects forgejo push all', result.stdout)

    def test_projects_git_commit_all_help_describes_command(self):
        result = self.run_diu('projects', 'git', 'commit', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git commit all', result.stdout)

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

    def test_github_push_uses_force_with_lease_for_the_branch(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)
            project_path = projects_root / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\n'
                'PROJECT_NAME="Projet"\n'
                'PROJECT_TYPE=application\n'
                'PROJECT_DOCKERED=No\n'
                'REMOTE_GITHUB_BASE_URL=https://github.example.test\n'
                'REMOTE_GITHUB_OWNER=owner\n'
                'REMOTE_GITHUB_REPOSITORY=project\n'
                'REMOTE_GITHUB_NAME=origin\n'
                'REMOTE_GITHUB_BRANCH=main\n'
                'REMOTE_GITHUB_SSL_VERIFY=Yes\n',
                encoding='utf-8',
            )

            result = self.run_provider_push(projects_root, 'github')

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(result.stdout.index('fetch:'), result.stdout.index('push:'))
        self.assertIn(
            '--force-with-lease --set-upstream origin main:main',
            result.stdout,
        )

    def test_github_cicd_routes_through_reconciliation(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as temporary_directory:
            projects_root = Path(temporary_directory)
            project_path = projects_root / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Projet\nPROJECT_TYPE=application\n'
                'PROJECT_DOCKERED=No\nREMOTE_GITHUB_BASE_URL=https://github.example.test\n'
                'REMOTE_GITHUB_OWNER=owner\nREMOTE_GITHUB_REPOSITORY=project\n'
                'REMOTE_GITHUB_NAME=origin\nREMOTE_GITHUB_BRANCH=main\n', encoding='utf-8')
            result = self.run_provider_push(projects_root, 'github', cicd=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('reconcile:github ', result.stdout)
        self.assertIn('cicd-status:branche réconciliée', result.stdout)
        self.assertNotIn('fetch:', result.stdout)
        self.assertNotIn('push:', result.stdout)

    def test_github_push_stops_when_fetch_fails(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            projects_root = Path(temporary_directory)
            project_path = projects_root / 'project'
            project_path.mkdir()
            (project_path / 'project.env').write_text(
                'PROJECT_ID=project\n'
                'PROJECT_NAME="Projet"\n'
                'PROJECT_TYPE=application\n'
                'PROJECT_DOCKERED=No\n'
                'REMOTE_GITHUB_BASE_URL=https://github.example.test\n'
                'REMOTE_GITHUB_OWNER=owner\n'
                'REMOTE_GITHUB_REPOSITORY=project\n'
                'REMOTE_GITHUB_NAME=origin\n'
                'REMOTE_GITHUB_BRANCH=main\n'
                'REMOTE_GITHUB_SSL_VERIFY=Yes\n',
                encoding='utf-8',
            )

            result = self.run_provider_push(projects_root, 'github', '1')

        self.assertEqual(result.returncode, 1)
        self.assertIn('fetch:', result.stdout)
        self.assertNotIn('push:', result.stdout)

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
        self.assertIn(
            '--force-with-lease=refs/heads/main: --set-upstream origin main:main',
            result.stdout,
        )

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
        result = self.run_diu('projects', 'git', 'status', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects git status <ID PROJECTS>', result.stdout)

    def test_unknown_root_command_suggests_root_help(self):
        result = self.run_diu('inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Classe d'actions inconnue : inconnue", result.stdout)
        self.assertIn('diu help', result.stdout)

    def test_unknown_software_command_suggests_contextual_help(self):
        result = self.run_diu('softwares', 'inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Action inconnue pour la classe 'softwares' : inconnue", result.stdout)
        self.assertIn('diu softwares help', result.stdout)



class GitCloneArgumentTests(unittest.TestCase):
    def run_clone_start(self, failure='0'):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.clone-arguments-') as directory:
            source = ENTRYPOINT.parent / 'modules/projects/git.sh'
            match = re.search(r'^git_init_clone\(\) \{\n.*?^\}', source.read_text(), re.M|re.S)
            self.assertIsNotNone(match)
            script = match.group() + r'''
print_error() { printf '%s\n' "$*" >&2; }
mkdir() { printf 'ARG:<%s>\n' "$@"; return "$MKDIR_FAILURE"; }
check_devops_user() { printf 'CHECKUSER\n'; return 1; }
ENV_DEVOPS_PROJECTS_ROOT="$1/root with spaces[*]"
git_init_clone 'project with spaces[*]'
'''
            return subprocess.run(
                ['bash', '-c', script, 'fixture', directory],
                env={**os.environ, 'MKDIR_FAILURE': failure},
                text=True, capture_output=True, check=False), directory

    def test_clone_directory_is_one_literal_argument(self):
        result, directory = self.run_clone_start()
        arguments = [line for line in result.stdout.splitlines() if line.startswith('ARG:')]
        self.assertEqual(arguments, ['ARG:<-p>', 'ARG:<-->',
                                    f'ARG:<{directory}/root with spaces[*]/project with spaces[*]>'])
        self.assertIn('CHECKUSER', result.stdout)

    def test_directory_creation_failure_stops_before_user_check(self):
        result, _ = self.run_clone_start('7')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('CHECKUSER', result.stdout)
        self.assertIn('Impossible de créer', result.stderr)


if __name__ == '__main__':
    unittest.main()
