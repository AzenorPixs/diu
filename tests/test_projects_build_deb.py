"""Paquets réels sur fixtures locales, sans bootstrap ni publication."""
import json
import io
import os
from pathlib import Path
import re
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
set -Eeuo pipefail
source "$1/modules/projects/diu-packaging.sh"
source "$1/modules/projects/debian-build.sh"
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf '%s\n' "$*"; }
ENV_DEVOPS_USER=fixture
ENV_DEVOPS_PROJECTS_ROOT="$2"
runuser() { [[ "${GIT_FAIL:-}" != yes ]] || return 71; printf '%s' "${TAGS-v1.2.3}"; }
date() { printf '2026.11.02.12.00\n'; }
if [[ "${BUILD_FAIL:-}" == yes ]]; then
    dpkg-deb() { [[ "${1:-}" != --build ]] || return 72; command dpkg-deb "$@"; }
fi
if [[ "${MOVE_FAIL:-}" == yes ]]; then mv() { return 73; }; fi
shift 2
"$@"
'''


class ProjectsBuildDebTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT, prefix='.debian-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.projects = self.base / 'projects with spaces'
        self.project = self.projects / 'example'
        (self.project / 'build').mkdir(parents=True)
        (self.project / 'payload').mkdir()
        (self.project / 'payload/file with spaces').write_text('working tree payload\n')
        (self.project / 'project.env').write_text('PROJECT_DEBIAN_PACKAGE=Yes\n')
        self.scratch = self.base / 'scratch'
        self.scratch.mkdir()
        self.recipe = {
            'package': 'example-package', 'architecture': 'amd64',
            'maintainer': 'Fixture <fixture@example.test>', 'description': 'Fixture générique',
            'depends': ['awk'], 'version': '2.3',
            'files': [{'source': 'payload', 'destination': '/opt/example'}],
        }
        self.save_recipe()

    def save_recipe(self):
        (self.project / 'build/debian-package.json').write_text(json.dumps(self.recipe))

    def run_build(self, *args, action='projects_build_deb', **settings):
        result = subprocess.run(
            ['bash', '-c', HARNESS, 'fixture', str(ROOT), str(self.projects), action,
             *(args or ('example',))], text=True, capture_output=True, check=False,
            env={**os.environ, 'TMPDIR': str(self.scratch), **settings})
        self.assertEqual(list(self.scratch.iterdir()), [])
        self.assertEqual(list(self.project.glob('.debian-build.*')), [])
        return result

    def archive_manifest(self, package):
        data = subprocess.check_output(['dpkg-deb', '--fsys-tarfile', str(package)])
        archive = self.base / 'data.tar'
        archive.write_bytes(data)
        with tarfile.open(archive) as tar:
            return {m.name: (m.mode, m.uid, m.gid,
                            tar.extractfile(m).read() if m.isfile() else None)
                    for m in tar.getmembers()}

    def test_generic_package_and_rotation(self):
        dist = self.project / 'dist'
        dist.mkdir()
        for name in ['example-package_0.1_amd64.deb', 'example-package_0.1_all.deb',
                     'other_0.1_amd64.deb', 'keep.txt']:
            (dist / name).write_text('keep')
        result = self.run_build()
        self.assertEqual(result.returncode, 0, result.stderr)
        package = dist / 'example-package_2.3_amd64.deb'
        self.assertTrue(package.exists())
        self.assertFalse((dist / 'example-package_0.1_amd64.deb').exists())
        for name in ['example-package_0.1_all.deb', 'other_0.1_amd64.deb', 'keep.txt']:
            self.assertEqual((dist / name).read_text(), 'keep')
        manifest = self.archive_manifest(package)
        self.assertEqual(manifest['./opt/example/file with spaces'][3], b'working tree payload\n')
        self.assertFalse(any('debian-package.json' in p for p in manifest))
        self.assertTrue(all(entry[1:3] == (0, 0) for entry in manifest.values()))

    def test_explicit_file_mode_and_invalid_modes(self):
        source = self.project / 'payload/file with spaces'
        source.chmod(0o644)
        self.recipe['files'] = [{'source': 'payload/file with spaces',
                                 'destination': '/usr/bin/example', 'mode': '0755'}]
        self.save_recipe()
        result = self.run_build()
        self.assertEqual(result.returncode, 0, result.stderr)
        package = self.project / 'dist/example-package_2.3_amd64.deb'
        manifest = self.archive_manifest(package)
        self.assertEqual(manifest['./usr/bin/example'][0], 0o755)
        self.assertEqual(source.stat().st_mode & 0o777, 0o644)
        original = package.read_bytes()
        for mode in ['755', '1755', '0788', '0755\n', '', 755, None]:
            with self.subTest(mode=mode):
                self.recipe['files'][0]['mode'] = mode
                self.save_recipe()
                self.assertNotEqual(self.run_build().returncode, 0)
                self.assertEqual(package.read_bytes(), original)
        self.recipe['files'] = [{'source': 'payload', 'destination': '/opt/example',
                                 'mode': '0755'}]
        self.save_recipe()
        self.assertNotEqual(self.run_build().returncode, 0)
        self.assertEqual(package.read_bytes(), original)

    def test_diu_recipe_installs_executable_from_nonexecutable_source(self):
        self.recipe = json.loads((ROOT / 'build/debian-package.json').read_text())
        self.save_recipe()
        (self.project / 'root-install-debian.sh').write_text('#!/bin/sh\n')
        (self.project / 'root-install-debian.sh').chmod(0o644)
        for directory in ['lib', 'modules', 'config']:
            (self.project / directory).mkdir()
        (self.project / 'config/hosts.json').write_text('[]\n')
        result = self.run_build()
        self.assertEqual(result.returncode, 0, result.stderr)
        package = self.project / 'dist/diu_2026.11.02.12.00_all.deb'
        self.assertEqual(self.archive_manifest(package)['./root/diu/root-install-debian.sh'][0], 0o755)
        self.assertEqual((self.project / 'root-install-debian.sh').stat().st_mode & 0o777, 0o644)

    def test_activation_exact_values_and_nonexecution(self):
        for value in ['Yes', 'YES', '1', '"Yes"', "'YES'"]:
            with self.subTest(value=value):
                (self.project / 'project.env').write_text(
                    f'UNRELATED=$(touch "{self.base}/executed")\nPROJECT_DEBIAN_PACKAGE={value}\n')
                result = self.run_build()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('Paquet construit', result.stdout)
                self.assertFalse((self.base / 'executed').exists())

    def test_disabled_before_recipe_or_tool_checks(self):
        (self.project / 'build/debian-package.json').unlink()
        for value in ['', 'No', 'NO', '0', 'yes', 'true', 'Anything']:
            (self.project / 'project.env').write_text(f'PROJECT_DEBIAN_PACKAGE={value}\n')
            result = self.run_build()
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('ne produit aucun paquet Debian', result.stdout)
        (self.project / 'project.env').unlink()
        self.assertEqual(self.run_build().returncode, 0)
        self.assertFalse((self.project / 'dist').exists())

    def test_missing_or_invalid_recipe_preserves_artifacts(self):
        dist = self.project / 'dist'
        dist.mkdir()
        previous = dist / 'example-package_0.1_amd64.deb'
        previous.write_bytes(b'old')
        path = self.project / 'build/debian-package.json'
        path.unlink()
        result = self.run_build()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('absent', result.stderr)
        self.assertIn('ne peut pas être construit', result.stderr)
        for content in ['{', '{"package":"bad"}', json.dumps({**self.recipe, 'description': 'injection\nVersion: 9'})]:
            path.write_text(content)
            self.assertNotEqual(self.run_build().returncode, 0)
            self.assertEqual(previous.read_bytes(), b'old')

    def test_ambiguous_activation_is_error_without_execution(self):
        for text in ['PROJECT_DEBIAN_PACKAGE=Yes\nPROJECT_DEBIAN_PACKAGE=No\n',
                     'PROJECT_DEBIAN_PACKAGE=$(touch marker)\n']:
            (self.project / 'project.env').write_text(text)
            self.assertNotEqual(self.run_build().returncode, 0)

    def test_paths_recipe_and_private_sources_are_refused(self):
        for source, destination in [('../payload', '/opt/app'), ('payload', '/../../tmp/app'),
                                    ('payload', '/DEBIAN/control'), ('payload', '/'),
                                    ('build', '/opt/build'), ('missing', '/opt/app')]:
            with self.subTest(source=source, destination=destination):
                self.recipe['files'] = [{'source': source, 'destination': destination}]
                self.save_recipe()
                self.assertNotEqual(self.run_build().returncode, 0)
        self.recipe['files'] = [{'source': 'payload', 'destination': '/opt/app'}]
        self.save_recipe()
        for name in ['private.env', 'credentials.json', 'debug.log', 'id_rsa', 'private.key']:
            p = self.project / 'payload' / name
            p.write_text('fixture')
            self.assertNotEqual(self.run_build().returncode, 0)
            p.unlink()
        (self.project / 'payload/link').symlink_to(self.base)
        self.assertNotEqual(self.run_build().returncode, 0)

    def test_overlap_and_symbolic_paths(self):
        self.recipe['files'].append({'source': 'payload/file with spaces', 'destination': '/opt/example/file'})
        self.save_recipe()
        self.assertNotEqual(self.run_build().returncode, 0)
        self.recipe['files'].pop()
        self.save_recipe()
        (self.project / 'dist').symlink_to(self.scratch)
        self.assertNotEqual(self.run_build().returncode, 0)
        (self.project / 'dist').unlink()
        (self.projects / 'alias').symlink_to(self.project)
        self.assertNotEqual(self.run_build('alias').returncode, 0)

    def test_versions_and_git_failures(self):
        self.recipe.pop('version')
        self.save_recipe()
        (self.project / '.git').mkdir()
        for settings in [{'TAGS': 'v3.4\n3.4'}, {'TAGS': ''}]:
            result = self.run_build(**settings)
            self.assertEqual(result.returncode, 0, result.stderr)
            version = '3.4' if settings['TAGS'] else '2026.11.02.12.00'
            self.assertTrue((self.project / f'dist/example-package_{version}_amd64.deb').exists())
        for settings in [{'TAGS': 'v1.0\nv2.0'}, {'TAGS': 'invalid'}, {'GIT_FAIL': 'yes'}]:
            self.assertNotEqual(self.run_build(**settings).returncode, 0)

    def test_build_and_move_failures_preserve_old_package(self):
        dist = self.project / 'dist'
        dist.mkdir()
        previous = dist / 'example-package_0.1_amd64.deb'
        previous.write_text('old')
        for setting in ['BUILD_FAIL', 'MOVE_FAIL']:
            self.assertNotEqual(self.run_build(**{setting: 'yes'}).returncode, 0)
            self.assertEqual(previous.read_text(), 'old')

    def test_diu_recipe_matches_historical_builder(self):
        self.recipe = json.loads((ROOT / 'build/debian-package.json').read_text())
        self.save_recipe()
        (self.project / 'config').mkdir()
        (self.project / 'config/hosts.json').write_text('[]\n')
        (self.project / 'root-install-debian.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
        (self.project / 'root-install-debian.sh').chmod(0o755)
        for directory in ['lib', 'modules']:
            (self.project / directory).mkdir()
            (self.project / directory).chmod(0o2775)
            (self.project / directory / 'sample.sh').write_text('# fixture\n')
            (self.project / directory / 'sample.sh').chmod(0o775)
        result = self.run_build(action='build_deb_diu')
        self.assertEqual(result.returncode, 0, result.stderr)
        package = self.project / 'dist/diu_2026.11.02.12.00_all.deb'
        old_manifest = self.archive_manifest(package)
        old_metadata = subprocess.check_output(['dpkg-deb', '-f', str(package)])
        result = self.run_build()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(old_manifest, self.archive_manifest(package))
        self.assertEqual(old_metadata, subprocess.check_output(['dpkg-deb', '-f', str(package)]))
        control = subprocess.check_output(['dpkg-deb', '--ctrl-tarfile', str(package)])
        with tarfile.open(fileobj=io.BytesIO(control)) as archive:
            entry = next(member for member in archive.getmembers() if member.name.endswith('/conffiles'))
            self.assertEqual(archive.extractfile(entry).read().decode(), '/root/diu/config/hosts.json\n')
        (self.project / 'config/hosts.json').write_text('[{"ip":"127.0.0.1","fqdn":"test.example"}]')
        self.assertNotEqual(self.run_build().returncode, 0)
        self.assertEqual(old_manifest, self.archive_manifest(package))

    def test_configuration_flags_require_valid_files_and_boolean_values(self):
        self.recipe['files'][0]['conffile'] = True
        self.save_recipe()
        self.assertNotEqual(self.run_build().returncode, 0)  # payload is a directory
        self.recipe['files'][0]['conffile'] = 'true'
        self.save_recipe()
        self.assertNotEqual(self.run_build().returncode, 0)
        self.recipe['files'][0] = {'source': 'payload/file with spaces',
                                   'destination': '/usr/share/example.json', 'empty_json': True}
        for value in ('[] []', '{}', '[1]'):
            (self.project / 'payload/file with spaces').write_text(value)
            self.save_recipe()
            self.assertNotEqual(self.run_build().returncode, 0)

    def test_help_levels_and_invalid_arguments_before_bootstrap(self):
        result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), 'projects', 'help'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('diu projects build deb <ID PROJECT>', result.stdout)
        for suffix in [('build',), ('build', 'deb'), ('build', 'deb', 'diu'), ('build', 'debian'), ('build', 'debian', 'diu')]:
            for help_word in ['help', '?']:
                result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'),
                                         'projects', *suffix, help_word], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('build/debian-package.json', result.stdout)
                self.assertIn('PROJECT_DEBIAN_PACKAGE', result.stdout)
        for args in [('projects', 'build'), ('projects', 'build', 'deb'),
                     ('projects', 'build', 'deb', '../diu'),
                     ('projects', 'build', 'deb', 'diu', 'extra'),
                     ('projects', 'build', 'rpm', 'diu')]:
            result = subprocess.run(['bash', str(ROOT / 'root-install-debian.sh'), *args],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 2)
            self.assertNotIn('variables.sh', result.stderr)

    def test_dispatch(self):
        entry = (ROOT / 'root-install-debian.sh').read_text()
        function = re.search(r'^manage_project_action\(\) \{\n.*?^\}\n', entry, re.M | re.S).group()
        script = function + '\nprojects_build_deb() { printf "PROJECT:%s" "$1"; }\nmanage_project_action build deb example\n'
        for syntax in ['deb', 'debian']:
            result = subprocess.run(['bash', '-c', script.replace('build deb example', f'build {syntax} example')],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, 'PROJECT:example')


    def test_maintainer_scripts_are_packaged_but_never_executed(self):
        script=self.project/'build/postinst'
        marker=self.project/'must-not-exist'
        script.write_text('#!/bin/sh\nset -eu\ntouch '+str(marker)+'\n')
        script.chmod(0o770)
        self.recipe['maintainer_scripts']={'postinst':'build/postinst'}
        self.save_recipe()
        result=self.run_build()
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertFalse(marker.exists())
        data=subprocess.check_output(['dpkg-deb','--ctrl-tarfile',str(self.project/'dist/example-package_2.3_amd64.deb')])
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:
            item=archive.getmember('./postinst')
            self.assertEqual(item.mode,0o755)
            self.assertEqual(archive.extractfile(item).read(),script.read_bytes())
        self.assertEqual(script.stat().st_mode&0o777,0o770)

    def test_maintainer_scripts_reject_unknown_escape_links_and_secrets(self):
        (self.project/'build/postinst').write_text('#!/bin/sh\nexit 0\n')
        for value in [{'control':'build/postinst'},{'postinst':'../outside'}, {'postinst':'/bin/sh'}, {'postinst':'project.env'}, {'postinst':12}]:
            with self.subTest(value=value):
                self.recipe['maintainer_scripts']=value;self.save_recipe()
                self.assertNotEqual(self.run_build().returncode,0)
        (self.project/'build/alias').symlink_to('postinst')
        self.recipe['maintainer_scripts']={'postinst':'build/alias'};self.save_recipe()
        self.assertNotEqual(self.run_build().returncode,0)


if __name__ == '__main__':
    unittest.main()
