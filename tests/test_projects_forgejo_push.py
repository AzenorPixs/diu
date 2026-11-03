"""Régressions Forgejo avec Git réel, sans réseau ni credentials réels."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_URL = 'https://forgejo.example.test/owner/project.git'
OLD_URL = 'https://forgejo.example.test/owner/template.git'

HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
DEVOPS_USER=fixture
ENV_DEVOPS_USER=fixture
DEVOPS_GROUP=fixture
DEVOPS_PROJECTS_ROOT="$2"
print_title() { :; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf 'SUCCESS:%s\n' "$*"; }
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
check_devops_user() { return 0; }
runuser() {
    shift 2
    shift
    if [[ "$*" == *'config --local --replace-all'* ]]; then
        printf '%s\n' "$*" >> "$WRITE_LOG"
        if [[ -n "${FAIL_WRITE:-}" && "$*" == *"${FAIL_WRITE}"* ]]; then
            return 72
        fi
    fi
    if [[ "${FAIL_READ:-}" == push && "$*" == *'remote get-url --push --all'* ]]; then
        return 73
    fi
    "$@"
}
_forgejo_ensure_credentials() { return 0; }
forgejo_repository_ensure() {
    if [[ "${MODE}" == concurrent ]]; then
        git -C "$TEST_REMOTE" update-ref "refs/heads/$TEST_BRANCH" "$BASE_COMMIT" || return 1
    fi
    [[ "${MODE}" == existing ]] && return 0
    return 2
}
forgejo_git_fetch_named() {
    printf 'FETCH\n'
    if [[ "${FAIL_FETCH:-}" == yes ]]; then
        return 74
    fi
    git -c "url.${TEST_REMOTE}.insteadOf=$EXPECTED_URL" -C "$1" fetch "$2"
}
forgejo_git_push_named() {
    local project_path="$1"
    shift 2
    printf 'PUSH:%s\n' "$*"
    git -c "url.${TEST_REMOTE}.insteadOf=$EXPECTED_URL" -C "$project_path" push "$@"
}
if [[ "$3" == helper ]]; then
    forgejo_remote_ensure "$2/project" "$TEST_REMOTE_NAME" "$EXPECTED_URL"
else
    forgejo_push project
fi
'''


class ForgejoPushTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.forgejo-test-')
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.project = self.base / 'project'
        self.remote = self.base / 'remote with spaces.git'
        self.env = dict(os.environ)
        for key in tuple(self.env):
            if key.startswith('GIT_'):
                self.env.pop(key)
        self.env.update({
            'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_NOSYSTEM': '1',
            'GIT_ALLOW_PROTOCOL': 'file', 'GIT_TERMINAL_PROMPT': '0',
            'GIT_AUTHOR_NAME': 'Fixture', 'GIT_AUTHOR_EMAIL': 'fixture@example.test',
            'GIT_COMMITTER_NAME': 'Fixture', 'GIT_COMMITTER_EMAIL': 'fixture@example.test',
            'TMPDIR': str(self.base), 'TEST_REMOTE': str(self.remote),
            'EXPECTED_URL': EXPECTED_URL, 'TEST_REMOTE_NAME': 'origin',
            'TEST_BRANCH': 'main', 'MODE': 'absent',
            'WRITE_LOG': str(self.base / 'writes'),
        })
        self.git(self.base, 'init', '--initial-branch=main', str(self.project))
        self.git(self.base, 'init', '--bare', '--initial-branch=main', str(self.remote))
        self.git(self.project, '-c', 'commit.gpgsign=false', 'commit', '--allow-empty', '-m', 'base')
        self.base_commit = self.git(self.project, 'rev-parse', 'HEAD').stdout.strip()
        self.env['BASE_COMMIT'] = self.base_commit
        self.git(self.project, 'push', str(self.remote), 'HEAD:refs/seed/base')
        self.git(self.project, '-c', 'commit.gpgsign=false', 'commit', '--allow-empty', '-m', 'local')
        self.head = self.git(self.project, 'rev-parse', 'HEAD').stdout.strip()
        self.git(self.project, 'tag', 'v1.2.3')
        self.git(self.project, 'remote', 'add', 'origin', OLD_URL)
        self.git(self.project, 'update-ref', 'refs/remotes/origin/main', self.base_commit)
        self.git(self.project, 'config', 'branch.main.remote', 'origin')
        self.git(self.project, 'config', 'branch.main.merge', 'refs/heads/main')
        self.git(self.project, 'remote', 'add', 'gitlab', 'https://gitlab.example.test/owner/project.git')
        self.other_remote = self.git(self.project, 'remote', 'get-url', 'gitlab').stdout
        self.project_env = (
            'PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_TYPE=application\n'
            'PROJECT_DOCKERED=No\n'
            'REMOTE_FORGEJO_BASE_URL=https://forgejo.example.test\n'
            'REMOTE_FORGEJO_OWNER=owner\nREMOTE_FORGEJO_REPOSITORY=project\n'
            'REMOTE_FORGEJO_NAME=origin\nREMOTE_FORGEJO_BRANCH=main\n'
            'REMOTE_FORGEJO_SSL_VERIFY=Yes\n'
        )
        (self.project / 'project.env').write_text(self.project_env, encoding='utf-8')

    def git(self, directory, *arguments, check=True):
        result = subprocess.run(
            ['git', '-C', str(directory), *arguments], env=self.env,
            text=True, capture_output=True, check=False,
        )
        if check:
            self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def run_harness(self, action='helper', **environment):
        return subprocess.run(
            ['bash', '-c', HARNESS, 'bash', str(ROOT), str(self.base), action],
            env=dict(self.env, **environment), text=True, capture_output=True, check=False,
        )

    def assert_urls_aligned(self, name='origin'):
        for options in (('--all',), ('--push', '--all')):
            self.assertEqual(
                self.git(self.project, 'remote', 'get-url', *options, name).stdout,
                EXPECTED_URL + '\n',
            )
        self.assertEqual(self.git(self.project, 'remote', 'get-url', 'gitlab').stdout, self.other_remote)
        self.assertEqual((self.project / 'project.env').read_text(encoding='utf-8'), self.project_env)
        self.assertEqual(self.git(self.project, 'rev-parse', 'HEAD').stdout.strip(), self.head)
        self.assertEqual(self.git(self.project, 'rev-parse', 'refs/tags/v1.2.3').stdout.strip(), self.head)

    def test_realigns_inherited_url_without_adding_pushurl(self):
        result = self.run_harness()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('réaligné', result.stdout)
        self.assertNotIn(OLD_URL, result.stdout + result.stderr)
        self.assert_urls_aligned()
        self.assertEqual(self.git(self.project, 'config', '--get-all', 'remote.origin.pushurl', check=False).returncode, 1)

    def test_realigns_distinct_pushurl(self):
        self.git(self.project, 'remote', 'set-url', 'origin', EXPECTED_URL)
        self.git(self.project, 'remote', 'set-url', '--push', 'origin', OLD_URL)
        result = self.run_harness()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_urls_aligned()

    def test_normalizes_multiple_fetch_and_push_urls(self):
        self.git(self.project, 'remote', 'set-url', '--add', 'origin', EXPECTED_URL)
        self.git(self.project, 'remote', 'set-url', '--add', '--push', 'origin', OLD_URL)
        self.git(self.project, 'remote', 'set-url', '--add', '--push', 'origin', EXPECTED_URL)
        result = self.run_harness()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_urls_aligned()

    def test_adds_absent_remote(self):
        result = self.run_harness(TEST_REMOTE_NAME='forgejo')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('ajouté', result.stdout)
        self.assert_urls_aligned('forgejo')
        self.assertEqual(self.git(self.project, 'remote', 'get-url', 'origin').stdout.strip(), OLD_URL)

    def test_reexecution_does_not_rewrite_aligned_urls(self):
        first = self.run_harness()
        self.assertEqual(first.returncode, 0, first.stderr)
        writes = Path(self.env['WRITE_LOG']).read_bytes()
        second = self.run_harness()
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(Path(self.env['WRITE_LOG']).read_bytes(), writes)
        self.assertNotIn('réalign', second.stdout)
        self.assert_urls_aligned()

    def test_fetch_url_write_failure_stops_push(self):
        result = self.run_harness('push', FAIL_WRITE='remote.origin.url')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de réaligner', result.stderr)
        self.assertNotIn('PUSH:', result.stdout)
        self.assertNotIn('réaligné', result.stdout)
        self.assertEqual(self.git(self.project, 'remote', 'get-url', 'origin').stdout.strip(), OLD_URL)

    def test_pushurl_write_failure_can_be_resumed(self):
        self.git(self.project, 'remote', 'set-url', '--push', 'origin', OLD_URL)
        result = self.run_harness('push', FAIL_WRITE='remote.origin.pushurl')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('PUSH:', result.stdout)
        self.assertNotIn('réaligné', result.stdout)
        resumed = self.run_harness()
        self.assertEqual(resumed.returncode, 0, resumed.stderr)
        self.assert_urls_aligned()

    def test_pushurl_read_failure_stops_push(self):
        result = self.run_harness('push', FAIL_READ='push')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Impossible de lire l'URL", result.stderr)
        self.assertNotIn('PUSH:', result.stdout)
        self.assertNotIn('réaligné', result.stdout)

    def test_url_rewrite_mismatch_stops_push(self):
        self.git(self.project, 'config', 'url.https://other.example.test/.insteadOf', 'https://forgejo.example.test/')
        result = self.run_harness('push')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('URL effectives', result.stderr)
        self.assertNotIn('PUSH:', result.stdout)
        self.assertNotIn('réaligné', result.stdout)

    def test_first_push_with_inherited_tracking_publishes_branch_and_tag(self):
        result = self.run_harness('push')
        self.assertEqual(result.returncode, 0, result.stderr)
        labels = ('Projet', 'ID projet', 'Répertoire', 'Utilisateur', 'Type distant', 'Branche locale', 'Dépôt distant', 'URL distante', 'Branche distante', 'Tag du commit')
        lines = [line for line in result.stdout.splitlines() if ' : ' in line and line.split(' : ', 1)[0].strip() in labels]
        self.assertGreaterEqual(len(lines), len(labels))
        self.assertEqual({line.index(' : ') for line in lines[:len(labels)]}, {16})
        self.assertIn('--force-with-lease=refs/heads/main:', result.stdout)
        self.assertNotIn('FETCH', result.stdout)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main').stdout.strip(), self.head)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/tags/v1.2.3').stdout.strip(), self.head)
        tag_push = [line for line in result.stdout.splitlines() if line.startswith('PUSH:') and 'refs/tags/' in line]
        self.assertEqual(len(tag_push), 1)
        self.assertNotIn('--force', tag_push[0])
        self.assert_urls_aligned()

    def test_concurrent_branch_creation_is_rejected_without_publishing_tag(self):
        result = self.run_harness('push', MODE='concurrent')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('stale info', result.stderr)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main').stdout.strip(), self.base_commit)
        self.assertNotEqual(self.git(self.remote, 'show-ref', '--verify', 'refs/tags/v1.2.3', check=False).returncode, 0)
        self.assertEqual(self.git(self.project, 'rev-parse', 'refs/remotes/origin/main').stdout.strip(), self.base_commit)
        self.assertNotIn('PUSH:origin refs/tags/', result.stdout)

    def test_existing_repository_keeps_fetch_and_implicit_lease(self):
        self.git(self.project, 'push', str(self.remote), f'{self.base_commit}:refs/heads/main')
        result = self.run_harness('push', MODE='existing')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(result.stdout.index('FETCH'), result.stdout.index('PUSH:'))
        self.assertIn('--force-with-lease --set-upstream', result.stdout)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/main').stdout.strip(), self.head)

    def test_existing_repository_fetch_failure_stops_push(self):
        result = self.run_harness('push', MODE='existing', FAIL_FETCH='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('FETCH', result.stdout)
        self.assertNotIn('PUSH:', result.stdout)

    def test_first_push_uses_configured_remote_and_destination_branch(self):
        self.git(self.project, 'remote', 'rename', 'origin', 'forgejo')
        self.project_env = self.project_env.replace('NAME=origin', 'NAME=forgejo').replace('BRANCH=main', 'BRANCH=stable')
        (self.project / 'project.env').write_text(self.project_env, encoding='utf-8')
        result = self.run_harness('push', TEST_REMOTE_NAME='forgejo', TEST_BRANCH='stable')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('--force-with-lease=refs/heads/stable: --set-upstream forgejo main:stable', result.stdout)
        self.assertEqual(self.git(self.remote, 'rev-parse', 'refs/heads/stable').stdout.strip(), self.head)
        self.assert_urls_aligned('forgejo')


if __name__ == '__main__':
    unittest.main()
