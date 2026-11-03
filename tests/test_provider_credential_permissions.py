"""Permissions des identifiants fictifs des trois fournisseurs, sans réseau."""
import os
from pathlib import Path
import stat
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PROVIDERS = ('forgejo', 'github', 'gitlab')
USERNAME = 'fixture-user-private'
TOKEN = 'fixture-token-private'
HARNESS = r'''
set -Eeuo pipefail
source "$1/lib/$3-auth.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { :; }
print_success() { :; }
project_path="$2"
provider="$3"
kind="$4"
action="$5"
if [[ "$action" == stat-failure ]]; then
    stat() { return 1; }
fi
variable="${provider}_${kind}"
printf -v "$variable" '%s' 'non-lu'
if "_${provider}_read_${kind}" "$project_path"; then
    [[ "$action" == accepted ]] || exit 81
    expected="$FIXTURE_TOKEN"
    [[ "$kind" != username ]] || expected="$FIXTURE_USERNAME"
    [[ "${!variable}" == "$expected" ]] || exit 82
else
    [[ "$action" != accepted ]] || exit 83
    if [[ "$action" != empty ]]; then
        [[ "${!variable}" == non-lu ]] || exit 84
    fi
fi
'''

TRANSPORT_HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
source "$1/lib/$3-auth.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { :; }
print_success() { :; }
runuser() { shift 2; [[ "${1:-}" != -- ]] || shift; "$@"; }
DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
export FIXTURE_PROVIDER="$3"
_forgejo_validate_credentials() { _forgejo_prepare_context "$@"; }
case "$5" in
    fetch|push)
        "$3_git_$5" "$2" origin main
        ;;
    clone)
        "$3_git_clone" "$2" "https://$3.example.test/owner/project.git" main "$2/clone"
        ;;
    initialize)
        "_$3_initialize_credentials" "$2"
        ;;
    api)
        if [[ "$3" == forgejo ]]; then
            forgejo_api_get "$2" /user
        else
            _github_ensure_api_credentials "$2"
            _github_api_request https://github.example.test GET /user
        fi
        ;;
    registry)
        ENV_DEVOPS_PROJECTS_ROOT="${2%/*}"
        projects_gitlab_release_docker "${2##*/}"
        ;;
esac
'''

GIT_TRANSPORT = r'''#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$*" == *'remote get-url'* ]]; then
    printf 'https://%s.example.test/owner/project.git\n' "$FIXTURE_PROVIDER"
    exit 0
fi
if [[ "$*" == *'rev-parse --is-inside-work-tree'* ]]; then
    printf 'true\n'
    exit 0
fi
if [[ "$*" == *'tag --points-at HEAD'* ]]; then
    printf 'v1.2.3\n'
    exit 0
fi
for argument in "$@"; do
    [[ "$argument" != *"$FIXTURE_TOKEN"* && "$argument" != *"$FIXTURE_USERNAME"* ]] || exit 90
done
[[ "$GIT_TERMINAL_PROMPT" == 0 ]] || exit 91
credentials_dir="$(dirname "$GIT_ASKPASS")"
[[ "$(stat -c %a "$credentials_dir")" == 700 ]] || exit 92
[[ "$(stat -c %a "$credentials_dir/credentials")" == 600 ]] || exit 93
[[ "$(stat -c %a "$GIT_ASKPASS")" == 700 ]] || exit 94
[[ "$("$GIT_ASKPASS" Username)" == "$FIXTURE_USERNAME" ]] || exit 95
[[ "$("$GIT_ASKPASS" Password)" == "$FIXTURE_TOKEN" ]] || exit 96
printf 'GIT:%s\n' "$*" >> "$FIXTURE_CALLS"
printf '%s\n' "$credentials_dir" >> "$FIXTURE_TEMPORARIES"
exit "${FIXTURE_TRANSPORT_RC:-0}"
'''

CURL_TRANSPORT = r'''#!/usr/bin/env bash
set -Eeuo pipefail
config=""
response=""
for argument in "$@"; do
    [[ "$argument" != *"$FIXTURE_TOKEN"* && "$argument" != *"$FIXTURE_USERNAME"* ]] || exit 90
