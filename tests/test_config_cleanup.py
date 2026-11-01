#!/usr/bin/env python3
"""Tests isolés de migration sans lecture de la configuration locale."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ConfigCleanupTests(unittest.TestCase):
    def run_cleanup(self, path, prelude=""):
        return subprocess.run(
            ["bash", "-c", 'set -Eeuo pipefail\nsource "$ROOT/modules/system/variables-cleanup.sh"\n'
             + prelude + '\nconfig_cleanup "$TARGET" "$SYSTEM_CONFIG"'],
            env=dict(os.environ, ROOT=str(ROOT), TARGET=str(path),
                     SYSTEM_CONFIG=str(path.parent / 'system.env')),
            text=True, capture_output=True)

    def test_cleanup_and_idempotence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            preserved = ('# DEBIAN_RELEASE=comment\n# DEBIAN_TYPE=comment\n# DISPLAY_LINK=comment\n'
                         '# PROXY_CA=comment\n'
                         'SYSTEM_DRIVERS_DISPLAY_LINK=1\nDISPLAY_LINK_EXTRA=keep\n'
                         '# TIME_ZONE=comment\nSYSTEM_TIME_ZONE=UTC\nTIME_ZONE_EXTRA=keep\n'
                         'SYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n'
                         'SYSTEM_DEBIAN_ENVIRONNEMENT=VM\nDEBIAN_TYPE_EXTRA=keep\n'
                         'SYSTEM_DEBIAN_RELEASE=bookworm\n'
                         'DEBIAN_RELEASE_EXTRA=keep\nOTHER=keep\n\n')
            path.write_text('DEBIAN_RELEASE=old\n export DEBIAN_RELEASE="old"\n'
                            '\texport\tDEBIAN_RELEASE=old # comment\n'
                            'DEBIAN_TYPE=PHYSICAL\n export DEBIAN_TYPE=VM\n'
                            '\texport\tDEBIAN_TYPE=LXC # comment\n'
                            'TIME_ZONE=UTC\n export TIME_ZONE=Europe/London\n'
                            '\texport\tTIME_ZONE=UTC # comment\n'
                            'DISPLAY_LINK=1\n export DISPLAY_LINK=0\n'
                            '\texport\tDISPLAY_LINK=1 # comment\n'
                            'PROXY_CA=0\n export PROXY_CA="1"\n'
                            '\texport\tPROXY_CA=1 # comment\n' + preserved)
            with path.open('a') as stream:
                stream.write('PROXY=0\n export PROXY=1 # legacy\nPROXY_HTTP=1\n')
            path.chmod(0o640)
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved + 'PROXY_HTTP=1\n')
            self.assertEqual((Path(directory) / 'system.env').read_text(),
                             'export SYSTEM_PROXY=1\n')
            self.assertEqual(path.stat().st_mode & 0o777, 0o640)
            before = path.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved + 'PROXY_HTTP=1\n')
            self.assertEqual(path.stat().st_mtime_ns, before.st_mtime_ns)
            self.assertEqual(path.stat().st_ino, before.st_ino)
            self.assertEqual(result.stdout, '')

    def test_proxy_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('PROXY=0\nexport PROXY=1\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_PROXY=1\n')
            before = system_config.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.stat().st_mtime_ns, before.st_mtime_ns)

            path.write_text('PROXY=0\n')
            system_config.write_text('export SYSTEM_PROXY=1\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_PROXY=1\n')

    def test_ambiguous_proxy_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export PROXY="${PROXY_ENABLED}"\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), 'export PROXY="${PROXY_ENABLED}"\nOTHER=keep\n')
            self.assertFalse((Path(directory) / 'system.env').exists())
            self.assertNotIn('PROXY_ENABLED', result.stderr)
            self.assertEqual(result.stdout, '')

    def test_missing_file(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'missing.sh'
            self.assertEqual(self.run_cleanup(path).returncode, 0)
            self.assertFalse(path.exists())

    def test_debian_type_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export DEBIAN_TYPE="PROXMOX"\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(result.stdout, '')

    def test_display_link_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            original = 'export DISPLAY_LINK="1"\nOTHER=keep\n'
            path.write_text(original)
            for prelude in ('grep() { return 2; }', 'sed() { return 1; }'):
                result = self.run_cleanup(path, prelude)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(path.read_text(), original)
                self.assertEqual(result.stdout, '')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')

    def test_proxy_ca_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export PROXY_CA=1\nSYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'SYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n')
            self.assertEqual(result.stdout, '')

    def test_read_and_write_errors(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            original = 'DEBIAN_RELEASE=old\n'
            path.write_text(original)
            for prelude in ('grep() { return 2; }', 'sed() { return 1; }'):
                result = self.run_cleanup(path, prelude)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Erreur', result.stderr)
                self.assertEqual(result.stdout, '')
                self.assertEqual(path.read_text(), original)

    def test_startup_order_and_consumers(self):
        text = (ROOT / 'root-install-debian.sh').read_text()
        self.assertLess(text.index('modules/system/variables-cleanup.sh'), text.index('config_cleanup || exit 1'))
        self.assertLess(text.index('config_cleanup || exit 1'), text.index('. "/root/diu/variables.sh"'))
        self.assertNotRegex(text, r'\bDEBIAN_RELEASE\b')
        self.assertIn('SYSTEM_DEBIAN_RELEASE', text)
        self.assertNotRegex(text, r'\bTIME_ZONE\b')
        self.assertIn('timedatectl set-timezone "$SYSTEM_TIME_ZONE"', text)
        self.assertNotRegex(text, r'\bDEBIAN_TYPE\b')
        self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT', text)
        self.assertNotRegex(text, r'\bDISPLAY_LINK\b')
        self.assertIn('PROXY_CA', (ROOT / 'modules/system/variables-cleanup.sh').read_text())
        self.assertNotRegex(text, r'\bPROXY_CA\b')
        self.assertIn('. "$BASH_SCRIPT_PATH/modules/system/drivers.sh"', text)
        drivers = (ROOT / 'modules/system/drivers.sh').read_text()
        self.assertNotRegex(drivers, r'\bDISPLAY_LINK\b')
        self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK', drivers)


if __name__ == '__main__':
    unittest.main()
