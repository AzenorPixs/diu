import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/system/software-versions.sh"


class FlatpakSoftwareVersionsTests(unittest.TestCase):
    def run_shell(self, body):
        return subprocess.run(["bash", "-c", 'source "$1"\n' + body, "--", str(MODULE)],
                              text=True, capture_output=True, check=False)

    def test_installed_applications_are_updated_at_system_scope(self):
        result = self.run_shell(
            'flatpak() { case "$1" in list) printf "org.example.App\\n";; '
            'update) printf "update %s\\n" "$*";; esac; }\n'
            'system_flatpak_update_applications'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("update update --system --noninteractive", result.stdout)

    def test_empty_inventory_does_not_call_update(self):
        result = self.run_shell(
            'flatpak() { [[ "$1" == list ]] && return 0; echo unexpected; }\n'
            'system_flatpak_update_applications'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_failed_inventory_is_not_reported_as_empty(self):
        result = self.run_shell(
            'flatpak() { return 1; }\n'
            'system_flatpak_update_applications'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("indisponible", result.stderr)

    def test_github_failures_do_not_skip_other_software(self):
        result = self.run_shell(
            'software_github_convergence_names() { printf "first\\nsecond\\n"; }\n'
            'software_github_update_version() { echo "$1"; [[ "$1" != first ]]; }\n'
            'system_github_update_applications /fixture'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ["first", "second"])


if __name__ == "__main__":
    unittest.main()