done
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --config) config="$2"; shift ;;
        --output|-o) response="$2"; shift ;;
    esac
    shift
done
[[ "$(stat -c %a "$config")" == 600 ]] || exit 91
[[ "$(stat -c %a "$response")" == 600 ]] || exit 92
[[ "$(< "$config")" == *"$FIXTURE_TOKEN"* ]] || exit 93
printf 'API\n' >> "$FIXTURE_CALLS"
printf '%s\n' "$config" "$response" >> "$FIXTURE_TEMPORARIES"
printf '{}\n' > "$response"
printf '200'
exit "${FIXTURE_TRANSPORT_RC:-0}"
'''

DOCKER_TRANSPORT = r'''#!/usr/bin/env bash
set -Eeuo pipefail
printf 'REGISTRY:%s\n' "$1" >> "$FIXTURE_CALLS"
if [[ "$1" == login ]]; then
    [[ "$*" == *--password-stdin* ]] || exit 90
    [[ "$(cat)" == "$FIXTURE_TOKEN" ]] || exit 91
    [[ "$(stat -c %a "$DOCKER_CONFIG")" == 700 ]] || exit 92
    printf '%s\n' "$DOCKER_CONFIG" >> "$FIXTURE_TEMPORARIES"
    exit "${FIXTURE_TRANSPORT_RC:-0}"
