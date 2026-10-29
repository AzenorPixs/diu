"""Bootstrap Forgejo sur identifiants fictifs, sans réseau."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
set -Eeuo pipefail
source "$1/lib/forgejo-auth.sh"
source "$1/modules/projects/git.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { :; }
print_success() { :; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
_forgejo_resolve_remote() {
    forgejo_host=forge.example.test
    forgejo_base=https://forge.example.test
    forgejo_owner=owner
    forgejo_repo=project
}
_forgejo_curl() {
    [[ "$*" != *fixture-manual-token* && "$*" != *fixture-generated-token* &&
        "$*" != *fixture-password* ]] || return 90
    printf 'request\n' >> "$CALLS"
    case "$*" in
        *'/tokens'*)
            if [[ "${INVALID_JSON:-}" == yes ]]; then
                printf 'invalid\n201'
            else
                printf '{"sha1":"fixture-generated-token"}\n%s' "${CREATE_CODE:-201}"
            fi
            ;;
        *'/api/v1/user'*) printf '%s' "${AUTH_CODE:-200}" ;;
        *) printf '%s' "${REMOTE_CODE:-200}" ;;
    esac
}
if [[ "${FAIL_PUBLISH:-}" == yes ]]; then
    ln() {
        [[ "$*" != *forgejo.token* ]] || return 72
        command ln "$@"
    }
fi
"$3" "$2" origin
'''

class ForgejoBootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.credential-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.project = self.base / 'project with spaces'
        self.project.mkdir()
        self.calls = self.base / 'calls'
        self.scratch = self.base / 'scratch'
        self.scratch.mkdir()

    def credential(self, name, value, mode=0o600):
        config = self.project / 'config'
        config.mkdir(exist_ok=True)
        p = config / ('forgejo.' + name)
        p.write_text(value)
        p.chmod(mode)
        return p

    def snapshot(self):
        return {str(p.relative_to(self.project)): (p.read_bytes(), p.stat().st_mode & 0o777)
                for p in self.project.rglob('*') if p.is_file()}

    def run_action(self, action='forgejo_credentials_prepare', data='', **settings):
        result = subprocess.run(
            ['bash', '-c', HARNESS, 'fixture', str(ROOT), str(self.project), action],
            input=data, text=True, capture_output=True, check=False,
            env={**os.environ, 'CALLS': str(self.calls), 'TMPDIR': str(self.scratch), **settings})
        for secret in ('fixture-manual-token', 'fixture-generated-token', 'fixture-password'):
            self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(list(self.project.glob('.forgejo-credentials.*')), [])
        self.assertEqual(list(self.scratch.iterdir()), [])
        return result

    def test_provider_without_credentials_never_prompts_or_writes(self):
        before = self.snapshot()
        result = self.run_action('forgejo_git_fetch_named', 'oui\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)
        self.assertFalse(self.calls.exists())

    def test_refusal_and_eof_have_no_effect(self):
        for data in ('non\n', ''):
            with self.subTest(data=data):
                result = self.run_action(data=data)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.snapshot(), {})
                self.assertFalse(self.calls.exists())

    def test_manual_setup_validates_then_publishes_pair(self):
        result = self.run_action(data='oui\nfixture-user\n1\nfixture-manual-token\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.project/'config/forgejo.token').read_text(), 'fixture-manual-token')
        self.assertEqual((self.project/'config').stat().st_mode & 0o7777, 0o700)
        for name in ('username', 'token'):
            self.assertEqual((self.project/f'config/forgejo.{name}').stat().st_mode & 0o777, 0o600)

    def test_existing_shared_pair_is_preserved_without_prompt(self):
        self.credential('username', 'fixture-user', 0o660)
        self.credential('token', 'fixture-manual-token', 0o660)
        before = self.snapshot()
        result = self.run_action()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, self.snapshot())

    def test_refused_existing_pair_is_never_removed(self):
        for code in ('401', '403'):
            self.credential('username', 'fixture-user')
            self.credential('token', 'fixture-manual-token')
            before = self.snapshot()
            result = self.run_action(data='oui\n', REMOTE_CODE=code)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(before, self.snapshot())

    def test_invalid_modes_or_empty_files_are_preserved(self):
        for value, mode in (('', 0o600), ('fixture-manual-token', 0o644)):
            self.credential('username', 'fixture-user')
            self.credential('token', value, mode)
            before = self.snapshot()
            result = self.run_action(data='oui\n')
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(before, self.snapshot())

    def test_partial_username_keeps_content_and_shared_mode(self):
        self.credential('username', 'fixture-user', 0o660)
        result = self.run_action(data='oui\n1\nfixture-manual-token\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        p = self.project/'config/forgejo.username'
        self.assertEqual(p.read_text(), 'fixture-user')
        self.assertEqual(p.stat().st_mode & 0o777, 0o660)

    def test_partial_token_is_not_replaced(self):
        self.credential('token', 'fixture-manual-token', 0o660)
        result = self.run_action(data='oui\nfixture-user\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        p = self.project/'config/forgejo.token'
        self.assertEqual(p.read_text(), 'fixture-manual-token')
        self.assertEqual(p.stat().st_mode & 0o777, 0o660)

    def test_candidate_rejection_preserves_partial_pair(self):
        self.credential('username', 'fixture-user', 0o660)
        before = self.snapshot()
        result = self.run_action(data='oui\n1\nfixture-manual-token\n', REMOTE_CODE='401')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(before, self.snapshot())

    def test_api_setup_requires_consent_and_keeps_secrets_private(self):
        result = self.run_action(data='oui\nfixture-user\n2\nfixture-password\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.project/'config/forgejo.token').read_text(), 'fixture-generated-token')

    def test_api_auth_and_creation_errors_leave_no_pair(self):
        for settings in ({'AUTH_CODE': '401'}, {'CREATE_CODE': '403'}, {'CREATE_CODE': '503'}):
            result = self.run_action(data='oui\nfixture-user\n2\nfixture-password\n', **settings)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(self.snapshot(), {})

    def test_invalid_api_payload_is_not_persisted(self):
        result = self.run_action(data='oui\nfixture-user\n2\nfixture-password\n', INVALID_JSON='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), {})

    def test_second_file_publication_failure_rolls_back_new_pair(self):
        result = self.run_action(data='oui\nfixture-user\n1\nfixture-manual-token\n', FAIL_PUBLISH='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), {})

    def test_eof_during_setup_leaves_partial_pair_intact(self):
        self.credential('username', 'fixture-user', 0o660)
        before = self.snapshot()
        result = self.run_action(data='oui\n1\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(before, self.snapshot())

if __name__ == '__main__':
    unittest.main()

