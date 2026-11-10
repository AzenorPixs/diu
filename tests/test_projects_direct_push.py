"""Commandes directes : sélection de version et partage du flux Git CI/CD."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DirectPushTests(unittest.TestCase):
    def run_case(self, provider, version='', existing=False, fail_commit=False):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.direct-push-') as tmp:
            project = Path(tmp) / 'fixture'
            project.mkdir()
            (project / '.git').mkdir()
            (project / 'project.env').write_text('PROJECT_VERSION=9.9.9\n')
            script = r'''
set -Eeuo pipefail
source "$1/lib/project-version.sh"
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
date() { printf '2026.11.10.12.34\n'; }
runuser() {
  shift 3
  if [[ "$1" == git ]]; then [[ "$EXISTING" == 1 ]]; return; fi
  "$@"
}
git_commit() { printf 'COMMIT:%s:%s:%s\n' "$1" "$2" "$3"; [[ "$FAIL_COMMIT" == 0 ]]; }
projects_cicd_replay_prepare() { PROJECTS_CICD_REPLAY_ROOT="$2/replay-root"; mkdir -p "$PROJECTS_CICD_REPLAY_ROOT"; printf 'REPLAY:%s\n' "$3"; }
forgejo_push() { printf 'PUSH:forgejo:%s:%s:%s\n' "$1" "$PROJECTS_DIRECT_PUSH_VERSION" "$PROJECTS_CICD_RECONCILE"; }
gitlab_push() { printf 'PUSH:gitlab:%s:%s:%s\n' "$1" "$PROJECTS_DIRECT_PUSH_VERSION" "$PROJECTS_CICD_RECONCILE"; }
github_push() { printf 'PUSH:github:%s:%s:%s\n' "$1" "$PROJECTS_DIRECT_PUSH_VERSION" "$PROJECTS_CICD_RECONCILE"; }
projects_provider_push_direct "$3" fixture "$4"
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), tmp, provider, version],
                                    env={**os.environ, 'EXISTING': str(int(existing)), 'FAIL_COMMIT': str(int(fail_commit))},
                                    text=True, capture_output=True)
            self.assertEqual((project / 'project.env').read_text(), 'PROJECT_VERSION=9.9.9\n')
            return result

    def test_explicit_and_automatic_selection_for_every_provider(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            for version, expected in [('1.0.1', '1.0.1'), ('', '2026.11.10.12.34')]:
                with self.subTest(provider=provider, version=version):
                    result = self.run_case(provider, version)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn(f'COMMIT:fixture:{expected}:v{expected}', result.stdout)
                    self.assertIn(f'PUSH:{provider}:fixture:{expected}:1', result.stdout)

    def test_existing_version_uses_isolated_replay(self):
        result = self.run_case('forgejo', '1.0.1', existing=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('REPLAY:v1.0.1', result.stdout)
        self.assertNotIn('COMMIT:', result.stdout)
        self.assertIn('PUSH:forgejo:fixture:1.0.1:1', result.stdout)

    def test_invalid_version_collision_and_commit_failure_stop_push(self):
        for result in (self.run_case('github', '01.0.0'),
                       self.run_case('gitlab', '', existing=True),
                       self.run_case('forgejo', '1.0.0', fail_commit=True)):
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('PUSH:', result.stdout)

    def test_real_git_commit_and_replay_preserve_pending_changes(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.direct-git-') as tmp:
            project = Path(tmp) / 'fixture'
            project.mkdir()
            def git(*args):
                return subprocess.run(['git', '-C', str(project), *args], check=True, text=True, capture_output=True).stdout.strip()
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / '.gitignore').write_text('project.env\nconfig/\n')
            (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_NAME=Fixture\nPROJECT_TYPE=BASH\nGIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\nPROJECT_VERSION=9.9.9\n')
            (project / 'data').write_text('first\n')
            script = r"""
set -Eeuo pipefail
source "$1/lib/project-version.sh"
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
DEVOPS_GROUP=fixture
runuser() { shift 3; "$@"; }
check_devops_user() { :; }
print_info() { :; }
print_success() { :; }
print_title() { :; }
print_error() { printf '%s\n' "$*" >&2; }
forgejo_push() {
    printf 'CONTENT:%s\n' "$(cat "$ENV_DEVOPS_PROJECTS_ROOT/fixture/data")"
    printf 'TAG:%s\n' "$(git -C "$ENV_DEVOPS_PROJECTS_ROOT/fixture" rev-parse HEAD)"
}
projects_provider_push_direct forgejo fixture 1.0.1
printf 'pending\n' > "$ENV_DEVOPS_PROJECTS_ROOT/fixture/data"
projects_provider_push_direct forgejo fixture 1.0.1
"""
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), tmp], text=True, capture_output=True,
                                    env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_NOSYSTEM': '1', 'TMPDIR': tmp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.count('CONTENT:first'), 2)
            self.assertEqual((project / 'data').read_text(), 'pending\n')
            self.assertEqual(git('rev-parse', 'HEAD'), git('rev-parse', 'v1.0.1^{commit}'))
            self.assertEqual(list(Path(tmp).glob('diu-cicd-replay.*')), [])

    def test_clean_tree_creates_local_tag_without_unauthenticated_remote_probe(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.direct-clean-') as tmp:
            project = Path(tmp) / 'fixture'
            project.mkdir()
            (project / '.gitignore').write_text('project.env\n')
            (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_NAME=Fixture\nPROJECT_TYPE=BASH\nGIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\nPROJECT_VERSION=1.0.0\n')
            def git(*args):
                return subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True, text=True).stdout.strip()
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            git('add', '.')
            git('commit', '-qm', 'fixture')
            git('remote', 'add', 'origin', 'https://invalid.example/owner/fixture.git')
            script = r"""
