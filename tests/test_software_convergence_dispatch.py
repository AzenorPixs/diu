import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/dispatch.sh"


class SoftwareConvergenceDispatchTests(unittest.TestCase):
    def run_shell(self, body):
        script = (
            'source "$1"\n'
            'SYSTEM_APT_ENGINE=1; SYSTEM_FLATPAK_ENGINE=1; SYSTEM_GITHUB_ENGINE=1\n'
            'software_apt_manage_all() { echo apt; return "${APT_STATUS:-0}"; }\n'
            'software_flatpak_manage_all() { echo flatpak; }\n'
            'software_github_manage_all() { echo github; }\n'
            'software_apt_manage_one() { echo "apt $2 $3"; }\n'
            'software_flatpak_manage_one() { echo "flatpak $2 $3"; }\n'
            'software_github_manage_one() { echo "github $2 $3"; }\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(MODULE)],
                              text=True, capture_output=True, check=False)

    def test_global_order_and_failure_continuation(self):
        result = self.run_shell('APT_STATUS=1\nsoftware_dispatch /fixture update')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ["apt", "flatpak", "github"])

    def test_flatpak_target_and_legacy_alias(self):
        result = self.run_shell(
            'software_dispatch /fixture update flatpak org.example.App\n'
            'software_dispatch /fixture flatpak update'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ["flatpak update org.example.App", "flatpak"])

    def test_global_invalid_engine_state_fails_and_continues(self):
        result = self.run_shell('SYSTEM_FLATPAK_ENGINE=invalid\nsoftware_dispatch /fixture update')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ["apt", "github"])
        self.assertIn("État invalide", result.stderr)

    def test_disabled_and_invalid_commands_have_no_effect(self):
        disabled = self.run_shell('SYSTEM_GITHUB_ENGINE=0\nsoftware_dispatch /fixture install github codex-cli')
        self.assertNotEqual(disabled.returncode, 0)
        self.assertEqual(disabled.stdout, "")
        invalid = self.run_shell('software_dispatch /fixture install apt jsvc extra')
        self.assertNotEqual(invalid.returncode, 0)
        self.assertEqual(invalid.stdout, "")


if __name__ == "__main__":
    unittest.main()
