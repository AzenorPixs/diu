"""Publications Git isolées : indisponibilité et erreurs réelles."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
NETWORK_ERROR = (
    "fatal: unable to access 'https://forge.example.test/owner/project.git/': "
    "Failed to connect to forge.example.test port 443 after 7335 ms: Could not connect to server"
)


def configuration(project_id='project'):
    lines = [f'PROJECT_ID={project_id}', 'PROJECT_NAME=Project',
             'PROJECT_TYPE=docker', 'PROJECT_DOCKERED=Yes']
    for provider in ('FORGEJO', 'GITLAB', 'GITHUB'):
        lines += [f'REMOTE_{provider}_BASE_URL=https://{provider.lower()}.example.test',
                  f'REMOTE_{provider}_OWNER=owner', f'REMOTE_{provider}_REPOSITORY={project_id}',
                  f'REMOTE_{provider}_NAME={provider.lower()}', f'REMOTE_{provider}_BRANCH=main']
    lines += ['REMOTE_FORGEJO_SSL_VERIFY=Yes', 'REMOTE_GITLAB_SSL_VERIFY=Yes',
              'REMOTE_GITLAB_REGISTRY=registry.example.test']
    return '\n'.join(lines) + '\n'


HARNESS = r'''
source "$1/modules/projects/git.sh"
source "$1/lib/forgejo-auth.sh"
source "$1/lib/gitlab-auth.sh"
source "$1/lib/github-auth.sh"
print_title() { :; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf 'SUCCES:%s\n' "$*"; }
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
check_devops_user() { return 0; }
forgejo_remote_ensure() { return 0; }
gitlab_remote_ensure() { return 0; }
github_remote_ensure() { return 0; }
_forgejo_ensure_credentials() { return 0; }
_gitlab_ensure_credentials() { return 0; }
_github_ensure_credentials() { return 0; }
_github_ensure_api_credentials() { github_token=fixture-token; }
_forgejo_prepare_context() {
    forgejo_token=fixture-token
    forgejo_base=https://forgejo.example.test
    forgejo_owner=owner
    forgejo_repo=project
}
_forgejo_read_username() { forgejo_username=fixture-user; }
_forgejo_read_token() { forgejo_token=fixture-token; }
_gitlab_read_username() { gitlab_username=fixture-user; }
_gitlab_read_token() { gitlab_token=fixture-token; }
_github_read_username() { github_username=fixture-user; }
_github_read_token() { github_token=fixture-token; }
runuser() { shift 2; [[ "${1:-}" == -- ]] && shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_USER="$DEVOPS_USER"
DEVOPS_PROJECTS_ROOT="$2/projects"
PATH="$2/bin:$PATH"
export PATH TMPDIR="$2/scratch" GIT_CALLS="$2/git-calls"
"${PUSH_PROVIDER}_push" project
rc=$?
printf 'RESULT:%s:%s\n' "$rc" "$PROJECTS_GIT_PUSH_STATUS"
exit "$rc"
'''


class ProviderUnavailableTests(unittest.TestCase):
    def run_push(self, provider, phase='branch', error=NETWORK_ERROR, code=128,
                 curl_code=0, http_code=200, script=HARNESS):
        with tempfile.TemporaryDirectory(dir=ROOT) as temporary:
            base = Path(temporary)
            project = base / 'projects' / 'project'
            project.mkdir(parents=True)
            original = configuration()
            (project / 'project.env').write_text(original, encoding='utf-8')
            (base / 'bin').mkdir()
            (base / 'scratch').mkdir()
            (base / 'bin' / 'git').write_text(r'''#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GIT_CALLS"
phase=""
case "$*" in
    *'rev-parse --verify'*) exit 1 ;;
    *'branch --show-current'*) printf 'main\n'; exit 0 ;;
    *'tag --points-at HEAD'*) printf 'v1.2.3\n'; exit 0 ;;
    *'remote get-url'*) printf 'https://%s.example.test/owner/project.git\n' "$PUSH_PROVIDER"; exit 0 ;;
    *' fetch '*) phase=fetch ;;
    *' push '*) phase=branch; [[ "$*" == *refs/tags/* ]] && phase=tag ;;
esac
if [[ -n "$phase" && "$phase" == "$FAIL_PHASE" ]]; then
    printf '%s\n' "$GIT_FAILURE" >&2
    exit "$GIT_FAILURE_CODE"
fi
exit 0
''', encoding='utf-8')
            (base / 'bin' / 'curl').write_text(r'''#!/usr/bin/env bash
request="$*"
if [[ "${BOOTSTRAP_PHASE:-}" == token && "$request" != *'/tokens'* ]]; then
    HTTP_CODE=200
fi
output=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in --output|-o) output="$2"; shift ;; esac
    shift
done
if [[ "$FAIL_PHASE" == api ]]; then
    if [[ "$CURL_CODE" != 0 ]]; then
        printf 'curl: (%s) simulated network or TLS failure\n' "$CURL_CODE" >&2
        exit "$CURL_CODE"
    fi
    printf '%s' "$HTTP_CODE"
else
    printf '200'
fi
[[ -n "$output" && "$output" != /dev/null ]] && printf '{}' > "$output"
exit 0
''', encoding='utf-8')
            for executable in ('git', 'curl'):
                (base / 'bin' / executable).chmod(0o755)
            environment = dict(os.environ, PUSH_PROVIDER=provider, FAIL_PHASE=phase,
                               GIT_FAILURE=error, GIT_FAILURE_CODE=str(code),
                               CURL_CODE=str(curl_code), HTTP_CODE=str(http_code))
            result = subprocess.run(['bash', '-c', script, 'bash', str(ROOT), str(base)],
                                    text=True, capture_output=True, env=environment, check=False)
            calls = (base / 'git-calls').read_text() if (base / 'git-calls').exists() else ''
            self.assertEqual((project / 'project.env').read_text(), original)
            self.assertEqual(list((base / 'scratch').iterdir()), [], result.stderr)
            self.assertNotIn('fixture-token', result.stdout + result.stderr)
            return result, calls

    def assert_unavailable(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('RESULT:0:indisponible', result.stdout)
        self.assertIn('publication non confirmée', result.stdout)
        self.assertNotIn('Push Git terminé avec succès', result.stdout)
        self.assertEqual(result.stderr, '')

    def test_connection_failure_on_branch_for_each_provider(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                result, calls = self.run_push(provider)
                self.assert_unavailable(result)
                self.assertNotIn('refs/tags/', calls)

    def test_connection_failure_on_tag_keeps_branch_publication_visible(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                result, calls = self.run_push(provider, phase='tag')
                self.assert_unavailable(result)
                self.assertIn('main:main', calls)
                self.assertIn('refs/tags/v1.2.3:refs/tags/v1.2.3', calls)

    def test_fetch_failure_does_not_push(self):
        for provider in ('forgejo', 'github'):
            with self.subTest(provider=provider):
                result, calls = self.run_push(provider, phase='fetch')
                self.assert_unavailable(result)
                self.assertNotIn(' push ', calls)

    def test_git_dns_timeout_and_gateway_errors_are_unavailable(self):
        reasons = ('Could not resolve host: forge.example.test',
                   'Could not resolve proxy: proxy.example.test',
                   'Operation timed out after 30000 milliseconds with 0 bytes received',
                   'Connection timed out after 30000 milliseconds',
                   'Resolving timed out after 30000 milliseconds',
                   'Operation too slow. Less than 1 bytes/sec transferred the last 30 seconds',
                   'The requested URL returned error: 502',
                   'The requested URL returned error: 503',
                   'The requested URL returned error: 504')
        for reason in reasons:
            with self.subTest(reason=reason):
                error = "fatal: unable to access 'https://forge.example.test/repo.git/': " + reason
                result, _ = self.run_push('gitlab', error=error)
                self.assert_unavailable(result)

    def test_api_network_failures_are_unavailable(self):
        for provider in ('forgejo', 'github'):
            for code in (5, 6, 7, 28):
                with self.subTest(provider=provider, code=code):
                    result, calls = self.run_push(provider, phase='api', curl_code=code)
                    self.assert_unavailable(result)
                    self.assertNotIn(' push ', calls)

    def test_api_gateway_failures_are_unavailable(self):
        for provider in ('forgejo', 'github'):
            for code in (502, 503, 504):
                with self.subTest(provider=provider, code=code):
                    result, calls = self.run_push(provider, phase='api', http_code=code)
                    self.assert_unavailable(result)
                    self.assertNotIn(' push ', calls)

    def test_git_auth_tls_rejection_and_generic_128_remain_errors(self):
        failures = (('fatal: Authentication failed', 128),
                    ("fatal: unable to access 'https://forge.example.test/repo.git/': SSL certificate problem", 128),
                    ('remote: ' + NETWORK_ERROR, 128),
                    ('fatal: unknown failure', 128),
                    ('[remote rejected] main -> main (protected branch)', 1))
        for provider in ('forgejo', 'gitlab', 'github'):
            for error, code in failures:
                with self.subTest(provider=provider, error=error):
                    result, _ = self.run_push(provider, error=error, code=code)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn('RESULT:', result.stdout)
                    self.assertNotIn('RESULT:0:indisponible', result.stdout)
                    self.assertIn(error, result.stderr)

    def test_api_auth_tls_and_unclassified_failures_remain_errors(self):
        for provider in ('forgejo', 'github'):
            for curl_code, http_code in ((0, 401), (0, 403), (60, 200), (35, 200), (0, 500)):
                with self.subTest(provider=provider, curl_code=curl_code, http_code=http_code):
                    result, _ = self.run_push(provider, phase='api', curl_code=curl_code, http_code=http_code)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertNotIn('RESULT:0:indisponible', result.stdout)
                    self.assertTrue(result.stderr)

    def test_success_after_unavailability_does_not_reuse_status(self):
        script = HARNESS.replace('exit "$rc"', r'''
FAIL_PHASE=none
export FAIL_PHASE
"${PUSH_PROVIDER}_push" project
printf 'SECOND:%s:%s\n' "$?" "$PROJECTS_GIT_PUSH_STATUS"
''')
        result, _ = self.run_push('gitlab', script=script)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('RESULT:0:indisponible', result.stdout)
        self.assertIn('SECOND:0:publié', result.stdout)

    def test_git_outside_push_context_retains_code_and_error(self):
        script = HARNESS[:HARNESS.index('"${PUSH_PROVIDER}_push" project')] + r'''
printf 'diagnostic précédent\n' >&2
git_with_token "$DEVOPS_PROJECTS_ROOT/project" fixture-user fixture-token push gitlab main:main
'''
        result, _ = self.run_push('gitlab', script=script)
        self.assertEqual(result.returncode, 128)
        self.assertIn(NETWORK_ERROR, result.stderr)
        self.assertIn('diagnostic précédent', result.stderr)

    def test_successful_pushes_still_publish_branch_and_tag(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                result, calls = self.run_push(provider, phase='none')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('RESULT:0:publié', result.stdout)
                self.assertIn('Push Git terminé avec succès', result.stdout)
                self.assertIn('main:main', calls)
                self.assertIn('refs/tags/v1.2.3', calls)

    def test_local_project_errors_are_not_unavailability(self):
        for provider in ('forgejo', 'gitlab', 'github'):
            with self.subTest(provider=provider):
                script = HARNESS.replace('"${PUSH_PROVIDER}_push" project',
                                         '"${PUSH_PROVIDER}_push" missing')
                result, _ = self.run_push(provider, script=script)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Projet introuvable', result.stderr)
                self.assertNotIn('RESULT:0:indisponible', result.stdout)

    def test_forgejo_credential_check_network_failure_is_not_invalid_token(self):
        script = HARNESS.replace('_forgejo_ensure_credentials() { return 0; }',
                                 '_forgejo_ensure_credentials() { _forgejo_validate_credentials "$@"; }')
        for curl_code, http_code in ((7, 200), (0, 503)):
            with self.subTest(curl_code=curl_code, http_code=http_code):
                result, calls = self.run_push('forgejo', phase='api', curl_code=curl_code,
                                              http_code=http_code, script=script)
                self.assert_unavailable(result)
                self.assertNotIn(' push ', calls)

    def test_forgejo_bootstrap_gateway_failures_clean_up_and_do_not_push(self):
        for phase in ('auth', 'token'):
            with self.subTest(phase=phase):
                script = HARNESS.replace('_forgejo_ensure_credentials() { return 0; }', '')
                script = script.replace('"${PUSH_PROVIDER}_push" project',
                                        f'export BOOTSTRAP_PHASE={phase}\n'
                                        '"${PUSH_PROVIDER}_push" project <<< $\'oui\\nfixture-user\\n2\\nfixture-password\\n\'')
                result, calls = self.run_push('forgejo', phase='api', http_code=503, script=script)
                self.assert_unavailable(result)
                self.assertNotIn(' push ', calls)
                self.assertNotIn('fixture-password', result.stdout + result.stderr)

    def test_cicd_continues_and_skips_only_unavailable_provider_releases(self):
        for provider in ('forgejo', 'gitlab', 'github', 'all'):
            with self.subTest(provider=provider):
                result, _ = self.run_push(provider, script=self.cicd_script())
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('État global : terminé avec indisponibilités', result.stdout)
                self.assertIn('BUILD', result.stdout)
                for candidate in ('forgejo', 'gitlab', 'github'):
                    if provider in (candidate, 'all'):
                        self.assertNotIn('RELEASE:' + candidate, result.stdout)
                    else:
                        self.assertIn('RELEASE:' + candidate, result.stdout)
                self.assertEqual(result.stderr, '')

    def test_cicd_real_failure_after_unavailability_still_stops(self):
        script = self.cicd_script().replace('if [[ "$2" == "$PUSH_PROVIDER"',
                                           'if [[ "$2" == github ]]; then print_error rejected; return 1; fi\n    if [[ "$2" == "$PUSH_PROVIDER"')
        result, _ = self.run_push('forgejo', script=script)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('État global : échec', result.stdout)
        self.assertNotIn('BUILD', result.stdout)

    def test_forgejo_group_reports_unavailability_without_false_success(self):
        script = self.cicd_script().replace('cicd_project project commit v1.2.3', 'forgejo_push_all')
        result, _ = self.run_push('forgejo', script=script)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('terminé avec indisponibilités', result.stdout)
        self.assertNotIn('terminé pour tous les projets configurés', result.stdout)

    @staticmethod
    def cicd_script():
        return HARNESS[:HARNESS.index('"${PUSH_PROVIDER}_push" project')] + r'''
git_commit() { printf 'COMMIT\n'; }
_git_push_provider() {
    printf 'PUSH:%s\n' "$2"
    if [[ "$2" == "$PUSH_PROVIDER" || "$PUSH_PROVIDER" == all ]]; then
        projects_git_note_unavailable curl 7
        print_error 'cascade réseau'
        return 128
    fi
}
projects_docker_build() { printf 'BUILD\n'; }
projects_forgejo_release() { printf 'RELEASE:forgejo\n'; }
projects_gitlab_release() { printf 'RELEASE:gitlab\n'; }
projects_github_release() { printf 'RELEASE:github\n'; }
cicd_project project commit v1.2.3
'''
