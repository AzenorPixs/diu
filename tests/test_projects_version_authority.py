"""Protection des versions et alignement des trois forges sur dépôts isolés."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class VersionAuthorityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.version-authority-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.local, self.remote = self.base / 'local', self.base / 'remote.git'
        self.local.mkdir()
        subprocess.run(['git', 'init', '-q', '--bare', str(self.remote)], check=True)
        self.git(self.local, 'init', '-q', '-b', 'main')
        self.git(self.local, 'config', 'user.name', 'Fixture')
        self.git(self.local, 'config', 'user.email', 'fixture@example.test')
        (self.local / 'file').write_text('old\n')
        self.git(self.local, 'add', '.')
        self.git(self.local, 'commit', '-qm', 'old')
        self.old = self.git(self.local, 'rev-parse', 'HEAD')
        (self.local / 'file').write_text('selected\n')
        self.git(self.local, 'commit', '-qam', 'selected')
        self.selected = self.git(self.local, 'rev-parse', 'HEAD')
        self.git(self.local, 'tag', 'v1.2.0')
        (self.local / 'remote-only').write_text('remove\n')
        self.git(self.local, 'add', '.')
        self.git(self.local, 'commit', '-qm', 'remote-only')
        self.ahead = self.git(self.local, 'rev-parse', 'HEAD')
        self.git(self.local, 'push', str(self.remote), 'main')
        self.git(self.local, 'reset', '--hard', self.selected)
        self.git(self.local, 'remote', 'add', 'origin', 'https://forge.example/owner/fixture.git')

    @staticmethod
    def git(path, *args):
        return subprocess.run(['git', '-C', str(path), *args], check=True, capture_output=True, text=True).stdout.strip()

    def run_push(self, provider, tag='v1.2.0', concurrent=False):
        script = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
ENV_DEVOPS_USER=fixture
for provider in FORGEJO GITLAB GITHUB; do
    printf -v "REMOTE_${provider}_BASE_URL" '%s' 'https://forge.example'
    printf -v "REMOTE_${provider}_OWNER" '%s' owner
    printf -v "REMOTE_${provider}_REPOSITORY" '%s' fixture
done
runuser() { shift 3; "$@"; }
print_info() { :; }
print_error() { printf '%s\n' "$*" >&2; }
projects_cicd_replay_git_transport() {
  local path="$2" operation="$3"; shift 3
  case "$operation" in
    ls-remote) shift; git -C "$path" ls-remote "$BARE" "$@" ;;
    fetch) shift 2; git -C "$path" fetch --no-tags "$BARE" "$@" ;;
    push) shift
      if [[ "$CONCURRENT" == 1 && "$*" == *'refs/heads/main'* ]]; then
        git -C "$BARE" update-ref refs/heads/main "$OLD"
      fi
      git -C "$path" push "$BARE" "$@" ;;
  esac
}
projects_cicd_replay_git_provider "$3" "$2" origin main "$4"
'''
        return subprocess.run(['bash', '-c', script, 'fixture', str(ROOT), str(self.local), provider, tag],
                              env={**os.environ, 'BARE': str(self.remote), 'OLD': self.old,
                                   'CONCURRENT': str(int(concurrent)), 'TMPDIR': str(self.base)},
                              text=True, capture_output=True)

    def test_equal_tag_aligns_branch_and_replaces_divergent_tag_for_all_providers(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                self.git(self.remote, 'update-ref', 'refs/heads/main', self.ahead)
                self.git(self.remote, 'update-ref', 'refs/tags/v1.2.0', self.old)
                result = self.run_push(provider)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.selected)
                self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v1.2.0'), self.selected)
                self.assertEqual(self.git(self.remote, 'ls-tree', '-r', '--name-only', 'main'), 'file')

    def test_higher_version_stops_before_any_write(self):
        self.git(self.remote, 'update-ref', 'refs/tags/v1.10.0', self.old)
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                result = self.run_push(provider)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('supérieur', result.stderr)
                self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.ahead)
                self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v1.10.0'), self.old)

    def test_timestamp_yields_to_stable_and_unknown_tags_stop(self):
        self.git(self.local, 'tag', 'v2026.11.10.12.34')
        self.git(self.remote, 'update-ref', 'refs/tags/v1.0.0', self.old)
        result = self.run_push('github', 'v2026.11.10.12.34')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('supérieur', result.stderr)
        self.git(self.remote, 'update-ref', '-d', 'refs/tags/v1.0.0')
        self.git(self.remote, 'update-ref', 'refs/tags/custom', self.old)
        result = self.run_push('github')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('non comparable', result.stderr)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.ahead)

    def test_lower_tags_are_preserved_and_stable_beats_timestamp(self):
        self.git(self.remote, 'update-ref', 'refs/tags/v1.1.9', self.old)
        self.git(self.remote, 'update-ref', 'refs/tags/v2026.11.10.12.34', self.old)
        result = self.run_push('gitlab')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.selected)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v1.1.9'), self.old)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v2026.11.10.12.34'), self.old)

    def test_annotated_remote_tag_is_compared_without_treating_peeled_ref_as_tag(self):
        self.git(self.local, 'tag', '-a', 'v1.1.0', self.old, '-m', 'fixture')
        self.git(self.local, 'push', str(self.remote), 'refs/tags/v1.1.0')
        result = self.run_push('github')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.selected)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v1.1.0^{commit}'), self.old)

    def test_branch_lease_rejects_concurrent_change(self):
        result = self.run_push('forgejo', concurrent=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main'), self.old)
        self.assertNotEqual(subprocess.run(['git', '-C', str(self.remote), 'show-ref', '--verify', '--quiet',
                                            'refs/tags/v1.2.0']).returncode, 0)


if __name__ == '__main__':
    unittest.main()
