"""Reprise Forgejo sur dépôt et transport fictifs."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HEAD = 'a' * 40

HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/diu-packaging.sh"
source "$1/modules/projects/diu-release.sh"
ENV_DEVOPS_PROJECTS_ROOT="$2"; ENV_DEVOPS_USER=fixture
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { :; }
print_title() { :; }
check_devops_user() { return 0; }
forgejo_credentials_prepare() { :; }
_forgejo_read_username() { forgejo_username=fixture; }
_forgejo_read_token() { forgejo_token=fixture; }
forgejo_git_fetch() { :; }
forgejo_git_fetch_named() { :; }
runuser() {
    shift 3
    if [[ "${1:-}" == env ]]; then shift 3; fi
    case "$*" in
      *'git --version'*) printf 'git fixture\n' ;;
      *'rev-parse --is-inside-work-tree'*) printf 'true\n' ;;
      *'remote get-url'*) printf 'https://forge.example/owner/project.git\n' ;;
      *'rev-parse --verify refs/tags/'*) printf '%s\n' "$HEAD_SHA" ;;
      *'rev-parse --verify origin/main'*) printf '%s\n' "$REMOTE_SHA" ;;
      *'rev-parse origin/main'*) printf '%s\n' "$REMOTE_SHA" ;;
      *'rev-parse HEAD'|*'rev-parse --verify HEAD'*) printf '%s\n' "$HEAD_SHA" ;;
      *'merge-base --is-ancestor'*) [[ "$ANCESTOR" == yes ]] ;;
      *'branch --show-current'*) printf 'main\n' ;;
      *'log -1 --format=%s'*) printf 'fixture\n' ;;
      *'tag --points-at HEAD'*) printf 'v1.0.3\n' ;;
      *) printf 'Git operation unexpected: %s\n' "$*" >&2; return 92 ;;
    esac
}
curl() {
    case "$*" in
      *'/releases/tags/v1.0.3'*)
        if [[ "$MODE" == complete ]]; then
          printf '{"id":22,"tag_name":"v1.0.3","assets":[{"name":"project_1.0.3_all.deb"}]}\n200'
        else printf '{"id":22,"tag_name":"v1.0.3","assets":[]}\n200'; fi ;;
      *'/tags/v1.0.3'*) printf '{"commit":{"sha":"%s"}}\n200' "${TAG_SHA:-$HEAD_SHA}" ;;
      *'/releases/22/assets'*) printf 'UPLOAD\n' >> "$CALLS"; printf '{}\n201' ;;
      *) return 91 ;;
    esac
}
publish_release_debian project
'''


class ForgejoDebianIdempotenceTests(unittest.TestCase):
    def run_release(self, mode, tag_sha=HEAD, remote_sha=HEAD, replay=False, ancestor=True):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.forgejo-release-fixture-') as directory:
            base = Path(directory)
            project = base / 'project'
            (project / 'dist').mkdir(parents=True)
            (project / 'project.env').write_text(
                'PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_VERSION=1.0.3\n'
                'LOCAL_DEFAULT_BRANCH=main\nREMOTE_FORGEJO_BASE_URL=https://forge.example\n'
                'REMOTE_FORGEJO_OWNER=owner\nREMOTE_FORGEJO_REPOSITORY=project\n'
                'REMOTE_FORGEJO_NAME=origin\nREMOTE_FORGEJO_BRANCH=main\n')
            staging = base / 'staging/DEBIAN'
            staging.mkdir(parents=True)
            staging.chmod(0o755)
            (staging / 'control').write_text('Package: project\nVersion: 1.0.3\nArchitecture: all\n'
                                             'Maintainer: Fixture <fixture@example.test>\nDescription: fixture\n')
            subprocess.run(['dpkg-deb', '--build', '--root-owner-group', str(staging.parent),
                            str(project / 'dist/project_1.0.3_all.deb')], check=True, capture_output=True)
            calls = base / 'calls'
            result = subprocess.run(['bash', '-c', HARNESS, 'fixture', str(ROOT), str(base)],
                                    text=True, capture_output=True, env={**os.environ, 'TMPDIR': str(base),
                                    'HEAD_SHA': HEAD, 'TAG_SHA': tag_sha, 'MODE': mode, 'CALLS': str(calls),
                                    'REMOTE_SHA': remote_sha, 'PROJECTS_CICD_REPLAY': '1' if replay else '0',
                                    'ANCESTOR': 'yes' if ancestor else 'no'})
            return result, calls.read_text() if calls.exists() else ''

    def test_existing_asset_does_not_upload(self):
        result, calls = self.run_release('complete')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('déjà publié', result.stdout)
        self.assertEqual(calls, '')
        lines = [line for line in result.stdout.splitlines() if ' : ' in line]
        labels = ('Projet', 'ID projet', 'Répertoire', 'Type distant', 'Dépôt distant', 'URL distante', 'Branche locale', 'Branche distante')
        selected = [line for line in lines if line.split(' : ', 1)[0].strip() in labels]
        self.assertEqual(len(selected), len(labels))
        self.assertEqual({line.index(' : ') for line in selected}, {16})

    def test_missing_asset_is_uploaded_to_existing_release(self):
        result, calls = self.run_release('incomplete')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, 'UPLOAD\n')

    def test_remote_tag_mismatch_never_uploads(self):
        result, calls = self.run_release('complete', 'b' * 40)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, '')

    def test_replay_allows_ancestor_but_rejects_divergence(self):
        result, calls = self.run_release('complete', remote_sha='c' * 40, replay=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Répertoire isolé :', result.stdout)
        self.assertEqual(calls, '')
        result, calls = self.run_release('complete', remote_sha='c' * 40, replay=True, ancestor=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, '')
