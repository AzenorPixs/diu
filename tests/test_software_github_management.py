import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class GithubManagementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".github-management-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/github-state.sh"\n'
            'source "$1/modules/softwares/github-convergence.sh"\n'
            'source "$1/modules/softwares/github-management.sh"\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), str(self.config)],
            text=True, capture_output=True, check=False,
        )

    def test_remove_records_desired_state_before_convergence(self):
        result = self.run_shell(
            'real_state=1\n'
            'software_github_convergence_detect() { printf "%s\\n" "$real_state"; }\n'
            'software_github_install() { echo unexpected; return 1; }\n'
            'software_github_remove() { real_state=0; }\n'
            'software_github_manage_one "$2" remove codex-cli'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_GITHUB_CODEX_CLI=0\n")
        self.assertNotIn("unexpected", result.stdout)

    def test_failed_install_keeps_desired_state(self):
        result = self.run_shell(
            'software_github_convergence_detect() { printf "0\\n"; }\n'
            'software_github_install() { return 1; }\n'
            'software_github_remove() { return 0; }\n'
            'software_github_manage_one "$2" install codex-cli'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_GITHUB_CODEX_CLI=1\n")

    def test_first_update_does_not_overwrite_persisted_value(self):
        data = "export SOFTWARE_GITHUB_CODEX_CLI=1\n"
        self.config.write_text(data, encoding="utf-8")
        result = self.run_shell(
            'software_github_convergence_detect() { printf "0\\n"; }\n'
            'software_github_manage_one "$2" update codex-cli'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)


if __name__ == "__main__":
    unittest.main()