fi
'''


class ProviderCredentialPermissionsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.provider-auth-test-')
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.project = self.base / 'project with spaces'
        self.config = self.project / 'config'
        self.config.mkdir(parents=True)
        (self.project / '.git').mkdir()
        (self.base / 'scratch').mkdir()
        # Le dépôt partagé est setgid ; isoler ce détail de l'environnement.
        (self.base / 'scratch').chmod(0o700)
        binaries = self.base / 'bin'
        binaries.mkdir()
        for name, source in (('git', GIT_TRANSPORT), ('curl', CURL_TRANSPORT),
                             ('docker', DOCKER_TRANSPORT)):
            executable = binaries / name
            executable.write_text(source, encoding='utf-8')
            executable.chmod(0o700)
        self.env = dict(os.environ, TMPDIR=str(self.base / 'scratch'),
                        FIXTURE_USERNAME=USERNAME, FIXTURE_TOKEN=TOKEN,
                        PATH=str(binaries) + os.pathsep + os.defpath,
                        FIXTURE_CALLS=str(self.base / 'calls'),
                        FIXTURE_TEMPORARIES=str(self.base / 'temporaries'))
        for provider in PROVIDERS:
            for kind, value in (('username', USERNAME), ('token', TOKEN)):
                path = self.config / f'{provider}.{kind}'
                path.write_text(value + '\n', encoding='utf-8')
                path.chmod(0o600)

    def run_script(self, script, provider, kind, action):
        result = subprocess.run(
            ['bash', '-c', script, 'bash', str(ROOT), str(self.project),
             provider, kind, action], env=self.env, text=True,
            capture_output=True, timeout=15, check=False,
        )
        self.assertNotIn(TOKEN, result.stdout + result.stderr)
        self.assertNotIn(USERNAME, result.stdout + result.stderr)
        return result

    def test_accepts_exact_600_and_660_without_changing_files(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                path = self.config / f'{provider}.{kind}'
                original = path.read_bytes()
                for mode in (0o600, 0o660):
                    with self.subTest(provider=provider, kind=kind, mode=oct(mode)):
                        path.chmod(mode)
                        before = path.stat()
                        result = self.run_script(HARNESS, provider, kind, 'accepted')
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assertEqual(result.stdout + result.stderr, '')
                        self.assertEqual(path.read_bytes(), original)
                        self.assertEqual(stat.S_IMODE(path.stat().st_mode), mode)
                        self.assertEqual(path.stat().st_mtime_ns, before.st_mtime_ns)
                        self.assertEqual(path.stat().st_ctime_ns, before.st_ctime_ns)

    def test_rejects_other_modes_before_reading_without_chmod(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                path = self.config / f'{provider}.{kind}'
                for mode in (0o000, 0o400, 0o640, 0o644, 0o664, 0o666,
                             0o700, 0o760, 0o777, 0o1600, 0o2660, 0o4600):
                    with self.subTest(provider=provider, kind=kind, mode=oct(mode)):
                        path.chmod(mode)
                        before = path.stat()
                        result = self.run_script(HARNESS, provider, kind, 'rejected')
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assertIn('600 ou 660', result.stderr)
                        self.assertEqual(stat.S_IMODE(path.stat().st_mode), mode)
                        self.assertEqual(path.stat().st_ctime_ns, before.st_ctime_ns)
                path.chmod(0o600)

    def test_missing_file_is_rejected_without_creating_it(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                with self.subTest(provider=provider, kind=kind):
                    path = self.config / f'{provider}.{kind}'
                    path.unlink()
                    result = self.run_script(HARNESS, provider, kind, 'missing')
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn('ERREUR:', result.stderr)
                    self.assertFalse(path.exists())

    def test_empty_file_is_rejected_for_both_accepted_modes(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                path = self.config / f'{provider}.{kind}'
                path.write_text('', encoding='utf-8')
                for mode in (0o600, 0o660):
                    with self.subTest(provider=provider, kind=kind, mode=oct(mode)):
                        path.chmod(mode)
                        result = self.run_script(HARNESS, provider, kind, 'empty')
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assertIn('vide', result.stderr)
                        self.assertEqual(path.read_bytes(), b'')
                        self.assertEqual(stat.S_IMODE(path.stat().st_mode), mode)

    def test_stat_failure_prevents_reading(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                with self.subTest(provider=provider, kind=kind):
                    result = self.run_script(HARNESS, provider, kind, 'stat-failure')
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn('600 ou 660', result.stderr)

    def configure_modes(self, provider, username_mode, token_mode):
        for kind, mode in (('username', username_mode), ('token', token_mode)):
            (self.config / f'{provider}.{kind}').chmod(mode)

    def assert_private_resources_cleaned(self):
        self.assertEqual(list((self.base / 'scratch').iterdir()), [])
        for line in (self.base / 'temporaries').read_text().splitlines():
            self.assertFalse(Path(line).exists(), line)

    def test_git_push_and_fetch_use_shared_or_private_files_and_private_askpass(self):
        for provider in PROVIDERS:
            for username_mode, token_mode in ((0o600, 0o600), (0o660, 0o660),
                                               (0o600, 0o660), (0o660, 0o600)):
                self.configure_modes(provider, username_mode, token_mode)
                for action in ('push', 'fetch'):
                    with self.subTest(provider=provider, action=action,
                                      modes=(username_mode, token_mode)):
                        result = self.run_script(TRANSPORT_HARNESS, provider, '', action)
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assert_private_resources_cleaned()
                        for kind, mode in (('username', username_mode), ('token', token_mode)):
                            self.assertEqual(stat.S_IMODE((self.config / f'{provider}.{kind}').stat().st_mode), mode)
        calls = (self.base / 'calls').read_text()
        self.assertEqual(calls.count('GIT:'), 24)
        self.assertNotIn(TOKEN, calls)
        self.assertNotIn(USERNAME, calls)

    def test_existing_clone_providers_accept_660(self):
        for provider in ('github', 'gitlab'):
            with self.subTest(provider=provider):
                self.configure_modes(provider, 0o660, 0o660)
                result = self.run_script(TRANSPORT_HARNESS, provider, '', 'clone')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assert_private_resources_cleaned()
        self.assertEqual((self.base / 'calls').read_text().count(' clone '), 2)

    def test_existing_660_files_are_reused_by_initialization(self):
        for provider in ('github', 'gitlab'):
            with self.subTest(provider=provider):
                self.configure_modes(provider, 0o660, 0o660)
                before = {p: p.stat().st_ctime_ns for p in self.config.iterdir()}
                result = self.run_script(TRANSPORT_HARNESS, provider, '', 'initialize')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(before, {p: p.stat().st_ctime_ns for p in self.config.iterdir()})
                self.assertFalse((self.base / 'calls').exists())

    def test_invalid_mode_blocks_git_before_transport(self):
        for provider in PROVIDERS:
            for kind in ('username', 'token'):
                with self.subTest(provider=provider, kind=kind):
                    self.configure_modes(provider, 0o660, 0o660)
                    (self.config / f'{provider}.{kind}').chmod(0o664)
                    result = self.run_script(TRANSPORT_HARNESS, provider, '', 'push')
                    self.assertEqual(result.returncode, 1, result.stderr)
                    self.assertIn('600 ou 660', result.stderr)
                    self.assertFalse((self.base / 'calls').exists())
                    self.assertEqual(list((self.base / 'scratch').iterdir()), [])

    def test_git_failure_keeps_original_code_and_cleans_private_files(self):
        self.env['FIXTURE_TRANSPORT_RC'] = '73'
        for provider in PROVIDERS:
            with self.subTest(provider=provider):
                self.configure_modes(provider, 0o660, 0o660)
                result = self.run_script(TRANSPORT_HARNESS, provider, '', 'push')
                self.assertEqual(result.returncode, 73, result.stderr)
                self.assert_private_resources_cleaned()

    def test_api_providers_accept_660_and_keep_curl_files_private(self):
        for provider in ('forgejo', 'github'):
            with self.subTest(provider=provider):
                self.configure_modes(provider, 0o660, 0o660)
                result = self.run_script(TRANSPORT_HARNESS, provider, '', 'api')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('200', result.stdout)
                self.assert_private_resources_cleaned()
                for kind in ('username', 'token'):
                    self.assertEqual(stat.S_IMODE((self.config / f'{provider}.{kind}').stat().st_mode), 0o660)

    def test_api_failure_cleans_private_files(self):
        self.env['FIXTURE_TRANSPORT_RC'] = '7'
        for provider in ('forgejo', 'github'):
            with self.subTest(provider=provider):
                self.configure_modes(provider, 0o660, 0o660)
                result = self.run_script(TRANSPORT_HARNESS, provider, '', 'api')
                self.assertEqual(result.returncode, 7, result.stderr)
                self.assert_private_resources_cleaned()

    def test_invalid_mode_blocks_api_before_transport(self):
        for provider in ('forgejo', 'github'):
            for kind in ('username', 'token'):
                with self.subTest(provider=provider, kind=kind):
                    self.configure_modes(provider, 0o660, 0o660)
                    (self.config / f'{provider}.{kind}').chmod(0o664)
                    result = self.run_script(TRANSPORT_HARNESS, provider, '', 'api')
                    self.assertEqual(result.returncode, 1, result.stderr)
                    self.assertFalse((self.base / 'calls').exists())
                    self.assertEqual(list((self.base / 'scratch').iterdir()), [])

    def test_gitlab_registry_accepts_660_and_cleans_private_configuration(self):
        (self.project / 'project.env').write_text(
            'PROJECT_ID=fixture\nPROJECT_DOCKERED=Yes\n'
            'REMOTE_GITLAB_BASE_URL=https://gitlab.example.test\n'
            'REMOTE_GITLAB_REGISTRY=registry.example.test\n'
            'REMOTE_GITLAB_OWNER=owner\nREMOTE_GITLAB_REPOSITORY=project\n',
            encoding='utf-8',
        )
        self.configure_modes('gitlab', 0o660, 0o660)
        for code, expected in (('0', 0), ('77', 1)):
            with self.subTest(transport_returncode=code):
                self.env['FIXTURE_TRANSPORT_RC'] = code
                result = self.run_script(TRANSPORT_HARNESS, 'gitlab', '', 'registry')
                self.assertEqual(result.returncode, expected, result.stderr)
                self.assert_private_resources_cleaned()
                for kind in ('username', 'token'):
                    path = self.config / f'gitlab.{kind}'
                    self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o660)
        calls = (self.base / 'calls').read_text()
        self.assertEqual(calls.count('REGISTRY:login'), 2)
        self.assertEqual(calls.count('REGISTRY:push'), 2)


if __name__ == '__main__':
    unittest.main()
