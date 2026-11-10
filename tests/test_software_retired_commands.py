import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class RetiredSoftwareCommandsTests(unittest.TestCase):
    def test_old_software_commands_fail_before_loading_configuration(self):
        for action in ("install", "remove", "update"):
            for engine in ("apt", "github"):
                with self.subTest(action=action, engine=engine):
                    result = subprocess.run(
                        ["bash", str(ROOT / "root-install-debian.sh"), action, engine, "example"],
                        text=True, capture_output=True, check=False,
                    )
                    self.assertEqual(result.returncode, 2)
                    self.assertIn("syntaxe logicielle a été supprimée", result.stderr)
                    help_result = subprocess.run(
                        ["bash", str(ROOT / "root-install-debian.sh"), action, engine, "help"],
                        text=True, capture_output=True, check=False,
                    )
                    self.assertEqual(help_result.returncode, 2)
                    self.assertIn("syntaxe logicielle a été supprimée", help_result.stderr)


if __name__ == "__main__":
    unittest.main()