set -Eeuo pipefail
source "$1/lib/project-version.sh"
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { shift 3; "$@"; }
check_devops_user() { :; }
print_info() { :; }
print_success() { :; }
print_title() { :; }
print_error() { printf '%s\n' "$*" >&2; }
github_push() { :; }
projects_provider_push_direct github fixture 1.0.2
"""
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), tmp],
                                    env={**os.environ, 'GIT_CONFIG_GLOBAL':'/dev/null', 'GIT_CONFIG_NOSYSTEM':'1'},
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(git('rev-parse', 'v1.0.2^{commit}'), git('rev-parse', 'HEAD'))

    def test_replay_initializes_credentials_in_source_and_reuses_them(self):
        for provider in ('github', 'gitlab'):
            with self.subTest(provider=provider), tempfile.TemporaryDirectory(dir=ROOT, prefix='.direct-auth-') as tmp:
                project = Path(tmp) / 'fixture'
                project.mkdir()
                (project / 'config').mkdir()
                (project / '.gitignore').write_text('project.env\nconfig/\n')
                (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_VERSION=1.0.2\n')
                def git(*args):
                    subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
                git('init', '-q', '-b', 'main')
                git('config', 'user.name', 'Fixture')
                git('config', 'user.email', 'fixture@example.test')
                git('add', '.')
                git('commit', '-qm', 'fixture')
                git('tag', 'v1.0.2')
                script = r"""
set -Eeuo pipefail
source "$1/lib/project-version.sh"
source "$1/modules/projects/git.sh"
source "$1/lib/github-auth.sh"
source "$1/lib/gitlab-auth.sh"
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { shift 3; "$@"; }
print_info() { :; }
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
github_push() { [[ -f "$ENV_DEVOPS_PROJECTS_ROOT/fixture/config/github.username" && -f "$ENV_DEVOPS_PROJECTS_ROOT/fixture/config/github.token" ]]; }
gitlab_push() { [[ -f "$ENV_DEVOPS_PROJECTS_ROOT/fixture/config/gitlab.username" && -f "$ENV_DEVOPS_PROJECTS_ROOT/fixture/config/gitlab.token" ]]; }
projects_provider_push_direct "$3" fixture 1.0.2
projects_provider_push_direct "$3" fixture 1.0.2 </dev/null
"""
                result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), tmp, provider],
                                        input='fixture-user\nfixture-token\nfixture-token\n', text=True, capture_output=True,
                                        env={**os.environ, 'TMPDIR': tmp, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_NOSYSTEM': '1'})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue((project / 'config' / f'{provider}.username').is_file())
                self.assertTrue((project / 'config' / f'{provider}.token').is_file())
                self.assertNotIn('fixture-token', result.stdout + result.stderr)
                self.assertEqual(list(Path(tmp).glob('diu-cicd-replay.*')), [])

    def test_replay_stops_before_clone_when_credential_preparation_fails(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.direct-auth-fail-') as tmp:
            project = Path(tmp) / 'fixture'
            project.mkdir()
            (project / '.git').mkdir()
            (project / 'project.env').write_text('PROJECT_VERSION=1.0.2\n')
            script = r"""
source "$1/lib/project-version.sh"
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { return 0; }
print_info() { :; }
print_error() { :; }
_github_ensure_api_credentials() { return 1; }
projects_cicd_replay_prepare() { echo 'unexpected clone'; }
projects_provider_push_direct github fixture 1.0.2
"""
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), tmp], text=True, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('unexpected clone', result.stdout)

    def test_dispatch_forwards_optional_version(self):
        script = r'''
source <(sed -n '/^manage_project_action() {/,/^}/p' "$1/root-install-debian.sh")
projects_provider_push_direct() { printf '%s:%s:%s\n' "$1" "$2" "$3"; }
manage_project_action forgejo push fixture 1.0.1
manage_project_action gitlab push fixture
manage_project_action github push fixture 2.0.0
'''
        result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT)], text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ['forgejo:fixture:1.0.1', 'gitlab:fixture:', 'github:fixture:2.0.0'])


if __name__ == '__main__':
    unittest.main()
