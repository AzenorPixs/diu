"""Construction Debian sur sources fictives et routage sans bootstrap hôte."""
from pathlib import Path
import os
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/diu-packaging.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf '%s\n' "$*"; }
DEVOPS_USER="$(id -un)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() {
    [[ "${GIT_FAIL:-}" != yes ]] || return 71
    printf '%s' "${TAGS:-}"
}
if [[ "${BUILD_FAIL:-}" == yes ]]; then
    dpkg-deb() { [[ "${1:-}" != --build ]] || return 72; command dpkg-deb "$@"; }
fi
if [[ "${PUBLISH_FAIL:-}" == yes ]]; then
    mv() { return 73; }
fi
shift 2
"$@"
'''

class DiuPackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.packaging-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.projects = self.base/'projects with spaces'
        self.projects.mkdir()
        self.project = self.projects/'source'
        self.project.mkdir()
        (self.project/'lib').mkdir()
        (self.project/'modules').mkdir()
        (self.project/'root-install-debian.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
        (self.project/'lib/fixture.sh').write_text('# fixture\n')
        self.scratch = self.base/'scratch'
        self.scratch.mkdir()

    def run_action(self, *args, harness=HARNESS, **settings):
        result = subprocess.run(
            ['bash', '-c', harness, 'fixture', str(ROOT), str(self.projects), *args],
            capture_output=True, text=True, check=False,
            env={**os.environ, 'TMPDIR': str(self.scratch), **settings})
        self.assertEqual(list(self.scratch.iterdir()), [])
        self.assertEqual(list(self.project.glob('.diu-build.*')), [])
        return result

    def tag_metadata(self):
        (self.project/'.git').mkdir(exist_ok=True)

    def old_package(self):
        dist = self.project/'dist'
        dist.mkdir(exist_ok=True)
        old = dist/'diu_0.1_all.deb'
        old.write_bytes(b'previous-valid-fixture')
        (dist/'keep.txt').write_text('keep')
        return old

    def test_real_build_without_deb_cache_and_inspection(self):
        self.scratch.chmod(0o2775)
        result = self.run_action('build_deb_diu', 'source')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.project/'deb').exists())
        packages = list((self.project/'dist').glob('diu_*_all.deb'))
        self.assertEqual(len(packages), 1)
        fields = subprocess.check_output(['dpkg-deb', '-f', str(packages[0]), 'Package', 'Version', 'Architecture'], text=True)
        self.assertIn('diu', fields)
        self.assertIn('all', fields)
        self.assertRegex(fields, r'\d{4}\.\d{2}\.\d{2}\.\d{2}\.\d{2}')
        content = subprocess.check_output(['dpkg-deb', '-c', str(packages[0])], text=True)
        self.assertIn('./root/diu/root-install-debian.sh', content)
        self.assertIn('./root/diu/lib/fixture.sh', content)
        for excluded in ('variables.sh', 'project.env', '/config/', '/deb/', '/.git/'):
            self.assertNotIn(excluded, content)

    def test_tag_version_and_rotation_preserve_other_files(self):
        self.tag_metadata()
        old = self.old_package()
        result = self.run_action('build_deb_diu', 'source', TAGS='v1.2.3\n1.2.3\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(old.exists())
        self.assertTrue((self.project/'dist/diu_1.2.3_all.deb').exists())
        self.assertEqual((self.project/'dist/keep.txt').read_text(), 'keep')

    def test_ambiguous_invalid_and_failed_git_queries_preserve_dist(self):
        self.tag_metadata()
        for settings in ({'TAGS': 'v1.0\nv2.0\n'}, {'TAGS': 'invalid-tag\n'}, {'GIT_FAIL': 'yes'}):
            old = self.old_package()
            result = self.run_action('build_deb_diu', 'source', **settings)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(old.read_bytes(), b'previous-valid-fixture')

    def test_build_and_publication_errors_preserve_previous_package(self):
        for settings in ({'BUILD_FAIL': 'yes'}, {'PUBLISH_FAIL': 'yes'}):
            old = self.old_package()
            result = self.run_action('build_deb_diu', 'source', **settings)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(old.read_bytes(), b'previous-valid-fixture')

    def test_default_project_and_missing_or_invalid_sources(self):
        result = self.run_action('build_deb_diu')
        self.assertNotEqual(result.returncode, 0)
        self.project.rename(self.projects/'diu')
        self.project = self.projects/'diu'
        result = self.run_action('build_deb_diu')
        self.assertEqual(result.returncode, 0, result.stderr)
        for target in ('../diu', '', '.', 'missing'):
            result = self.run_action('build_deb_diu', target)
            self.assertNotEqual(result.returncode, 0)

    def test_symbolic_project_and_missing_required_content(self):
        (self.projects/'alias').symlink_to(self.project, target_is_directory=True)
        self.assertNotEqual(self.run_action('build_deb_diu', 'alias').returncode, 0)
        (self.project/'root-install-debian.sh').unlink()
        self.assertNotEqual(self.run_action('build_deb_diu', 'source').returncode, 0)

    def test_no_tags_falls_back_and_release_keeps_package_version(self):
        self.tag_metadata()
        result = self.run_action('build_deb_diu', 'source', TAGS='')
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.run_action('diu_release_version_matches', str(self.project), '1.4')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '')

    def test_release_refuses_tag_mismatch_and_ambiguity(self):
        self.tag_metadata()
        for tags in ('v2.0\n', 'v1.0\nv2.0\n'):
            result = self.run_action('diu_release_version_matches', str(self.project), '1.0', TAGS=tags)
            self.assertNotEqual(result.returncode, 0)

    def test_version_selection_with_real_local_git(self):
        environment = {**os.environ, 'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': '/dev/null'}
        for arguments in (['init', '-q'],
                          ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.test',
                           'commit', '--allow-empty', '-qm', 'fixture'],
                          ['tag', 'v3.2']):
            subprocess.run(['git', '-C', str(self.project), *arguments],
                           env=environment, check=True, capture_output=True)
        harness = re.sub(r'^runuser\(\) \{.*?^\}',
                         'runuser() { shift 2; [[ "${1:-}" != -- ]] || shift; "$@"; }',
                         HARNESS, flags=re.M|re.S)
        result = self.run_action('diu_package_version_from_head', str(self.project), harness=harness,
                                 GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL='/dev/null')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '3.2')

    def test_help_alias_and_invalid_arguments_before_bootstrap(self):
        for args in [('projects', 'deb', 'help'), ('proj', 'deb', 'source', '?')]:
            result = subprocess.run(['bash', str(ROOT/'root-install-debian.sh'), *args],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('défaut', result.stdout)
        for args in [('proj', 'deb'), ('projects', 'deb', '../source'), ('projects', 'deb', 'a', 'b')]:
            result = subprocess.run(['bash', str(ROOT/'root-install-debian.sh'), *args],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 2)
            self.assertNotIn('variables.sh', result.stderr)

    def test_dispatch_transmits_source_and_preserves_default(self):
        entry = (ROOT/'root-install-debian.sh').read_text()
        function = re.search(r'^manage_project_action\(\) \{\n.*?^\}\n', entry, re.M|re.S).group()
        script = function + '\nbuild_deb_diu() { printf "SOURCE:%s" "$1"; }\nmanage_project_action deb "$1"\n'
        result = subprocess.run(['bash', '-c', script, 'fixture', 'source'],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.stdout, 'SOURCE:source')
        result = subprocess.run(['bash', '-c', script, 'fixture', ''],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.stdout, 'SOURCE:diu')

if __name__ == '__main__':
    unittest.main()

