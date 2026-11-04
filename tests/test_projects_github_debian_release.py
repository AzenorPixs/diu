"""Release Debian GitHub : paquets réels et transports entièrement simulés."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HEAD = 'a' * 40
TAG = 'b' * 40
OTHER = 'c' * 40
HARNESS = r'''
set -Eeuo pipefail
source "$1/lib/github-auth.sh"
source "$1/modules/projects/github-release.sh"
ENV_DEVOPS_PROJECTS_ROOT="$2"
ENV_DEVOPS_USER=fixture
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf 'SUCCESS:%s\n' "$*"; }
check_devops_user() { return 0; }
_github_ensure_api_credentials() { github_username=fixture; github_token=fixture-private-token; }
github_git_fetch() { [[ "${FETCH_FAIL:-}" != yes ]]; }
runuser() {
    shift 3
    if [[ "${1:-}" == env ]]; then shift 3; fi
    case "$*" in
        *'remote get-url'*) printf '%s' "${REMOTE_OVERRIDE:-https://github.com/owner/project.git}" ;;
        *'branch --show-current') printf '%s' "${BRANCH_OVERRIDE:-main}" ;;
        *'rev-parse refs/remotes/github/main') printf '%s' "${REMOTE_SHA:-$HEAD_SHA}" ;;
        *'rev-parse --verify refs/tags/'*) [[ "${LOCAL_TAG_MISSING:-}" != yes ]] || return 1; printf '%s' "$HEAD_SHA" ;;
        *'rev-parse HEAD'|*'rev-parse --verify HEAD') printf '%s' "$HEAD_SHA" ;;
        *'merge-base --is-ancestor'*) [[ "${REPLAY_ANCESTOR:-}" == yes ]] ;;
        *'tag --points-at HEAD') printf '%s' "${LOCAL_TAGS:-v1.0.3}" ;;
        *'log -1 --format=%s') printf 'fixture release' ;;
        *) printf 'Unexpected Git operation\n' >&2; return 92 ;;
    esac
}
curl() {
    local method=GET url="" output="" config="" data="" arg="" code=200 body='{}' kind=""
    while [[ $# -gt 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --request) method="$1"; shift ;;
            --output) output="$1"; shift ;;
            --config) config="$1"; shift ;;
            --data-binary) data="$1"; shift ;;
            --header|--write-out|--connect-timeout|--max-time) shift ;;
            https://*) url="$arg" ;;
        esac
    done
    [[ "$(stat -c '%a' "$config")" == 600 ]] || return 93
    [[ "$url $method $data" != *fixture-private-token* ]] || return 94
    jq -nc --arg method "$method" --arg url "$url" --arg data "$data" \
        '{method:$method,url:$url,data:$data}' >> "$API_LOG"
    case "$method:$url" in
        GET:*'/git/ref/tags/'*)
            kind=tag
            if [[ "${TAG_ABSENT:-}" == yes ]]; then code=404
            elif [[ "${LIGHTWEIGHT_TAG:-}" == yes ]]; then
                body="$(jq -nc --arg sha "${TAG_COMMIT:-$HEAD_SHA}" '{object:{type:"commit",sha:$sha}}')"
            else body="$(jq -nc --arg sha "$TAG_SHA" '{object:{type:"tag",sha:$sha}}')"; fi ;;
        GET:*'/git/tags/'*)
            kind=peel; body="$(jq -nc --arg sha "${TAG_COMMIT:-$HEAD_SHA}" '{object:{type:"commit",sha:$sha}}')" ;;
        GET:*'/releases/tags/'*)
            kind=lookup; code=404
            if [[ "${RELEASE_EXISTS:-}" == yes ]]; then code=200; body='{"id":22}'; fi
            if [[ "${RELEASE_EXISTS:-}" == complete ]]; then
                code=200; body='{"id":22,"tag_name":"v1.0.3","assets":[{"name":"project_1.0.3_all.deb","state":"uploaded"}]}'
            elif [[ "${RELEASE_EXISTS:-}" == incomplete ]]; then
                code=200; body='{"id":22,"tag_name":"v1.0.3","assets":[],"upload_url":"https://uploads.github.com/repos/owner/project/releases/22/assets{?name,label}"}'
            fi ;;
        POST:*'/git/tags') kind=create_tag; code=201; body="$(jq -nc --arg sha "$TAG_SHA" '{sha:$sha}')" ;;
        POST:*'/git/refs') kind=create_ref; code=201; body='{"ref":"refs/tags/v1.0.3"}' ;;
        POST:*'/releases')
            kind=create_release; code=201
            body="$(jq -nc --arg url "${UPLOAD_URL:-https://uploads.github.com/repos/owner/project/releases/22/assets{?name,label}}" '{id:22,upload_url:$url}')" ;;
        POST:https://uploads.github.com/*|POST:https://enterprise.example.test/api/v3/*'/assets?name='*)
            kind=upload; code=201
            local file="${data#@}" size="" name=""
            [[ "$data" == @* && -f "$file" ]] || return 95
            size="$(stat -c '%s' "$file")"; name="$(basename -- "$file")"
            if [[ "${BAD_ASSET:-}" == name ]]; then name=other.deb; fi
            if [[ "${BAD_ASSET:-}" == size ]]; then size=1; fi
            body="$(jq -nc --arg name "$name" --argjson size "$size" '{id:77,name:$name,size:$size,state:"uploaded"}')" ;;
        *) printf 'Unexpected API route\n' >&2; return 96 ;;
    esac
    if [[ "${NETWORK_FAIL:-}" == "$kind" ]]; then return 7; fi
    if [[ "${INTERRUPT_UPLOAD:-}" == yes && "$kind" == upload ]]; then kill -TERM "$BASHPID"; fi
    if [[ "${HTTP_FAIL_KIND:-}" == "$kind" ]]; then code="${HTTP_FAIL_CODE:-403}"; fi
    if [[ "${INVALID_JSON:-}" == "$kind" ]]; then body='invalid-json'; fi
    printf '%s' "$body" > "$output"
    printf '%s' "$code"
}
projects_github_release_debian project
'''


class GithubDebianReleaseTests(unittest.TestCase):
    def test_replay_allows_tagged_ancestor_without_rewinding_remote(self):
        result = self.run_release(harness=HARNESS.replace('projects_github_release_debian project',
                                                        'PROJECTS_CICD_REPLAY=1\nprojects_github_release_debian project'),
                                  REMOTE_SHA=OTHER, REPLAY_ANCESTOR='yes', RELEASE_EXISTS='complete')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('déjà publié', result.stdout)
        self.assertIn('Répertoire isolé :', result.stdout)
        self.assertTrue(all(call['method'] == 'GET' for call in self.calls()))

    def test_replay_rejects_tag_outside_remote_history(self):
        result = self.run_release(harness=HARNESS.replace('projects_github_release_debian project',
                                                        'PROJECTS_CICD_REPLAY=1\nprojects_github_release_debian project'),
                                  REMOTE_SHA=OTHER)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(call['method'] == 'POST' for call in self.calls()))

    def test_existing_complete_release_is_informational(self):
        result = self.run_release(RELEASE_EXISTS='complete')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('déjà publié', result.stdout)
        self.assertIn('GitHub : identifiants disponibles.', result.stdout)
        self.assertIn('GitHub : récupération Git effectuée', result.stdout)
        self.assertIn('GitHub : HEAD synchronisé', result.stdout)
        self.assertIn('GitHub : tag v1.0.3 déjà présent et cohérent.', result.stdout)
        self.assertIn('déjà publié sur GitHub pour v1.0.3', result.stdout)
        labels = ('Projet', 'ID projet', 'Répertoire', 'Type distant', 'Dépôt distant', 'URL distante', 'Branche locale', 'Branche distante')
        rows = [line for line in result.stdout.splitlines() if ' : ' in line and line.split(' : ', 1)[0].strip() in labels]
        self.assertEqual(len(rows), len(labels))
        self.assertEqual({line.index(' : ') for line in rows}, {16})
        self.assertTrue(all(call['method'] == 'GET' for call in self.calls()))

    def test_existing_incomplete_release_adds_only_missing_asset(self):
        result = self.run_release(RELEASE_EXISTS='incomplete')
        self.assertEqual(result.returncode, 0, result.stderr)
        posts = [call for call in self.calls() if call['method'] == 'POST']
        self.assertEqual(len(posts), 1)
        self.assertIn('/assets?name=', posts[0]['url'])

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.github-deb-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.project = self.base / 'project'
        (self.project / 'dist').mkdir(parents=True)
        self.scratch = self.base / 'http'
        self.scratch.mkdir()
        self.log = self.base / 'api.log'
        self.config = self.project / 'project.env'
        self.config.write_text('PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_DOCKERED=No\n'
                               'PROJECT_DEBIAN_PACKAGE=Yes\nPROJECT_VERSION=1.0.3\nLOCAL_DEFAULT_BRANCH=main\n'
                               'REMOTE_GITHUB_BASE_URL=https://github.com\nREMOTE_GITHUB_OWNER=owner\n'
                               'REMOTE_GITHUB_REPOSITORY=project\nREMOTE_GITHUB_NAME=github\nREMOTE_GITHUB_BRANCH=main\n')
        self.build_package()

    def build_package(self, name='project', version='1.0.3', architecture='all', filename=None):
        staging = self.base / 'staging'
        (staging / 'DEBIAN').mkdir(parents=True, exist_ok=True)
        (staging / 'DEBIAN').chmod(0o755)
        (staging / 'DEBIAN/control').write_text(
            f'Package: {name}\nVersion: {version}\nArchitecture: {architecture}\n'
            'Maintainer: Fixture <fixture@example.test>\nDescription: Fixture package\n')
        package = self.project / 'dist' / (filename or f'{name}_{version}_{architecture}.deb')
        result = subprocess.run(['dpkg-deb', '--build', '--root-owner-group', str(staging), str(package)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return package

    def run_release(self, harness=HARNESS, **settings):
        self.log.unlink(missing_ok=True)
        before = self.config.read_bytes()
        result = subprocess.run(['bash', '-c', harness, 'fixture', str(ROOT), str(self.base)],
                                capture_output=True, text=True, env={**os.environ,
                                'TMPDIR': str(self.scratch), 'API_LOG': str(self.log),
                                'HEAD_SHA': HEAD, 'TAG_SHA': TAG, **settings})
        self.assertEqual(self.config.read_bytes(), before)
        self.assertEqual(list(self.scratch.iterdir()), [])
        self.assertNotIn('fixture-private-token', result.stdout + result.stderr)
        return result

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_existing_annotated_tag_creates_release_and_uploads_package(self):
        result = self.run_release()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('SUCCESS:Paquet Debian publié sur GitHub', result.stdout)
        self.assertIn('/releases/download/v1.0.3/project_1.0.3_all.deb', result.stdout)
        calls = self.calls()
        self.assertEqual([c['method'] for c in calls], ['GET', 'GET', 'GET', 'POST', 'POST'])
        self.assertEqual(json.loads(calls[-2]['data'])['target_commitish'], HEAD)
        self.assertTrue(calls[-1]['data'].startswith('@'))
        self.assertIn('name=project_1.0.3_all.deb', calls[-1]['url'])
        self.assertNotIn('fixture-private-token', self.log.read_text())

    def test_lightweight_tag_and_three_active_values(self):
        for value in ['Yes', 'YES', '1']:
            text = self.config.read_text()
            self.config.write_text(text.replace('PROJECT_DEBIAN_PACKAGE=Yes', f'PROJECT_DEBIAN_PACKAGE={value}'))
            result = self.run_release(LIGHTWEIGHT_TAG='yes')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.config.write_text(text)

    def test_disabled_publication_makes_no_api_call(self):
        self.config.write_text(self.config.read_text().replace('PROJECT_DEBIAN_PACKAGE=Yes', 'PROJECT_DEBIAN_PACKAGE=No'))
        result = self.run_release()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])

    def test_missing_multiple_or_mismatched_packages_are_refused(self):
        package = self.project / 'dist/project_1.0.3_all.deb'
        saved = package.read_bytes()
        package.unlink()
        self.assertNotEqual(self.run_release().returncode, 0)
        self.assertEqual(self.calls(), [])
        package.write_bytes(saved)
        other = self.build_package(name='other')
        self.assertNotEqual(self.run_release().returncode, 0)
        self.assertEqual(self.calls(), [])
        other.unlink()
        package.rename(package.with_name('wrong_1.0.3_all.deb'))
        self.assertNotEqual(self.run_release().returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_version_mismatch_and_missing_local_tag_are_refused(self):
        self.config.write_text(self.config.read_text().replace('PROJECT_VERSION=1.0.3', 'PROJECT_VERSION=2.0.0'))
        self.assertNotEqual(self.run_release().returncode, 0)
        self.assertEqual(self.calls(), [])
        self.config.write_text(self.config.read_text().replace('PROJECT_VERSION=2.0.0', 'PROJECT_VERSION=1.0.3'))
        self.assertNotEqual(self.run_release(LOCAL_TAG_MISSING='yes').returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_remote_configuration_branch_and_sync_are_required(self):
        for settings in [{'REMOTE_OVERRIDE': 'https://github.com/other/project.git'},
                         {'BRANCH_OVERRIDE': 'other'}, {'REMOTE_SHA': OTHER}, {'FETCH_FAIL': 'yes'}]:
            self.assertNotEqual(self.run_release(**settings).returncode, 0)
            self.assertEqual(self.calls(), [])

    def test_remote_tag_mismatch_and_existing_release_never_write(self):
        for settings in [{'TAG_COMMIT': OTHER}, {'RELEASE_EXISTS': 'yes'}]:
            result = self.run_release(**settings)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(any(call['method'] != 'GET' for call in self.calls()))

    def test_absent_remote_tag_is_created_without_replacing_a_ref(self):
        result = self.run_release(TAG_ABSENT='yes')
        self.assertEqual(result.returncode, 0, result.stderr)
        posts = [c for c in self.calls() if c['method'] == 'POST']
        self.assertIn('/git/tags', posts[0]['url'])
        self.assertIn('/git/refs', posts[1]['url'])
        self.assertEqual(json.loads(posts[0]['data'])['object'], HEAD)
        self.assertEqual(json.loads(posts[1]['data'])['ref'], 'refs/tags/v1.0.3')

    def test_no_git_tag_fallback_matches_forgejo_existing_tag_policy(self):
        self.config.write_text(self.config.read_text().replace('PROJECT_VERSION=1.0.3\n', ''))
        result = self.run_release(TAG_ABSENT='yes')
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.run_release()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(c['method'] == 'POST' for c in self.calls()))

    def test_http_failures_do_not_announce_success(self):
        for kind in ['tag', 'lookup', 'create_release', 'upload']:
            for code in ['401', '403', '422', '500']:
                result = self.run_release(HTTP_FAIL_KIND=kind, HTTP_FAIL_CODE=code)
                self.assertNotEqual(result.returncode, 0, (kind, code))
                self.assertNotIn('SUCCESS:', result.stdout)

    def test_json_network_and_asset_failures_are_explicit(self):
        for settings in [{'INVALID_JSON': 'tag'}, {'INVALID_JSON': 'create_release'},
                         {'INVALID_JSON': 'upload'}, {'NETWORK_FAIL': 'upload'},
                         {'BAD_ASSET': 'name'}, {'BAD_ASSET': 'size'}]:
            result = self.run_release(**settings)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('SUCCESS:', result.stdout)
        self.assertIn('incomplète', result.stderr)

    def test_unexpected_upload_origin_or_path_never_receives_credentials(self):
        for url in ['https://other.example.test/repos/owner/project/releases/22/assets',
                    'https://uploads.github.com/repos/other/project/releases/22/assets',
                    'https://uploads.github.com/repos/owner/project/releases/99/assets']:
            result = self.run_release(UPLOAD_URL=url)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(any('uploads.github.com' in c['url'] or 'other.example.test' in c['url'] for c in self.calls()))

    def test_enterprise_upload_uses_its_own_api_origin(self):
        self.config.write_text(self.config.read_text().replace('https://github.com', 'https://enterprise.example.test'))
        result = self.run_release(REMOTE_OVERRIDE='https://enterprise.example.test/owner/project.git',
                                  UPLOAD_URL='https://enterprise.example.test/api/v3/repos/owner/project/releases/22/assets{?name,label}')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.calls()[-1]['url'].startswith('https://enterprise.example.test/api/v3/'))

    def test_interrupted_upload_cleans_private_temporary_files(self):
        result = self.run_release(INTERRUPT_UPLOAD='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('incomplète', result.stderr)
        self.assertNotIn('SUCCESS:', result.stdout)

    def test_concurrent_ref_creation_is_not_overwritten(self):
        result = self.run_release(TAG_ABSENT='yes', HTTP_FAIL_KIND='create_ref', HTTP_FAIL_CODE='422')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(c['url'].endswith('/releases') for c in self.calls()))
        self.assertFalse(any(c['method'] in ['PATCH', 'DELETE'] for c in self.calls()))

    def test_wrong_package_name_and_architecture_are_refused(self):
        for name, architecture in [('other', 'all'), ('project', 'amd64')]:
            self.build_package(name=name, architecture=architecture, filename='project_1.0.3_all.deb')
            result = self.run_release()
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(self.calls(), [])

    def parent_harness(self, mocked=True):
        call = 'projects_github_release project\n'
        if mocked:
            call = r'''
projects_github_release_docker() { printf 'DOCKER-PUBLISHED\n'; [[ "${DOCKER_FAIL:-}" != yes ]]; }
projects_github_release_debian() { printf 'DEBIAN-PUBLISHED\n'; [[ "${DEBIAN_FAIL:-}" != yes ]]; }
''' + call
        return HARNESS.replace('source "$1/lib/github-auth.sh"',
                               'source "$1/modules/projects/git.sh"\nsource "$1/lib/github-auth.sh"', 1).replace(
                                   'projects_github_release_debian project\n', call)

    def set_flags(self, docker, debian):
        lines = self.config.read_text().splitlines()
        self.config.write_text('\n'.join(
            f'PROJECT_DOCKERED={docker}' if line.startswith('PROJECT_DOCKERED=') else
            f'PROJECT_DEBIAN_PACKAGE={debian}' if line.startswith('PROJECT_DEBIAN_PACKAGE=') else line
            for line in lines) + '\n')

    def test_parent_selects_each_artifact_for_all_three_active_values(self):
        for value in ['Yes', 'YES', '1']:
            for docker, debian, expected in [(value, 'No', ['DOCKER-PUBLISHED']),
                                             ('No', value, ['DEBIAN-PUBLISHED']),
                                             (value, value, ['DOCKER-PUBLISHED', 'DEBIAN-PUBLISHED'])]:
                with self.subTest(docker=docker, debian=debian):
                    self.set_flags(docker, debian)
                    result = self.run_release(harness=self.parent_harness())
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout.splitlines(), expected)

    def test_parent_without_active_artifacts_publishes_nothing(self):
        self.set_flags('No', 'No')
        result = self.run_release(harness=self.parent_harness())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Aucun artefact activé', result.stdout)
        self.assertNotIn('PUBLISHED', result.stdout)

    def test_parent_requires_package_before_mixed_docker_publication(self):
        self.set_flags('Yes', 'Yes')
        (self.project / 'dist/project_1.0.3_all.deb').unlink()
        result = self.run_release(harness=self.parent_harness())
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('PUBLISHED', result.stdout)

    def test_parent_failure_keeps_partial_publication_explicit(self):
        self.set_flags('Yes', 'Yes')
        result = self.run_release(harness=self.parent_harness(), DOCKER_FAIL='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('DEBIAN-PUBLISHED', result.stdout)
        result = self.run_release(harness=self.parent_harness(), DEBIAN_FAIL='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('déjà publiée', result.stderr)

    def test_public_parent_routes_to_real_debian_publisher_without_docker(self):
        result = self.run_release(harness=self.parent_harness(mocked=False))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('SUCCESS:Paquet Debian publié sur GitHub', result.stdout)

    def test_public_parent_routes_mixed_publication_to_real_debian_publisher(self):
        self.set_flags('Yes', 'Yes')
        harness = self.parent_harness(mocked=False).replace('projects_github_release project\n',
            'projects_github_release_docker() { printf "DOCKER-PUBLISHED\\n"; }\nprojects_github_release project\n')
        result = self.run_release(harness=harness)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(result.stdout.startswith('DOCKER-PUBLISHED\n'))
        self.assertIn('SUCCESS:Paquet Debian publié sur GitHub', result.stdout)

    def test_help_describes_both_activations_before_bootstrap(self):
        for args in [('projects', 'github'), ('projects', 'github', 'release'),
                     ('projects', 'github', 'release', 'diu')]:
            for word in ['help', '?']:
                result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *args, word],
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('PROJECT_DOCKERED=Yes/YES/1', result.stdout)
                self.assertIn('PROJECT_DEBIAN_PACKAGE=Yes/YES/1', result.stdout)
                self.assertIn('sans build', result.stdout)

    def test_invalid_identifiers_and_symbolic_projects_are_refused(self):
        (self.base / 'alias').symlink_to(self.project, target_is_directory=True)
        for target in ['../project', '', 'alias']:
            for parent in [False, True]:
                harness = self.parent_harness(mocked=False) if parent else HARNESS
                name = 'projects_github_release' if parent else 'projects_github_release_debian'
                harness = harness.replace(f'{name} project\n', f'{name} "{target}"\n')
                result = self.run_release(harness=harness)
                self.assertNotEqual(result.returncode, 0, (target, parent))
                self.assertEqual(self.calls(), [])


if __name__ == '__main__':
    unittest.main()
