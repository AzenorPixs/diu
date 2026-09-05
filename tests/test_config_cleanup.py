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
             + prelude + '\nconfig_cleanup "$TARGET"'],
            env=dict(os.environ, ROOT=str(ROOT), TARGET=str(path)),
            text=True, capture_output=True)

    def test_cleanup_and_idempotence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            preserved = ('# DEBIAN_RELEASE=comment\n'
                         'SYSTEM_DEBIAN_RELEASE=bookworm\n'
                         'DEBIAN_RELEASE_EXTRA=keep\nOTHER=keep\n\n')
            path.write_text('DEBIAN_RELEASE=old\n export DEBIAN_RELEASE="old"\n'
                            '\texport\tDEBIAN_RELEASE=old # comment\n' + preserved)
            path.chmod(0o640)
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved)
            self.assertEqual(path.stat().st_mode & 0o777, 0o640)
            before = path.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved)
            self.assertEqual(path.stat().st_mtime_ns, before.st_mtime_ns)
            self.assertEqual(path.stat().st_ino, before.st_ino)
            self.assertEqual(result.stdout, '')

    def test_missing_file(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'missing.sh'
            self.assertEqual(self.run_cleanup(path).returncode, 0)
            self.assertFalse(path.exists())

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


if __name__ == '__main__':
    unittest.main()
