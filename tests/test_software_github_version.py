import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class GithubVersionTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".github-version-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.binary = Path(self.directory.name) / "codex"
        self.config = Path(self.directory.name) / "config"
        self.config.write_text("export SOFTWARE_GITHUB_CODEX_CLI=1\n", encoding="utf-8")
        self.binary.write_text("#!/bin/sh\nprintf 'codex 1.0.0\\n'\n", encoding="utf-8")
        self.binary.chmod(0o700)

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/github.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/github-state.sh"\n'
            'source "$1/modules/softwares/github-version.sh"\n'
            'fixture_binary="$2"\n'
            'software_github_convergence_metadata() { case "$2" in\n'
            ' variable) echo SOFTWARE_GITHUB_CODEX_CLI;; binary) echo "$fixture_binary";;\n'
            ' command) echo codex;; owner) echo openai;; repository) echo codex;; tag-prefix) echo rust-v;;\n'
            ' *) return 1;; esac; }\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.binary), str(self.config)],
                              text=True, capture_output=True, check=False)

    def test_new_version_invokes_install_without_changing_desired_state(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_CODEX_CLI=1\n'
            'software_github_convergence_detect() { echo 1; }\n'
            'curl() { printf "{\\"tag_name\\":\\"rust-v2.0.0\\"}\\n"; }\n'
            'software_github_install() { echo INSTALL; }\n'
            'software_github_update_version codex-cli "$3" || exit $?\n'
            '[[ "$SOFTWARE_GITHUB_CODEX_CLI" == 1 ]]'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("INSTALL", result.stdout)

    def test_absent_software_is_not_installed_or_queried(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_CODEX_CLI=1\n'
            'software_github_convergence_detect() { echo 0; }\n'
            'curl() { echo unexpected; return 1; }\n'
            'software_github_update_version codex-cli "$3"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_unknown_version_fails_without_install(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_CODEX_CLI=1\n'
            'software_github_convergence_detect() { echo 1; }\n'
            'curl() { echo "{}"; }\n'
            'software_github_install() { echo unexpected; }\n'
            'software_github_update_version codex-cli "$3"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
