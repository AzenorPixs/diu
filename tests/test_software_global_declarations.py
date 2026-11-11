import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class GlobalDeclarationsTests(unittest.TestCase):
    def test_repository_and_secret_are_initialized_without_leaking_value(self):
        with tempfile.TemporaryDirectory(prefix=".software-globals-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            script = (
                'source "$1/modules/softwares/desired-state.sh"\n'
                'source "$1/modules/softwares/migration.sh"\n'
                'source "$1/modules/softwares/global-declarations.sh"\n'
                'system_apt_source_state() { printf "0\\n"; }\n'
                'SOFTWARE_APT_CROWDSEC_AGENT=1\n'
                'SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY=fixture-secret\n'
                'software_declare_crowdsec_repository "$2" || exit $?\n'
                'software_declare_crowdsec_secret "$2"'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("fixture-secret", result.stdout + result.stderr)
            content = config.read_text(encoding="utf-8")
            self.assertIn("export SOFTWARE_APT_CROWDSEC=0\n", content)
            self.assertIn("export SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY=fixture-secret\n", content)
            self.assertEqual(config.stat().st_mode & 0o777, 0o600)

    def test_repository_detection_failure_is_deferred(self):
        with tempfile.TemporaryDirectory(prefix=".software-globals-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            script = (
                'source "$1/modules/softwares/global-declarations.sh"\n'
                'software_crowdsec_repository_detect() { return 1; }\n'
                'software_declare_crowdsec_repository "$2"'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("différée", result.stderr)
            self.assertFalse(config.exists())


if __name__ == "__main__":
    unittest.main()
