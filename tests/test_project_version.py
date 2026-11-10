"""Priorité de version sur fixtures isolées, sans publication ni Docker réel."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import unittest
import test_projects_docker_build_args as docker_fixtures
import test_projects_forgejo_push as push_fixtures

ROOT = Path(__file__).resolve().parents[1]


class ProjectVersionTests(unittest.TestCase):
    def test_latest_remote_tag_prefers_stable_version(self):
        result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
git() { printf '1111111111111111111111111111111111111111\trefs/tags/v2026.11.03.08.38\n2222222222222222222222222222222222222222\trefs/tags/v1.0.7\n'; }
git_get_latest_release https://example.test owner project
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'v1.0.7')

    def test_local_stable_tag_precedes_timestamp_for_both_debian_builders(self):
        (self.project / '.git').mkdir()
        result = self.run_shell(r'''
source "$1/modules/projects/diu-packaging.sh"
source "$1/modules/projects/debian-build.sh"
runuser() { printf 'v2026.11.03.08.38\nv1.0.7\n'; }
diu_package_version_from_head "$project"; printf '\n'
projects_debian_version "$project"; printf '\n'
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '1.0.7\n1.0.7\n')

    def test_set_version_preserves_other_content_and_permissions(self):
        self.config.write_bytes(b'OTHER=value\nexport PROJECT_VERSION="1.0.0" # note\nTAIL=no-newline')
        self.config.chmod(0o640)
        result = self.run_shell('project_version_set "$project/project.env" 1.0.7')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_bytes(), b'OTHER=value\nexport PROJECT_VERSION="1.0.7" # note\nTAIL=no-newline')
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o640)
        before = self.config.stat().st_mtime_ns
        result = self.run_shell('project_version_set "$project/project.env" 1.0.7')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.stat().st_mtime_ns, before)

    def test_set_version_rejects_ambiguous_or_invalid_config(self):
        self.config.write_bytes(b'PROJECT_VERSION=1.0.0\nPROJECT_VERSION=1.0.1\n')
        original = self.config.read_bytes()
        result = self.run_shell('project_version_set "$project/project.env" 1.0.7')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_bytes(), original)

    def test_set_version_adds_key_and_rejects_invalid_input(self):
        self.config.write_bytes(b'UNRELATED=value')
        bad = self.run_shell('project_version_set "$project/project.env" 01.0.7')
        self.assertNotEqual(bad.returncode, 0)
        self.assertEqual(self.config.read_bytes(), b'UNRELATED=value')
        result = self.run_shell('project_version_set "$project/project.env" 1.0.7')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_bytes(), b'UNRELATED=value\nPROJECT_VERSION=1.0.7\n')

    def test_cicd_cli_sets_version_before_dispatch_and_keeps_legacy_pair(self):
        self.config.write_text('OTHER=value\nPROJECT_VERSION=1.0.0\n')
        result = self.run_shell(r'''
source <(sed -n '/^manage_project_action() {/,/^}/p' "$1/root-install-debian.sh")
cicd_project() { printf 'CALL:%s:%s:%s:%s\n' "$1" "$2" "$3" "$(project_version_get "$project/project.env")"; }
manage_project_action cicd project 1.0.7
manage_project_action cicd project 'description' vcustom
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('CALL:project:1.0.7:v1.0.7:1.0.7', result.stdout)
        self.assertIn('CALL:project:description:vcustom:1.0.7', result.stdout)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.version-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.project = self.base / 'project'
        self.project.mkdir()
        self.config = self.project / 'project.env'

    def run_shell(self, script, **extra):
        prefix = r'''
set -Eeuo pipefail
source "$1/lib/project-version.sh"
print_error() { printf '%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf '%s\n' "$*"; }
print_title() { :; }
ENV_DEVOPS_PROJECTS_ROOT="$2"
ENV_DEVOPS_USER="$(id -un)"
DEVOPS_GROUP="$(id -gn)"
ENV_DEVOPS_USER="$ENV_DEVOPS_USER"
project="$2/project"
'''
        return subprocess.run(['bash', '-c', prefix + script, 'fixture', str(ROOT), str(self.base)],
                              env={**os.environ, **extra}, capture_output=True, text=True)

    def test_reader_absence_quotes_comments_and_isolation(self):
        result = self.run_shell('project_version_get "$project/project.env"')
        self.assertEqual((result.returncode, result.stdout), (0, ''))
        for value in ['1.0.0', '"1.0.0"', "'1.0.0' # public", '0.12.34']:
            self.config.write_text(f'OTHER=$(touch "{self.base}/executed")\nexport PROJECT_VERSION={value}\n')
            result = self.run_shell('project_version_get "$project/project.env"')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(result.stdout, ['1.0.0', '0.12.34'])
            self.assertFalse((self.base / 'executed').exists())
        self.config.write_text('OTHER=value\n')
        self.assertEqual(self.run_shell('project_version_get "$project/project.env"').stdout, '')

    def test_reader_refuses_present_invalid_and_duplicate_versions(self):
        for value in ['', '""', 'v1.0.0', '01.0.0', '1.0', '1.0.0-rc1',
                      '$(touch marker)', '1.0.0\nPROJECT_VERSION=2.0.0']:
            self.config.write_text('PROJECT_VERSION=' + value + '\n')
            result = self.run_shell('project_version_get "$project/project.env"')
            self.assertNotEqual(result.returncode, 0, value)
            self.assertEqual(result.stdout, '')
            self.assertIn('PROJECT_VERSION', result.stderr)

    def test_commit_parameter_selection_and_no_cross_project_leak(self):
        self.config.write_text('PROJECT_VERSION=1.0.0\n')
        result = self.run_shell('''
name=2026.11.02.15.33; tag=v2026.11.02.15.33
project_version_commit_parameters "$project" name tag
printf '%s|%s\n' "$name" "$tag"
name='Description explicite'; tag=v9
project_version_commit_parameters "$project" name tag
printf '%s|%s\n' "$name" "$tag"
name=legacy; tag=vlegacy
project_version_commit_parameters "$2/absent" name tag
printf '%s|%s' "$name" "$tag"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '1.0.0|v1.0.0\nDescription explicite|v1.0.0\nlegacy|vlegacy')

    def prepare_debian_sources(self):
        (self.project / 'lib').mkdir()
        (self.project / 'modules').mkdir()
        (self.project / 'config').mkdir()
        (self.project / 'config/hosts.json').write_text('[]\n')
        (self.project / 'root-install-debian.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
        (self.project / 'build').mkdir()
        recipe = json.loads((ROOT / 'build/debian-package.json').read_text())
        recipe['version'] = '9.9.9'
        (self.project / 'build/debian-package.json').write_text(json.dumps(recipe))

    def test_both_debian_builders_prioritize_config_over_recipe_and_git(self):
        self.prepare_debian_sources()
        self.config.write_text('PROJECT_DEBIAN_PACKAGE=Yes\nPROJECT_VERSION=1.0.0\n')
        (self.project / '.git').mkdir()
        for command in ['build_deb_diu project', 'projects_build_deb project']:
            result = self.run_shell('''
source "$1/modules/projects/diu-packaging.sh"
source "$1/modules/projects/debian-build.sh"
runuser() { printf 'unexpected git consultation\n' >&2; return 91; }
''' + command)
            self.assertEqual(result.returncode, 0, result.stderr)
            package = self.project / 'dist/diu_1.0.0_all.deb'
            self.assertTrue(package.exists())
            self.assertEqual(subprocess.check_output(['dpkg-deb', '-f', str(package), 'Version'], text=True).strip(), '1.0.0')
            self.assertFalse(list(self.project.glob('.debian-build.*')))
            self.assertFalse(list(self.project.glob('.diu-build.*')))

    def test_absent_config_keeps_recipe_and_invalid_config_preserves_dist(self):
        self.prepare_debian_sources()
        self.config.write_text('PROJECT_DEBIAN_PACKAGE=Yes\n')
        result = self.run_shell('source "$1/modules/projects/debian-build.sh"\nprojects_build_deb project')
        self.assertEqual(result.returncode, 0, result.stderr)
        old = self.project / 'dist/diu_9.9.9_all.deb'
        self.assertTrue(old.exists())
        original = old.read_bytes()
        self.config.write_text('PROJECT_DEBIAN_PACKAGE=Yes\nPROJECT_VERSION=bad\n')
        result = self.run_shell('source "$1/modules/projects/debian-build.sh"\nprojects_build_deb project')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(old.read_bytes(), original)

    def test_docker_build_adds_version_without_changing_build_arguments(self):
        fixture = docker_fixtures.DockerBuildArgs()
        fixture.setUp()
        self.addCleanup(fixture.doCleanups)
        config = fixture.project / 'project.env'
        config.write_text(config.read_text() + 'PROJECT_VERSION=1.0.0\n')
        result = fixture.run_build(b'PUBLIC_FLAG=literal\n')
        self.assertEqual(result.returncode, 0, result.stderr.decode())
        args = fixture.captured()
        self.assertIn(b'artifact-fixture:latest', args)
        self.assertIn(b'artifact-fixture:1.0.0', args)
        self.assertEqual(args[-3:], [b'--build-arg', b'PUBLIC_FLAG=literal', str(fixture.project).encode()])
        fixture.capture.unlink()
        config.write_text(config.read_text().replace('1.0.0', 'bad'))
        self.assertNotEqual(fixture.run_build().returncode, 0)
        self.assertFalse(fixture.capture.exists())

    def test_real_commit_version_and_collision_before_new_commit(self):
        self.config.write_text('PROJECT_ID=project\nPROJECT_NAME=Fixture\n'
                               'GIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\n'
                               'PROJECT_VERSION=1.0.0\n')
        (self.project / 'tracked.txt').write_text('first\n')
        script = r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git -C "$project" init -q
git_commit project 2026.11.02.15.33 v2026.11.02.15.33
git -C "$project" rev-parse HEAD refs/tags/v1.0.0^{}
git -C "$project" log -1 --format=%s
'''
        result = self.run_shell(script, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1], '1.0.0')
        hashes = result.stdout.splitlines()[-3:-1]
        self.assertEqual(hashes[0], hashes[1])
        head = hashes[0]
        (self.project / 'tracked.txt').write_text('second\n')
        result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git_commit project description vother
''', GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('existe déjà', result.stdout)
        self.assertEqual(subprocess.check_output(['git', '-C', str(self.project), 'rev-parse', 'HEAD'], text=True).strip(), head)

    def test_clean_tree_creates_new_version_tag_without_empty_commit(self):
        self.config.write_text('PROJECT_ID=project\nPROJECT_NAME=Fixture\n'
                               'GIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\n'
                               'PROJECT_VERSION=1.0.0\n')
        (self.project / 'tracked.txt').write_text('first\n')
        setup = r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git -C "$project" init -q
git_commit project 1.0.0 v1.0.0
'''
        env = {'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_NOSYSTEM': '1'}
        self.assertEqual(self.run_shell(setup, **env).returncode, 0)
        head = subprocess.check_output(['git', '-C', str(self.project), 'rev-parse', 'HEAD'], text=True).strip()
        self.config.write_text(self.config.read_text().replace('1.0.0', '1.0.1'))
        subprocess.run(['git', '-C', str(self.project), 'update-index', '--assume-unchanged', 'project.env'], check=True)
        result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git_commit project 1.0.1 v1.0.1
''', **env)
        self.assertEqual(result.returncode, 0, result.stderr)
        target = subprocess.check_output(['git', '-C', str(self.project), 'rev-parse', 'v1.0.1^{commit}'], text=True).strip()
        self.assertEqual(target, head)

    def test_clean_tree_with_version_tag_on_older_commit_is_informational(self):
        self.config.write_text('PROJECT_ID=project\nPROJECT_NAME=Fixture\n'
                               'GIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\n'
                               'PROJECT_VERSION=1.0.0\n')
        (self.project / 'tracked.txt').write_text('first\n')
        script = r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git -C "$project" init -q
git_commit project 1.0.0 v1.0.0
printf second > "$project/tracked.txt"
git -C "$project" add tracked.txt
git -C "$project" commit -qm later
git_commit project 1.0.0 v1.0.0
printf 'STATUS=%s\n' "$PROJECTS_GIT_COMMIT_STATUS"
'''
        result = self.run_shell(script, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('STATUS=version_deja_attribuee', result.stdout)
        self.assertIn('déjà attribué', result.stdout)

    def test_git_push_three_providers_selects_only_declared_tag(self):
        for provider in ['forgejo', 'gitlab', 'github']:
            with self.subTest(provider=provider):
                fixture = push_fixtures.ForgejoPushTests()
                fixture.setUp()
                self.addCleanup(fixture.doCleanups)
                fixture.git(fixture.project, 'tag', 'v1.0.0')
                config = fixture.project / 'project.env'
                extra = 'PROJECT_VERSION=1.0.0\n'
                url = push_fixtures.EXPECTED_URL
                if provider != 'forgejo':
                    url = f'https://{provider}.example.test/owner/project.git'
                    extra += (f'REMOTE_{provider.upper()}_BASE_URL=https://{provider}.example.test\n'
                              f'REMOTE_{provider.upper()}_OWNER=owner\nREMOTE_{provider.upper()}_REPOSITORY=project\n'
                              f'REMOTE_{provider.upper()}_NAME=origin\nREMOTE_{provider.upper()}_BRANCH=main\n'
                              f'REMOTE_{provider.upper()}_SSL_VERIFY=Yes\n')
                    fixture.git(fixture.project, 'remote', 'set-url', 'origin', url)
                config.write_text(config.read_text() + extra)
                transports = r'''
_github_ensure_credentials() { return 0; }
_gitlab_ensure_credentials() { return 0; }
github_remote_ensure() { return 0; }
github_repository_ensure() { return 0; }
github_git_fetch() { git -c "url.${TEST_REMOTE}.insteadOf=$EXPECTED_URL" -C "$1" fetch --prune "$2"; }
version_push_transport() {
    local path="$1"; shift
    printf 'PUSH:%s\n' "$*"
    git -c "url.${TEST_REMOTE}.insteadOf=$EXPECTED_URL" -C "$path" push "$@"
}
github_git_push() { version_push_transport "$@"; }
gitlab_git_push() { version_push_transport "$@"; }
'''
                harness = push_fixtures.HARNESS.replace('if [[ "$3" == helper ]]; then', transports + '\nif [[ "$3" == helper ]]; then')
                harness = harness.replace('    forgejo_push project', f'    {provider}_push project')
                result = subprocess.run(['bash', '-c', harness, 'fixture', str(ROOT), str(fixture.base), 'push'],
                                        env={**fixture.env, 'EXPECTED_URL': url}, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(fixture.git(fixture.remote, 'rev-parse', 'refs/heads/main').stdout.strip(), fixture.head)
                self.assertEqual(fixture.git(fixture.remote, 'rev-parse', 'refs/tags/v1.0.0').stdout.strip(), fixture.head)
                self.assertNotEqual(fixture.git(fixture.remote, 'show-ref', '--verify', 'refs/tags/v1.2.3', check=False).returncode, 0)
                if provider == 'gitlab':
                    self.assertNotIn('--force', result.stdout)

    def test_push_missing_or_wrong_tag_stops_before_transport(self):
        self.config.write_text('PROJECT_VERSION=1.0.0\n')
        for provider in ['forgejo', 'gitlab', 'github']:
            for wrong in ['missing', 'wrong']:
                result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
check_devops_user() { return 0; }
runuser() {
    case "$*" in
        *'rev-parse --verify HEAD') printf 'head-sha' ;;
        *'refs/tags/v1.0.0'*) [[ "$WRONG" != missing ]] || return 1; printf 'other-sha' ;;
        *) printf 'UNEXPECTED TRANSPORT\n'; return 93 ;;
    esac
}
''' + provider + '_push project\n', WRONG=wrong)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('UNEXPECTED TRANSPORT', result.stdout)
                self.assertIn('doit exister et désigner HEAD', result.stderr)

    def release_config(self):
        text = 'PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_TYPE=application\nPROJECT_DOCKERED=Yes\nPROJECT_DEBIAN_PACKAGE=Yes\nPROJECT_VERSION=1.0.0\n'
        for provider in ['FORGEJO', 'GITLAB', 'GITHUB']:
            text += (f'REMOTE_{provider}_BASE_URL=https://{provider.lower()}.example.test\n'
                     f'REMOTE_{provider}_OWNER=owner\nREMOTE_{provider}_REPOSITORY=project\n'
                     f'REMOTE_{provider}_NAME=origin\nREMOTE_{provider}_BRANCH=main\n'
                     f'REMOTE_{provider}_SSL_VERIFY=Yes\n')
        self.config.write_text(text + 'REMOTE_GITLAB_REGISTRY=gitlab.example.test:5050\n')

    def run_docker_release(self, provider, **extra):
        return self.run_shell(r'''
source "$1/modules/projects/git.sh"
docker() {
    printf '%s\n' "$*" >> "$project/docker.log"
    if [[ "$*" == 'image inspect project:1.0.0' && "${IMAGE_MISSING:-}" == yes ]]; then return 1; fi
    if [[ "${1:-}" == login ]]; then cat >/dev/null; fi
    return 0
}
git() {
    case "$*" in
        *'rev-parse --verify HEAD'|*'refs/tags/v1.0.0'*) printf 'same-sha' ;;
        *'rev-parse --is-inside-work-tree'*) printf 'true' ;;
        *'tag --points-at HEAD'*) printf 'v9.9.9\nv8.8.8\n' ;;
    esac
    return 0
}
runuser() {
    shift 3
    if [[ "${1:-}" == env && "${2:-}" == -u ]]; then shift 3; fi
    if [[ "${1:-}" == env && "${2:-}" == DOCKER_CONFIG=* ]]; then shift 2; fi
    "$@"
}
curl() { printf 'API\n' >> "$project/api.log"; printf '200'; }
_forgejo_read_username() { forgejo_username=fixture; }
_forgejo_read_token() { forgejo_token=fixture-token; }
_gitlab_read_username() { gitlab_username=fixture; }
_gitlab_read_token() { gitlab_token=fixture-token; }
_github_read_username() { github_username=fixture; }
_github_read_token() { github_token=fixture-token; }
_github_ensure_credentials() { return 0; }
_gitlab_ensure_credentials() { return 0; }
''' + {'forgejo': 'projects_forgejo_release_docker', 'gitlab': 'projects_gitlab_release_docker',
       'github': 'projects_github_release_docker', 'gitlab-debian': 'projects_gitlab_release_debian'}[provider] + ' project\n', TMPDIR=str(self.base), **extra)

    def test_docker_releases_use_versioned_source_for_three_providers(self):
        self.release_config()
        for provider in ['forgejo', 'gitlab', 'github']:
            with self.subTest(provider=provider):
                result = self.run_docker_release(provider)
                self.assertEqual(result.returncode, 0, result.stderr)
                log = (self.project / 'docker.log').read_text()
                self.assertIn('tag project:1.0.0 ', log)
                self.assertNotIn('tag project:latest ', log)
                self.assertIn(':1.0.0', log)
                self.assertNotIn(':9.9.9', log)
                (self.project / 'docker.log').unlink()

    def test_docker_releases_refuse_missing_versioned_image(self):
        self.release_config()
        for provider in ['forgejo', 'gitlab', 'github']:
            result = self.run_docker_release(provider, IMAGE_MISSING='yes')
            self.assertNotEqual(result.returncode, 0)
            log = (self.project / 'docker.log').read_text()
            self.assertNotIn('push ', log)
            self.assertNotIn('tag ', log)
            (self.project / 'docker.log').unlink()

    def test_grouped_commits_resolve_each_project_version(self):
        second = self.base / 'second'
        second.mkdir()
        common = 'PROJECT_NAME=Fixture\nGIT_USER_NAME=Fixture\nGIT_USER_EMAIL=fixture@example.test\n'
        self.config.write_text('PROJECT_ID=project\nPROJECT_VERSION=1.0.0\n' + common)
        (second / 'project.env').write_text('PROJECT_ID=second\nPROJECT_VERSION=2.0.0\n' + common)
        result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
runuser() { shift 3; "$@"; }
check_devops_user() { return 0; }
git -C "$project" init -q
git -C "$2/second" init -q
git_commit_all 2026.11.02.15.33 v2026.11.02.15.33
git -C "$project" tag --points-at HEAD
git -C "$2/second" tag --points-at HEAD
''', GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines()[-2:], ['v1.0.0', 'v2.0.0'])

    def test_cicd_summaries_prioritize_version_over_other_head_tags(self):
        self.config.write_text('PROJECT_ID=project\nPROJECT_NAME=Fixture\nPROJECT_TYPE=application\n'
                               'PROJECT_DOCKERED=No\nPROJECT_VERSION=1.0.0\n')
        result = self.run_shell(r'''
source "$1/modules/projects/git.sh"
git_commit() { printf 'COMMIT:%s|%s|%s\n' "$1" "$2" "$3"; }
runuser() { if [[ "$*" == *'show-ref --verify --quiet'* ]]; then return 1; fi; printf 'v9.9.9\n'; }
cicd_project project 2026.11.02.15.33 v2026.11.02.15.33
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('COMMIT:project|1.0.0|v1.0.0', result.stdout)
        self.assertNotIn('v9.9.9', result.stdout)

    def test_debian_release_checks_declared_version_and_tag(self):
        self.config.write_text('PROJECT_VERSION=1.0.0\n')
        prefix = r'''
source "$1/modules/projects/diu-packaging.sh"
runuser() {
    case "$*" in
        *'rev-parse --verify HEAD'|*'refs/tags/v1.0.0'*) printf 'same-sha' ;;
        *) return 92 ;;
    esac
}
'''
        result = self.run_shell(prefix + 'diu_release_version_matches "$project" 1.0.0\n')
        self.assertEqual((result.returncode, result.stdout), (0, '1.0.0'), result.stderr)
        result = self.run_shell(prefix + 'diu_release_version_matches "$project" 9.9.9\n')
        self.assertNotEqual(result.returncode, 0)

    def test_gitlab_debian_refuses_mismatched_artifact_before_api(self):
        self.prepare_debian_sources()
        self.config.write_text('PROJECT_DEBIAN_PACKAGE=Yes\n')
        result = self.run_shell('source "$1/modules/projects/debian-build.sh"\nprojects_build_deb project')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.release_config()
        result = self.run_docker_release('gitlab-debian')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('ne correspond pas à PROJECT_VERSION', result.stderr)
        self.assertFalse((self.project / 'api.log').exists())

    def test_help_covers_version_before_bootstrap(self):
        commands = [('projects',), ('projects', 'git', 'commit'), ('projects', 'cicd'),
                    ('projects', 'cicddiu'), ('projects', 'cicddr'),
                    ('projects', 'docker', 'build'), ('projects', 'build', 'deb'),
                    ('projects', 'deb'), ('projects', 'forgejo', 'push'),
                    ('projects', 'github', 'push'), ('projects', 'gitlab', 'push')]
        for command in commands:
            result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *command, 'help'],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, (command, result.stderr))
            if len(command) == 3 and command[1] in ('forgejo', 'github', 'gitlab') and command[2] == 'push':
                self.assertIn('PROJECT_VERSION reste inchangée', result.stdout)
                self.assertIn('horodatage si absente', result.stdout)
            else:
                self.assertIn('PROJECT_VERSION=x.y.z', result.stdout)
            self.assertNotIn('variables.sh', result.stderr)


if __name__ == '__main__':
    unittest.main()
