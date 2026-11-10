import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SharedResourceTests(unittest.TestCase):
    def test_resource_is_retained_if_desired_or_actually_used(self):
        with tempfile.TemporaryDirectory(prefix=".shared-resource-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            for desired, actual, expected in ((0, 0, "0"), (1, 0, "1"), (0, 1, "1"), (1, 1, "1")):
                with self.subTest(desired=desired, actual=actual):
                    config.write_text(f"export SOFTWARE_APT_SYSLOG_SERVER={desired}\n", encoding="utf-8")
                    script = (
                        'source "$1/modules/softwares/desired-state.sh"\n'
                        'source "$1/modules/softwares/shared-resource.sh"\n'
                        f'SOFTWARE_APT_SYSLOG_SERVER={desired}\n'
                        f'detect() {{ printf "{actual}\\n"; }}\n'
                        'software_shared_resource_needed "$2" SOFTWARE_APT_SYSLOG_SERVER detect'
                    )
                    result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                            text=True, capture_output=True, check=False)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout.strip(), expected)

    def test_inconsistent_or_unknown_state_does_not_authorize_removal(self):
        with tempfile.TemporaryDirectory(prefix=".shared-resource-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            config.write_text("export SOFTWARE_APT_SYSLOG_SERVER=1\n", encoding="utf-8")
            script = (
                'source "$1/modules/softwares/desired-state.sh"\n'
                'source "$1/modules/softwares/shared-resource.sh"\n'
                'SOFTWARE_APT_SYSLOG_SERVER=0\n'
                'detect() { printf "0\\n"; }\n'
                'software_shared_resource_needed "$2" SOFTWARE_APT_SYSLOG_SERVER detect'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    text=True, capture_output=True, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
