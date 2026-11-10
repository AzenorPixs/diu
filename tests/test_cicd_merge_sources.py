"""Réconciliation CI/CD sur des dépôts Git temporaires."""
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CicdMergeSourcesTests(unittest.TestCase):
    def test_tag_changed_after_read_is_not_overwritten(self):
        import os
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-merge-test-') as tmp:
            base = Path(tmp)
            local, bare = base / 'local', base / 'remote.git'
            local.mkdir()

            def git(path, *args):
                return subprocess.run(['git', '-C', str(path), *args], check=True,
                                      capture_output=True, text=True).stdout.strip()

            subprocess.run(['git', 'init', '-q', '--bare', str(bare)], check=True)
            git(local, 'init', '-q', '-b', 'main')
            git(local, 'config', 'user.name', 'Fixture')
            git(local, 'config', 'user.email', 'fixture@example.test')
            (local / 'source.txt').write_text('first\n')
            git(local, 'add', '.')
            git(local, 'commit', '-qm', 'first')
            first = git(local, 'rev-parse', 'HEAD')
            (local / 'source.txt').write_text('second\n')
            git(local, 'commit', '-qam', 'second')
            second = git(local, 'rev-parse', 'HEAD')
            (local / 'source.txt').write_text('third\n')
            git(local, 'commit', '-qam', 'third')
            third = git(local, 'rev-parse', 'HEAD')
            git(local, 'tag', 'v1.0.0')
            git(local, 'push', '-q', str(bare), 'main')
            git(bare, 'update-ref', 'refs/tags/v1.0.0', first)
            git(local, 'remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')
            script = r'''
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
REMOTE_FORGEJO_BASE_URL=https://forge.example
REMOTE_FORGEJO_OWNER=owner
REMOTE_FORGEJO_REPOSITORY=fixture
runuser() { shift 3; "$@"; }
print_info() { :; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_git_transport() {
  local path="$2" operation="$3"; shift 3
  case "$operation" in
    ls-remote) shift; git -C "$path" ls-remote "$BARE" "$@" ;;
    fetch) shift 2; git -C "$path" fetch --no-tags "$BARE" "$@" ;;
    push) shift; git -C "$BARE" update-ref refs/tags/v1.0.0 "$SECOND"; git -C "$path" push "$BARE" "$@" ;;
  esac
}
projects_cicd_replay_git_provider forgejo "$2" origin main v1.0.0
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(local)],
                                    text=True, capture_output=True,
                                    env={**os.environ, 'BARE': str(bare), 'SECOND': second, 'TMPDIR': tmp})
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(git(bare, 'rev-parse', 'refs/tags/v1.0.0'), second)
            self.assertEqual(git(local, 'rev-parse', 'v1.0.0'), third)
            stable_script = script.replace('git -C "$BARE" update-ref refs/tags/v1.0.0 "$SECOND"; ', '')
            result = subprocess.run(['bash', '-c', stable_script, 'fixture', str(ROOT), str(local)],
                                    text=True, capture_output=True,
                                    env={**os.environ, 'BARE': str(bare), 'SECOND': second, 'TMPDIR': tmp})
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(git(bare, 'rev-parse', 'refs/tags/v1.0.0'), third)

    def test_local_deletion_wins_modify_delete_conflict(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-merge-test-') as tmp:
            local = Path(tmp) / 'local'
            local.mkdir()

            def git(*args):
                return subprocess.run(['git', '-C', str(local), *args], check=True,
                                      capture_output=True, text=True).stdout.strip()

            git('init', '-q', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.test')
            (local / 'source.txt').write_text('base\n')
            git('add', '.')
            git('commit', '-qm', 'base')
            git('branch', 'remote')
            git('rm', '-q', 'source.txt')
            git('commit', '-qm', 'local deletion')
            git('switch', '-q', 'remote')
            (local / 'source.txt').write_text('remote change\n')
            git('commit', '-qam', 'remote change')
            remote_head = git('rev-parse', 'HEAD')
            git('switch', '-q', 'main')
            script = r'''
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
runuser() { shift 3; "$@"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_merge_sources "$2" "$3" Fixture fixture@example.test
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(local), remote_head],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertFalse((local / 'source.txt').exists())
            self.assertEqual(git('status', '--porcelain'), '')

    def test_replay_aligns_unrelated_branch_without_changing_local_head(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-merge-test-') as tmp:
            base = Path(tmp)
            local, other, bare = base / 'local', base / 'other', base / 'remote.git'
            local.mkdir()
            other.mkdir()

            def git(path, *args):
                return subprocess.run(['git', '-C', str(path), *args], check=True,
                                      capture_output=True, text=True).stdout.strip()

            subprocess.run(['git', 'init', '-q', '--bare', str(bare)], check=True)
            for directory in (local, other):
                git(directory, 'init', '-q', '-b', 'main')
                git(directory, 'config', 'user.name', 'Fixture')
                git(directory, 'config', 'user.email', 'fixture@example.test')
            (local / 'source.txt').write_text('local\n')
            git(local, 'add', '.')
            git(local, 'commit', '-qm', 'local')
            git(local, 'tag', 'v1.0.0')
            original = git(local, 'rev-parse', 'HEAD')
            (other / 'source.txt').write_text('remote\n')
            (other / 'extra.txt').write_text('remote addition\n')
            git(other, 'add', '.')
            git(other, 'commit', '-qm', 'remote')
            remote_head = git(other, 'rev-parse', 'HEAD')
            git(other, 'push', '-q', str(bare), 'main')
            git(local, 'remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')
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
  local path="$2" operation="$3"; shift 3
  case "$operation" in
    ls-remote) shift; git -C "$path" ls-remote "$BARE" "$@" ;;
    fetch) shift 2; git -C "$path" fetch --no-tags "$BARE" "$@" ;;
    push) shift; git -C "$path" push "$BARE" "$@" ;;
  esac
}
projects_cicd_replay_git_provider forgejo "$2" origin main v1.0.0
'''
            import os
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(local)],
                                    text=True, capture_output=True,
                                    env={**os.environ, 'BARE': str(bare), 'TMPDIR': tmp})
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(git(local, 'rev-parse', 'HEAD'), original)
            self.assertEqual(git(bare, 'show', 'main:source.txt'), 'local')
            self.assertEqual(git(bare, 'rev-parse', 'refs/heads/main'), original)
            self.assertEqual(git(bare, 'rev-parse', 'refs/tags/v1.0.0'), original)
            self.assertEqual(git(bare, 'ls-tree', '-r', '--name-only', 'main'), 'source.txt')

    def test_unrelated_histories_keep_local_conflict_and_remote_addition(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-merge-test-') as tmp:
            local, remote = Path(tmp) / 'local', Path(tmp) / 'remote'
            local.mkdir()
            remote.mkdir()

            def git(path, *args):
                return subprocess.run(['git', '-C', str(path), *args], check=True,
                                      capture_output=True, text=True).stdout.strip()

            for directory in (local, remote):
                git(directory, 'init', '-q', '-b', 'main')
                git(directory, 'config', 'user.name', 'Fixture')
                git(directory, 'config', 'user.email', 'fixture@example.test')
            (local / 'source.txt').write_text('local\n')
            git(local, 'add', '.')
            git(local, 'commit', '-qm', 'local')
            local_head = git(local, 'rev-parse', 'HEAD')
            (remote / 'source.txt').write_text('remote\n')
            (remote / 'extra.txt').write_text('remote addition\n')
            git(remote, 'add', '.')
            git(remote, 'commit', '-qm', 'remote')
            remote_head = git(remote, 'rev-parse', 'HEAD')
            git(local, 'fetch', '-q', str(remote), 'main')
            script = r'''
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
runuser() { shift 3; "$@"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_merge_sources "$2" "$3" Fixture fixture@example.test
'''
            result = subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(local), remote_head],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((local / 'source.txt').read_text(), 'local\n')
            self.assertEqual((local / 'extra.txt').read_text(), 'remote addition\n')
            parents = git(local, 'show', '-s', '--format=%P', 'HEAD').split()
            self.assertEqual(parents, [local_head, remote_head])


if __name__ == '__main__':
    unittest.main()
