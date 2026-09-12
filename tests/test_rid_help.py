#!/usr/bin/env python3
"""Tests des chemins d'aide rid exécutables sans configuration de production."""
from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
ENTRYPOINT = ROOT / 'root-install-debian.sh'


class RidHelpTests(unittest.TestCase):
    def run_rid(self, *arguments):
        return subprocess.run(
            ['bash', str(ENTRYPOINT), *arguments],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_root_help_is_available_without_configuration(self):
        result = self.run_rid('help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares', result.stdout)
        self.assertIn('→', result.stdout)

    def test_software_help_lists_available_commands(self):
        result = self.run_rid('softwares', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares install apt <SOFTWARE>', result.stdout)
        self.assertIn('rid softwares update github [SOFTWARE]', result.stdout)
        self.assertIn('rid softwares flatpak update', result.stdout)

    def test_flatpak_help_is_available_without_configuration(self):
        result = self.run_rid('softwares', 'flatpak', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid softwares flatpak update', result.stdout)

    def test_terminal_help_does_not_publish(self):
        result = self.run_rid('projects', 'github', 'push', 'help')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('rid projects github push <ID PROJECT>', result.stdout)

    def test_unknown_root_command_suggests_root_help(self):
        result = self.run_rid('inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Classe d'actions inconnue : inconnue", result.stdout)
        self.assertIn('rid help', result.stdout)

    def test_unknown_software_command_suggests_contextual_help(self):
        result = self.run_rid('softwares', 'inconnue')
        self.assertEqual(result.returncode, 2)
        self.assertIn("Action inconnue pour la classe 'softwares' : inconnue", result.stdout)
        self.assertIn('rid softwares help', result.stdout)


if __name__ == '__main__':
    unittest.main()
