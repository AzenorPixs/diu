"""Préparation du rejeu CI/CD sur des dépôts Git isolés."""
import os
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CicdReplayTests(unittest.TestCase):
    def test_real_debian_builder_uses_only_tagged_payload(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp) / 'projets avec espaces'
            base.mkdir()
            project = base / 'fixture'
            (project / 'build').mkdir(parents=True)
            (project / 'payload').mkdir()
            (project / 'payload/data').write_text('tagged\n')
            (project / 'build/debian-package.json').write_text(json.dumps({
                'package': 'fixture', 'architecture': 'all', 'maintainer': 'Fixture <fixture@example.test>',
                'description': 'Fixture', 'files': [{'source': 'payload', 'destination': '/opt/fixture'}]}))
            (project / '.gitignore').write_text('project.env\nconfig/\ndist/\n')
            def git(*args):
                subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            git('add', '.')
            git('commit', '-qm', 'tagged')
            git('tag', 'v1.0.0')
            (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_NAME=Fixture\nPROJECT_TYPE=BASH\n'
                'PROJECT_VERSION=1.0.0\nPROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=Yes\n')
            (project / 'payload/data').write_text('modified\n')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
source "$1/modules/projects/debian-build.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() {
  shift 3
  if [[ "$1" == rm ]]; then printf 'permission refusée pour devops\n' >&2; return 1; fi
  "$@"
}
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { :; }
print_title() { :; }
cicd_project fixture automatic vautomatic
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('permission refusée pour devops', result.stderr)
            self.assertEqual(list(Path(temp).glob('diu-cicd-replay.*')), [])
            packages = list((project / 'dist/replay/v1.0.0').glob('*/fixture_1.0.0_all.deb'))
            self.assertEqual(len(packages), 1)
            extract = base / 'extracted'
            subprocess.run(['dpkg-deb', '-x', str(packages[0]), str(extract)], check=True)
            self.assertEqual((extract / 'opt/fixture/data').read_text(), 'tagged\n')
            self.assertEqual((project / 'payload/data').read_text(), 'modified\n')

    def test_missing_tag_aligns_advanced_branch(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp)
            project, remote = base / 'fixture', base / 'remote.git'
            project.mkdir()
            def git(path, *args):
                return subprocess.run(['git', '-C', str(path), *args], check=True, capture_output=True, text=True)
            subprocess.run(['git', 'init', '-q', '--bare', str(remote)], check=True)
            git(project, 'init', '-q', '-b', 'main')
            git(project, 'config', 'user.name', 'Fixture')
            git(project, 'config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('old\n')
            git(project, 'add', '.')
            git(project, 'commit', '-qm', 'old')
            git(project, 'tag', 'v1.0.0')
            tagged = git(project, 'rev-parse', 'HEAD').stdout.strip()
            (project / 'tracked').write_text('new\n')
            git(project, 'commit', '-qam', 'new')
            newer = git(project, 'rev-parse', 'HEAD').stdout.strip()
            git(project, 'push', str(remote), 'main')
            git(project, 'checkout', '-q', '--detach', 'v1.0.0')
            tagged = git(project, 'rev-parse', 'HEAD').stdout.strip()
            git(project, 'remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
REMOTE_FORGEJO_BASE_URL=https://forge.example
REMOTE_FORGEJO_OWNER=owner
REMOTE_FORGEJO_REPOSITORY=fixture
runuser() { shift 3; "$@"; }
print_info() { printf '%s\n' "$*"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_git_transport() {
  local provider="$1" path="$2" operation="$3"; shift 3
  case "$operation" in
    ls-remote) shift; git -C "$path" ls-remote "$BARE" "$@" ;;
    fetch) shift 2; git -C "$path" fetch --no-tags "$BARE" "$@" ;;
    push) shift; git -C "$path" push "$BARE" "$@" ;;
  esac
}
projects_cicd_replay_git_provider forgejo "$2" origin main v1.0.0
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(project)],
                                    text=True, capture_output=True, env={**os.environ, 'BARE': str(remote), 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(git(remote, 'rev-parse', 'refs/heads/main').stdout.strip(), tagged)
            self.assertEqual(git(remote, 'rev-parse', 'refs/tags/v1.0.0^{commit}').stdout.strip(), tagged)

    def test_interrupt_removes_private_replay_context(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp)
            project = base / 'fixture'
            project.mkdir()
            def git(*args):
                subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('tagged\n')
            (project / '.gitignore').write_text('project.env\nconfig/\n.cicd-replay.*\n')
            git('add', '.')
            git('commit', '-qm', 'tagged')
            git('tag', 'v1.0.0')
            (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_NAME=Fixture\n'
                'PROJECT_TYPE=BASH\nPROJECT_VERSION=1.0.0\nPROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=Yes\n')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { shift 3; "$@"; }
print_error() { :; }
print_info() { :; }
print_title() { :; }
projects_build_deb() { kill -TERM "$BASHPID"; }
cicd_project fixture automatic vautomatic
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(list(Path(temp).glob('diu-cicd-replay.*')), [])

    def test_remote_tag_conflict_uses_expected_sha_lease(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            project = Path(temp) / 'fixture'
            project.mkdir()
            def git(*args):
                subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('tagged\n')
            git('add', '.')
            git('commit', '-qm', 'tagged')
            git('tag', 'v1.0.0')
            git('remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
REMOTE_FORGEJO_BASE_URL=https://forge.example
REMOTE_FORGEJO_OWNER=owner
REMOTE_FORGEJO_REPOSITORY=fixture
runuser() { shift 3; "$@"; }
print_info() { :; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_git_transport() {
  case "$3" in
    ls-remote) printf '%s\trefs/heads/main\n%040d\trefs/tags/v1.0.0\n' "$(git -C "$2" rev-parse HEAD)" 1 ;;
    fetch) git -C "$2" update-ref refs/remotes/origin/main "$(git -C "$2" rev-parse HEAD)" ;;
    push) printf '%s\n' "$@" >> "$PUSH_LOG" ;;
  esac
}
projects_cicd_replay_git_provider forgejo "$2" origin main v1.0.0
printf '%s\n' "$PROJECTS_CICD_REPLAY_GIT_STATUS"
'''
            push_log = Path(temp) / 'push'
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(project)],
                                    text=True, capture_output=True, env={**os.environ, 'PUSH_LOG': str(push_log), 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('tag remplacé, artefacts à vérifier', result.stdout)
            self.assertIn('--force-with-lease=refs/tags/v1.0.0:' + '0' * 39 + '1', push_log.read_text())
            self.assertIn('refs/tags/v1.0.0:refs/tags/v1.0.0', push_log.read_text())

    def test_recognized_unavailability_is_informational(self):
        script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
_projects_cicd_replay_git_provider() { printf unavailable > "$projects_git_unavailable_file"; return 1; }
projects_cicd_replay_git_provider forgejo /unused origin main v1.0.0
printf 'STATUS:%s\n' "$PROJECTS_GIT_PUSH_STATUS"
'''
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-network-test-') as temp:
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('STATUS:indisponible', result.stdout)
        self.assertNotIn('❌', result.stdout + result.stderr)

    def test_docker_build_context_contains_only_tagged_files(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp)
            project = base / 'fixture'
            project.mkdir()
            def git(*args):
                subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('tagged\n')
            (project / '.gitignore').write_text('project.env\nconfig/\n.cicd-replay.*\n')
            (project / '.gitattributes').write_text('tracked export-ignore\n')
            git('add', '.')
            git('commit', '-qm', '1.0.0')
            git('tag', 'v1.0.0')
            (project / 'project.env').write_text('PROJECT_ID=fixture\nPROJECT_NAME=Fixture\n'
                'PROJECT_TYPE=BASH\nPROJECT_VERSION=1.0.0\nPROJECT_DOCKERED=Yes\nPROJECT_DEBIAN_PACKAGE=Yes\n'
                'REMOTE_FORGEJO_BASE_URL=https://forge.example\nREMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=fixture\nREMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\nREMOTE_FORGEJO_SSL_VERIFY=Yes\n')
            (project / 'config').mkdir()
            (project / 'config/github.token').write_text('fixture-token\n')
            (project / 'tracked').write_text('modified\n')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { shift 3; "$@"; }
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_title() { :; }
projects_cicd_replay_git_provider() { PROJECTS_CICD_REPLAY_GIT_STATUS='déjà en ligne'; }
projects_docker_build() {
  test "$(cat "$PROJECTS_CICD_DOCKER_CONTEXT/tracked")" = tagged
  test ! -e "$PROJECTS_CICD_DOCKER_CONTEXT/.git"
  test ! -e "$PROJECTS_CICD_DOCKER_CONTEXT/project.env"
  test ! -e "$PROJECTS_CICD_DOCKER_CONTEXT/config/github.token"
  test -f "$PROJECTS_CICD_PROJECT_ENV"
  printf 'CONTEXTE-ISOLÉ\n'
}
projects_build_deb() {
  mkdir -p "$ENV_DEVOPS_PROJECTS_ROOT/$1/dist"
  cp "$ENV_DEVOPS_PROJECTS_ROOT/$1/tracked" "$ENV_DEVOPS_PROJECTS_ROOT/$1/dist/fixture_1.0.0_all.deb"
}
publish_release_debian() { printf 'DEBIAN-PUBLIÉ\n'; }
projects_forgejo_release() { printf 'DOCKER-UNEXPECTED\n'; return 1; }
cicd_project fixture automatic vautomatic
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('CONTEXTE-ISOLÉ', result.stdout, result.stderr)
            self.assertIn('immutabilité du tag distant non confirmée', result.stdout)
            self.assertIn('DEBIAN-PUBLIÉ', result.stdout)
            self.assertNotIn('DOCKER-UNEXPECTED', result.stdout)
            self.assertNotIn('ERROR:', result.stderr)
            self.assertNotIn('fixture-token', result.stdout + result.stderr)
            self.assertEqual(list(Path(temp).glob('diu-cicd-replay.*')), [])
            unavailable = script.replace(
                "publish_release_debian() { printf 'DEBIAN-PUBLIÉ\\n'; }",
                "publish_release_debian() { projects_git_note_unavailable http 503; return 1; }")
            self.assertNotEqual(unavailable, script)
            result = subprocess.run(['bash', '-c', unavailable, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('terminé avec indisponibilités', result.stdout)
            self.assertIn('potentiellement partielle', result.stdout)
            self.assertNotIn('DOCKER-UNEXPECTED', result.stdout)

    def test_full_debian_replay_uses_tagged_sources_and_preserves_index(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp)
            project = base / 'fixture'
            project.mkdir()
            def git(*args):
                return subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True, text=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('tagged\n')
            (project / '.gitignore').write_text('project.env\nconfig/\ndist/\n.cicd-replay.*\n')
            git('add', '.')
            git('commit', '-qm', '1.0.0')
            git('tag', 'v1.0.0')
            (project / 'project.env').write_text(
                'PROJECT_ID=fixture\nPROJECT_NAME=Fixture\nPROJECT_TYPE=BASH\n'
                'PROJECT_VERSION=1.0.0\nPROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=Yes\n'
                'ENV_DEVOPS_PROJECTS_ROOT=/unexpected\n'
                'REMOTE_FORGEJO_BASE_URL=https://forge.example\nREMOTE_FORGEJO_OWNER=owner\n'
                'REMOTE_FORGEJO_REPOSITORY=fixture\nREMOTE_FORGEJO_NAME=origin\n'
                'REMOTE_FORGEJO_BRANCH=main\nREMOTE_FORGEJO_SSL_VERIFY=Yes\n')
            (project / 'tracked').write_text('staged\n')
            git('add', 'tracked')
            (project / 'tracked').write_text('unstaged\n')
            (project / 'extra').write_text('untracked\n')
            before = git('status', '--porcelain=v1').stdout
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { shift 3; "$@"; }
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
print_title() { printf 'TITLE:%s\n' "$*"; }
git_commit() { printf 'unexpected commit\n' >&2; return 1; }
projects_cicd_replay_git_provider() { PROJECTS_CICD_REPLAY_GIT_STATUS='déjà en ligne'; }
projects_build_deb() {
  mkdir -p "$ENV_DEVOPS_PROJECTS_ROOT/$1/dist"
  cp "$ENV_DEVOPS_PROJECTS_ROOT/$1/tracked" "$ENV_DEVOPS_PROJECTS_ROOT/$1/dist/fixture_1.0.0_all.deb"
}
publish_release_debian() {
  test "$(cat "$ENV_DEVOPS_PROJECTS_ROOT/$1/dist/fixture_1.0.0_all.deb")" = tagged
  printf 'PUBLICATION-ISOLÉE\n'
}
cicd_project fixture automatic vautomatic
cicd_project fixture automatic vautomatic
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            for step in range(1, 7):
                self.assertIn(f'Étape {step}/6', result.stdout)
            self.assertIn('modifications locales conservées', result.stdout.lower())
            self.assertEqual(result.stdout.count('PUBLICATION-ISOLÉE'), 2)
            self.assertEqual(git('status', '--porcelain=v1').stdout, before)
            self.assertEqual((project / 'tracked').read_text(), 'unstaged\n')
            artifacts = list((project / 'dist/replay/v1.0.0').glob('*/fixture_1.0.0_all.deb'))
            self.assertEqual(len(artifacts), 1)
            self.assertEqual(artifacts[0].read_text(), 'tagged\n')
            self.assertEqual(list(Path(temp).glob('diu-cicd-replay.*')), [])

    def test_replay_aligns_remote_branch_ahead_and_existing_tag(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            base = Path(temp)
            project, remote = base / 'fixture', base / 'remote.git'
            project.mkdir()
            def git(path, *args):
                return subprocess.run(['git', '-C', str(path), *args], check=True, capture_output=True, text=True)
            subprocess.run(['git', 'init', '-q', '--bare', str(remote)], check=True)
            git(project, 'init', '-q', '-b', 'main')
            git(project, 'config', 'user.name', 'Fixture')
            git(project, 'config', 'user.email', 'fixture@example.test')
            (project / 'tracked').write_text('old\n')
            git(project, 'add', '.')
            git(project, 'commit', '-qm', 'old')
            git(project, 'tag', 'v1.0.0')
            (project / 'tracked').write_text('new\n')
            git(project, 'commit', '-qam', 'new')
            newer = git(project, 'rev-parse', 'HEAD').stdout.strip()
            git(project, 'push', str(remote), 'main', 'refs/tags/v1.0.0')
            git(project, 'checkout', '-q', '--detach', 'v1.0.0')
            tagged = git(project, 'rev-parse', 'HEAD').stdout.strip()
            git(project, 'remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
REMOTE_FORGEJO_BASE_URL=https://forge.example
REMOTE_FORGEJO_OWNER=owner
REMOTE_FORGEJO_REPOSITORY=fixture
runuser() { shift 3; "$@"; }
print_info() { printf '%s\n' "$*"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_git_transport() {
  local provider="$1" path="$2" operation="$3"; shift 3
  case "$operation" in
    ls-remote) shift; git -C "$path" ls-remote "$BARE" "$@" ;;
    fetch) shift 2; git -C "$path" fetch --no-tags "$BARE" "$@" ;;
    push) shift; git -C "$path" push "$BARE" "$@" ;;
  esac
}
projects_cicd_replay_git_provider forgejo "$2" origin main v1.0.0
printf 'STATUS:%s\n' "$PROJECTS_CICD_REPLAY_GIT_STATUS"
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(project)],
                                    text=True, capture_output=True, env={**os.environ, 'BARE': str(remote), 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('STATUS:branche alignée sur le commit local', result.stdout)
            self.assertEqual(git(remote, 'rev-parse', 'refs/heads/main').stdout.strip(), tagged)

    def test_prepare_failure_removes_temporary_context(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            project = Path(temp) / 'fixture'
            project.mkdir()
            def git(*args):
                subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked.txt').write_text('tagged\n')
            git('add', '.')
            git('commit', '-qm', '1.0.0')
            git('tag', 'v1.0.0')
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
runuser() { shift 3; "$@"; }
print_error() { printf '%s\n' "$*" >&2; }
if projects_cicd_replay_prepare fixture "$2" v1.0.0; then exit 1; fi
test -z "$PROJECTS_CICD_REPLAY_ROOT"
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(project)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(list(Path(temp).glob('diu-cicd-replay.*')), [])

    def test_prepare_uses_tagged_commit_and_preserves_local_changes(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-replay-test-') as temp:
            project = Path(temp) / 'fixture'
            project.mkdir()
            def git(*args):
                return subprocess.run(['git', '-C', str(project), *args], check=True, capture_output=True, text=True)
            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (project / 'tracked.txt').write_text('tagged\n')
            (project / '.gitignore').write_text('project.env\nconfig/\n.cicd-replay.*\n')
            git('add', '.')
            git('commit', '-qm', '1.0.0')
            git('tag', 'v1.0.0')
            (project / 'project.env').write_text('PROJECT_VERSION=1.0.0\n')
            (project / 'config').mkdir()
            (project / 'config/github.token').write_text('fixture-token\n')
            (project / 'tracked.txt').write_text('staged\n')
            git('add', 'tracked.txt')
            (project / 'tracked.txt').write_text('unstaged\n')
            (project / 'extra.txt').write_text('untracked\n')
            before = git('status', '--porcelain=v1').stdout
            script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
runuser() { shift 3; "$@"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_prepare fixture "$2" v1.0.0
test "$(cat "$PROJECTS_CICD_REPLAY_ROOT/fixture/tracked.txt")" = tagged
test ! -e "$PROJECTS_CICD_REPLAY_ROOT/fixture/extra.txt"
test "$(git -C "$PROJECTS_CICD_REPLAY_ROOT/fixture" rev-parse HEAD)" = "$(git -C "$2" rev-parse v1.0.0^{commit})"
rm -rf -- "$PROJECTS_CICD_REPLAY_ROOT"
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(project)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': temp})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(git('status', '--porcelain=v1').stdout, before)
            self.assertEqual((project / 'tracked.txt').read_text(), 'unstaged\n')
