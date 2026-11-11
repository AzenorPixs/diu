"""Contrôles isolés des liens de commande DIU."""
from pathlib import Path
import os
import re
import subprocess
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DiuCommandLinksTests(unittest.TestCase):
    def test_generated_aliases_use_diu_commands(self):
        result = subprocess.run(['bash', '-c', 'source "$1/modules/softwares/apt-recipes.sh"; '
                                 'software_apt_load_recipes; software_apt_zsh_defaults', '--', str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        definitions = re.findall(r'^(alias [^\n]+)$', result.stdout, re.MULTILINE)
        aliases = {}
        for definition in definitions:
            name, target = definition.removeprefix('alias ').split('=', 1)
            aliases[name] = target.strip("'")
        expected = {
            'diu': '/root/diu/root-install-debian.sh',
            'diut': '/home/devops/datas/diu/root-install-debian.sh',
            'diuo': 'diu projects ocrw',
            'diuu': 'diu update',
            'ndiu': 'nano /root/diu/root-install-debian.sh',
            'rcicddiu': 'diut projects cicddiu',
            'rcicddr': 'diut projects cicddr',
            'drid': 'docker run --rm --entrypoint id',
        }
        for name, target in expected.items():
            with self.subTest(alias=name):
                self.assertEqual(aliases[name], target)
        old_command = 'r' + 'id'
        for name in (old_command, old_command + 't', old_command + 'o',
                     old_command + 'u', 'n' + old_command):
            self.assertNotIn(name, aliases)

    def test_executable_sources_use_diu_identifiers(self):
        old_command = 'r' + 'id'
        pattern = re.compile(r'(?<![A-Za-z])' + old_command
                             + r'(?:t|o|u)?(?![A-Za-z])')
        paths = [ROOT / 'root-install-debian.sh']
        for directory in ('lib', 'modules'):
            paths.extend((ROOT / directory).rglob('*.sh'))
        for path in paths:
            with self.subTest(path=path.relative_to(ROOT)):
                self.assertIsNone(pattern.search(path.read_text()))
        self.assertTrue((ROOT / 'lib/diu-help.sh').is_file())
        self.assertFalse((ROOT / 'lib' / (old_command + '-help.sh')).exists())

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

    def test_installed_startup_checks_link_before_help(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            base = Path(tmp)
            installed = base / 'installed'
            (installed / 'lib').mkdir(parents=True)
            shutil.copy(ROOT / 'lib/diu-links.sh', installed / 'lib/diu-links.sh')
            shutil.copy(ROOT / 'lib/diu-help.sh', installed / 'lib/diu-help.sh')
            shutil.copy(ROOT / 'lib/diu-softwares-help.sh', installed / 'lib/diu-softwares-help.sh')
            target = installed / 'root-install-debian.sh'
            link = base / 'bin/diu'
            link.parent.mkdir()
            source = (ROOT / 'root-install-debian.sh').read_text()
            # Simuler root et isoler les chemins, sans modifier le système.
            source = source.replace('"$EUID" -eq 0', '"$EUID" -eq "$EUID"', 1)
            source = source.replace('/root/diu/root-install-debian.sh', str(target))
            source = source.replace('/usr/local/bin/diu', str(link))
            target.write_text(source)
            def run(path=target):
                return subprocess.run(['bash', str(path), 'help'], capture_output=True, text=True)
            self.assertEqual(run().returncode, 0)
            self.assertEqual(link.readlink(), target)
            self.assertEqual(run().returncode, 0)
            link.unlink()
            link.symlink_to(base / 'missing')
            self.assertEqual(run().returncode, 0)
            self.assertEqual(link.readlink(), base / 'missing')
            link.unlink()
            link.write_text('preserved')
            self.assertEqual(run().returncode, 0)
            self.assertEqual(link.read_text(), 'preserved')
            link.unlink()
            dev = installed / 'development.sh'
            dev.write_text(source)
            self.assertEqual(run(dev).returncode, 0)
            self.assertFalse(link.exists())
            link.parent.rmdir()
            result = run()
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('Impossible de créer le lien', result.stderr)

    def test_help_through_symbolic_link(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-links-test-') as tmp:
            base = Path(tmp)
            target = base / 'installed/root-install-debian.sh'
            target.parent.mkdir()
            shutil.copy(ROOT / 'root-install-debian.sh', target)
            target.chmod(0o755)
            (target.parent / 'lib').mkdir()
            shutil.copy(ROOT / 'lib/diu-help.sh', target.parent / 'lib/diu-help.sh')
            shutil.copy(ROOT / 'lib/diu-softwares-help.sh', target.parent / 'lib/diu-softwares-help.sh')
            link = base / 'diu'
            link.symlink_to(target)
            result = subprocess.run([str(link), 'help'], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(result.stdout.strip())


if __name__ == '__main__':
    unittest.main()
