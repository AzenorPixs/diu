import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "lib/diu-softwares-help.sh"


class SoftwareConvergenceHelpTests(unittest.TestCase):
    def run_help(self, *arguments):
        script = 'diu_help_line() { printf "%s : %s\\n" "$1" "$2"; }; source "$1"; shift; diu_softwares_convergence_help "$@"'
        return subprocess.run(["bash", "-c", script, "--", str(MODULE), *arguments],
                              text=True, capture_output=True, check=False)

    def test_global_help_describes_desired_state_and_order(self):
        result = self.run_help()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("APT, Flatpak puis GitHub", result.stdout)
        self.assertIn("état désiré 1", result.stdout)
        self.assertIn("diu system engine update", result.stdout)

    def test_flatpak_targeted_help_and_legacy_alias(self):
        targeted = self.run_help("update", "flatpak")
        self.assertEqual(targeted.returncode, 0, targeted.stderr)
        self.assertIn("diu softwares update flatpak [SOFTWARE]", targeted.stdout)
        alias = self.run_help("flatpak", "update")
        self.assertEqual(alias.returncode, 0, alias.stderr)
        self.assertIn("Alias compatible de convergence", alias.stdout)

    def test_unknown_context_fails(self):
        result = self.run_help("install", "unknown")
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
