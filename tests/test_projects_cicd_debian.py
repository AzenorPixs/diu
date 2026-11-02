"""Six étapes CI/CD sur fixtures, sans réseau ni installation."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/git.sh"
source "$1/modules/projects/debian-build.sh"
DEVOPS_PROJECTS_ROOT="$2"
DEVOPS_USER=fixture
print_title() { printf 'TITLE:%s\n' "$*"; }
print_error() { printf 'ERROR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf '%s\n' "$*"; }
runuser() { printf 'UNEXPECTED RUNUSER\n' >&2; return 92; }
git_commit() {
    printf 'OP:commit:%s:%s:%s\n' "$1" "$2" "$3"
    [[ "${FAIL_OPERATION:-}" != commit ]]
}
fixture_push() {
    printf 'OP:push_%s\n' "$1"
    [[ "${FAIL_OPERATION:-}" != "push_$1" ]] || return 57
    if [[ "${UNAVAILABLE_PROVIDER:-}" == "$1" ]]; then PROJECTS_GIT_PUSH_STATUS=indisponible; fi
}
forgejo_push() { fixture_push forgejo; }
gitlab_push() { fixture_push gitlab; }
github_push() { fixture_push github; }
projects_docker_build() { printf 'OP:docker:%s\n' "$1"; [[ "${FAIL_OPERATION:-}" != docker ]]; }
if [[ "${REAL_BUILD:-}" != yes ]]; then
    projects_build_deb() { printf 'OP:debian:%s\n' "$1"; [[ "${FAIL_OPERATION:-}" != debian ]]; }
fi
fixture_release() {
    if [[ "${REAL_BUILD:-}" == yes && "$1" == *_debian ]]; then
        [[ -f "$DEVOPS_PROJECTS_ROOT/$2/dist/project_2.3.4_all.deb" ]] || return 91
    fi
    printf 'OP:%s:%s\n' "$1" "$2"
    [[ "${FAIL_OPERATION:-}" != "$1" ]]
}
projects_forgejo_release() { fixture_release forgejo_release "$1"; }
projects_gitlab_release() { fixture_release gitlab_release "$1"; }
projects_github_release() { fixture_release github_release "$1"; }
publish_release_debian() { fixture_release forgejo_debian "$1"; }
projects_gitlab_release_debian() { fixture_release gitlab_debian "$1"; }
cicd_project project 2026.11.02.15.33 v2026.11.02.15.33
'''


class CicdDebianTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.cicd-debian-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.project = self.base / 'project'
        (self.project / 'build').mkdir(parents=True)
        (self.project / 'payload').mkdir()
        (self.project / 'payload/app').write_text('fixture\n')
        self.recipe = self.project / 'build/debian-package.json'
        self.recipe.write_text(json.dumps({
            'package': 'project', 'architecture': 'all',
            'maintainer': 'Fixture <fixture@example.test>', 'description': 'Fixture CI/CD',
            'files': [{'source': 'payload', 'destination': '/opt/project'}],
        }))
        self.config()

    def config(self, docker='No', debian='Yes', providers=('forgejo', 'gitlab', 'github'), project=None):
        path = project or self.project
        text = f'PROJECT_ID={path.name}\nPROJECT_NAME=Fixture\nPROJECT_TYPE=application\nPROJECT_VERSION=2.3.4\n'
        if docker is not None:
            text += f'PROJECT_DOCKERED="{docker}"\n'
        if debian is not None:
            text += f'PROJECT_DEBIAN_PACKAGE="{debian}"\n'
        for provider in providers:
            prefix = f'REMOTE_{provider.upper()}'
            text += (f'{prefix}_BASE_URL=https://{provider}.example.test\n'
                     f'{prefix}_OWNER=owner\n{prefix}_REPOSITORY={path.name}\n'
                     f'{prefix}_NAME={provider}\n{prefix}_BRANCH=main\n{prefix}_SSL_VERIFY=Yes\n')
            if provider == 'gitlab':
                text += 'REMOTE_GITLAB_REGISTRY=registry.example.test\n'
        (path / 'project.env').write_text(text)

    def run_flow(self, harness=HARNESS, **settings):
        result = subprocess.run(['bash', '-c', harness, 'fixture', str(ROOT), str(self.base)],
                                capture_output=True, text=True,
                                env={**os.environ, 'TMPDIR': str(self.base), **settings})
        self.assertFalse(list(self.project.glob('.debian-build.*')))
        return result

    @staticmethod
    def operations(result):
        return [line.split(':')[1] for line in result.stdout.splitlines() if line.startswith('OP:')]

    def test_debian_only_uses_supported_publications_and_six_steps(self):
        result = self.run_flow()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.operations(result), ['commit', 'push_forgejo', 'push_gitlab', 'push_github',
                                                 'debian', 'forgejo_debian', 'gitlab_debian'])
        for number in range(1, 7):
            self.assertEqual(result.stdout.count(f'TITLE:Étape {number}/6'), 1)
        self.assertIn('OP:commit:project:2.3.4:v2.3.4', result.stdout)
        self.assertIn('Paquet Debian\n  Build   : construit dans ', result.stdout)
        self.assertIn('publication Debian non prise en charge', result.stdout)

    def test_mixed_order_builds_both_before_parent_publications(self):
        self.config(docker='Yes')
        result = self.run_flow()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.operations(result), ['commit', 'push_forgejo', 'push_gitlab', 'push_github',
                                                 'docker', 'debian', 'forgejo_release', 'gitlab_release', 'github_release'])
        self.assertIn('paquet Debian publié', result.stdout)

    def test_three_active_values_and_docker_semantics_are_preserved(self):
        for value in ['Yes', 'YES', '1']:
            for docker in ['No', 'YES', '1']:
                with self.subTest(value=value, docker=docker):
                    self.config(docker=docker, debian=value)
                    result = self.run_flow()
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(self.operations(result).count('debian'), 1)
                    self.assertNotIn('docker', self.operations(result))
                    self.assertIn('forgejo_debian', self.operations(result))
                    self.assertNotIn('github_release', self.operations(result))

    def test_inactive_values_do_not_call_builder_or_publications(self):
        self.recipe.unlink()
        for value in [None, '', 'No', 'NO', '0', 'yes', 'true']:
            with self.subTest(value=value):
                self.config(debian=value)
                result = self.run_flow()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.operations(result), ['commit', 'push_forgejo', 'push_gitlab', 'push_github'])
                self.assertIn('Paquet Debian\n  Build   : non activé, ignoré', result.stdout)

    def test_docker_only_keeps_eight_historical_operations(self):
        self.config(docker='Yes', debian='No')
        result = self.run_flow()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.operations(result), ['commit', 'push_forgejo', 'push_gitlab', 'push_github',
                                                 'docker', 'forgejo_release', 'gitlab_release', 'github_release'])

    def test_failed_debian_build_stops_all_publications_with_summary(self):
        self.config(docker='Yes')
        result = self.run_flow(FAIL_OPERATION='debian')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.operations(result)[-2:], ['docker', 'debian'])
        self.assertFalse(any('release' in op for op in self.operations(result)))
        self.assertIn('État global : échec', result.stdout)
        self.assertIn('Paquet Debian\n  Build   : échec', result.stdout)
        self.assertIn('Étape 6/6', result.stdout)
        self.assertNotIn('Étape 5/6', result.stdout)

    def test_failed_docker_build_stops_before_debian(self):
        self.config(docker='Yes')
        result = self.run_flow(FAIL_OPERATION='docker')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('debian', self.operations(result))
        self.assertIn('Paquet Debian\n  Build   : non exécuté', result.stdout)

    def test_commit_and_push_failures_stop_remaining_steps(self):
        for failure in ['commit', 'push_forgejo']:
            with self.subTest(failure=failure):
                result = self.run_flow(FAIL_OPERATION=failure)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('debian', self.operations(result))
                self.assertIn('État global : échec', result.stdout)

    def test_unavailability_keeps_builds_and_skips_only_affected_release(self):
        for docker in ['No', 'Yes']:
            for provider in ['forgejo', 'gitlab', 'github']:
                self.config(docker=docker)
                result = self.run_flow(UNAVAILABLE_PROVIDER=provider)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('debian', self.operations(result))
                self.assertIn('État global : terminé avec indisponibilités', result.stdout)
                self.assertNotIn(f'{provider}_release', self.operations(result))
                self.assertNotIn(f'{provider}_debian', self.operations(result))
                self.assertEqual(result.stderr, '')

    def test_no_provider_configuration_keeps_local_debian_build(self):
        self.config(providers=())
        result = self.run_flow()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.operations(result), ['commit', 'debian'])

    def test_debian_flag_does_not_leak_to_next_project(self):
        self.config(providers=())
        second = self.base / 'second'
        second.mkdir()
        self.config(project=second, providers=(), debian=None)
        harness = HARNESS + '\ncicd_project second 2026.11.02.15.33 v2026.11.02.15.33\n'
        result = self.run_flow(harness=harness)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.operations(result), ['commit', 'debian', 'commit'])

    def test_real_package_is_built_before_debian_publication(self):
        result = self.run_flow(REAL_BUILD='yes')
        self.assertEqual(result.returncode, 0, result.stderr)
        package = self.project / 'dist/project_2.3.4_all.deb'
        self.assertTrue(package.exists())
        metadata = subprocess.check_output(['dpkg-deb', '-f', str(package), 'Version'], text=True)
        self.assertEqual(metadata.strip(), '2.3.4')
        self.assertIn('forgejo_debian', self.operations(result))
        self.assertIn('gitlab_debian', self.operations(result))

    def test_missing_recipe_preserves_old_package_and_blocks_release(self):
        self.recipe.unlink()
        dist = self.project / 'dist'
        dist.mkdir()
        old = dist / 'project_0.1_all.deb'
        old.write_bytes(b'old-fixture')
        result = self.run_flow(REAL_BUILD='yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Fichier de build Debian absent', result.stderr)
        self.assertEqual(old.read_bytes(), b'old-fixture')
        self.assertFalse(any('debian' in op for op in self.operations(result)))

    def test_debian_release_failure_stops_next_provider(self):
        result = self.run_flow(FAIL_OPERATION='forgejo_debian')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('gitlab_debian', self.operations(result))
        self.assertIn('Paquet Debian\n  Build   : construit dans ', result.stdout)

    def test_help_explains_six_steps_without_bootstrap(self):
        for suffix in [('projects', 'cicd'), ('projects', 'cicd', 'diu')]:
            for word in ['help', '?']:
                result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *suffix, word],
                                        text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('4. Build Debian', result.stdout)
                self.assertIn('5. Publications', result.stdout)
                self.assertIn('6. Bilan', result.stdout)
                self.assertIn('PROJECT_DEBIAN_PACKAGE=Yes/YES/1', result.stdout)
                self.assertNotIn('variables.sh', result.stderr)


if __name__ == '__main__':
    unittest.main()
