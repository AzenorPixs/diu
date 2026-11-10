import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class LegacyDirectTests(unittest.TestCase):
    def test_legacy_install_does_not_change_desired_state(self):
        with tempfile.TemporaryDirectory(prefix=".software-legacy-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            data = "export SOFTWARE_APT_CHATGPT=0\n"
            config.write_text(data, encoding="utf-8")
            script = (
                'source "$1/modules/softwares/legacy-direct.sh"\n'
                'SOFTWARE_APT_CHATGPT=0; SYSTEM_APT_ENGINE=1\n'
                'software_apt_converge() { echo "action $1 $2"; }\n'
                'software_legacy_direct "$2" install apt chatgpt || exit $?\n'
                '[[ "$SOFTWARE_APT_CHATGPT" == 0 ]]'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("action chatgpt 1", result.stdout)
            self.assertEqual(config.read_text(encoding="utf-8"), data)

    def test_unknown_legacy_target_is_rejected_before_action(self):
        script = (
            'source "$1/modules/softwares/legacy-direct.sh"\n'
            'software_apt_converge() { echo unexpected; }\n'
            'software_legacy_direct /fixture install apt unknown'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
