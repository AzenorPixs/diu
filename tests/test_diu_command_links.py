"""Contrôles isolés des liens de commande DIU."""
from pathlib import Path
import os
import subprocess
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DiuCommandLinksTests(unittest.TestCase):
    def test_link_creation_idempotence_and_occupied_names(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            base = Path(tmp)
            target = base / 'source with spaces'
            target.write_text('target')
            link = base / 'diu'
            def create():
                return subprocess.run(['bash', '-c', 'source "$1"; diu_create_link "$2" "$3"',
                                       'test', str(ROOT / 'lib/diu-links.sh'), str(target), str(link)],
                                      capture_output=True, text=True)
            self.assertEqual(create().returncode, 0)
            self.assertEqual(link.readlink(), target)
            self.assertEqual(create().returncode, 0)
            link.unlink()
            link.symlink_to(base / 'missing')
            self.assertEqual(create().returncode, 0)
            self.assertEqual(link.readlink(), base / 'missing')
            link.unlink()
            link.write_text('preserved')
            self.assertEqual(create().returncode, 0)
            self.assertEqual(link.read_text(), 'preserved')
            link.unlink()
            link.mkdir()
            self.assertEqual(create().returncode, 0)
            self.assertTrue(link.is_dir())
            link.rmdir()
            link = base / 'missing-dir' / 'diu'
            self.assertNotEqual(create().returncode, 0)

    def test_development_target_must_exist_under_configured_root(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            base = Path(tmp)
            projects = base / 'custom root'
            link = base / 'diut'
            def create():
                return subprocess.run(['bash', '-c', 'source "$1"; diu_create_development_link "$2" "$3"',
                                       'test', str(ROOT / 'lib/diu-links.sh'), str(projects), str(link)],
                                      capture_output=True, text=True)
            self.assertEqual(create().returncode, 0)
            self.assertFalse(link.is_symlink())
            target = projects / 'diu/root-install-debian.sh'
            target.parent.mkdir(parents=True)
            target.write_text('fixture')
            self.assertEqual(create().returncode, 0)
            self.assertEqual(link.readlink(), target)
            self.assertEqual(create().returncode, 0)
            self.assertEqual(link.readlink(), target)

    def test_built_package_postinst_is_conditional(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            base = Path(tmp)
            projects = base / 'projects'
            project = projects / 'diu'
            (project / 'lib').mkdir(parents=True)
            (project / 'modules').mkdir()
            (project / 'config').mkdir()
            (project / 'config/hosts.json').write_text('[]\n')
            (project / 'root-install-debian.sh').write_text('#!/bin/bash\n')
            shutil.copy(ROOT / 'lib/diu-links.sh', project / 'lib/diu-links.sh')
            build = r'''source "$1/modules/projects/diu-packaging.sh"
print_error() { echo "$*" >&2; }
print_info() { :; }
print_success() { :; }
ENV_DEVOPS_USER="$(id -un)"
ENV_DEVOPS_PROJECTS_ROOT="$2"
build_deb_diu
'''
            scratch = base / 'scratch'
            scratch.mkdir()
            result = subprocess.run(['bash', '-c', build, 'test', str(ROOT), str(projects)],
                                    capture_output=True, text=True,
                                    env={**os.environ, 'TMPDIR': str(scratch)})
            self.assertEqual(result.returncode, 0, result.stderr)
            package = next((project / 'dist').glob('*.deb'))
            control = base / 'control'
            subprocess.run(['dpkg-deb', '-e', str(package), str(control)], check=True)
            postinst = control / 'postinst'
            target = base / 'installed' / 'root-install-debian.sh'
            link = base / 'bin' / 'diu'
            link.parent.mkdir()
            text = postinst.read_text().replace('/root/diu/lib/diu-links.sh', str(ROOT / 'lib/diu-links.sh'))
            text = text.replace('/root/diu/root-install-debian.sh', str(target))
            text = text.replace('/usr/local/bin/diu', str(link))
            postinst.write_text(text)
            for _ in range(2):
                subprocess.run([str(postinst), 'configure'], check=True)
                self.assertEqual(link.readlink(), target)
            link.unlink()
            link.symlink_to(base / 'other-missing-target')
            subprocess.run([str(postinst), 'configure'], check=True)
            self.assertEqual(link.readlink(), base / 'other-missing-target')

    def test_help_through_symbolic_link(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            link = Path(tmp) / 'diu'
            link.symlink_to(ROOT / 'root-install-debian.sh')
            result = subprocess.run([str(link), 'help'], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(result.stdout.strip())


if __name__ == '__main__':
    unittest.main()
