import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/github-state.sh"


class GithubStateTests(unittest.TestCase):
    def test_catalogue_uses_the_github_variable(self):
        result = subprocess.run(
            ["bash", "-c", 'source "$1"; software_github_convergence_metadata codex-cli variable',
             "--", str(MODULE)], text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "SOFTWARE_GITHUB_CODEX_CLI")

    def test_detector_checks_real_executable_without_using_desired_variable(self):
        with tempfile.TemporaryDirectory(prefix=".github-state-test-", dir=ROOT) as directory:
            binary = Path(directory) / "codex"
            script = (
                'source "$1"\n'
                'fixture_binary="$2"; PATH=/nonexistent; SOFTWARE_GITHUB_CODEX_CLI=0\n'
                'software_github_convergence_metadata() { printf "%s\\n" "$fixture_binary"; }\n'
                'software_github_codex_cli_detect'
            )
            absent = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(binary)],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(absent.stdout, "0\n")
            binary.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            binary.chmod(0o700)
            present = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(binary)],
                                     text=True, capture_output=True, check=False)
            self.assertEqual(present.returncode, 0, present.stderr)
            self.assertEqual(present.stdout, "1\n")

    def test_unknown_software_is_rejected(self):
        result = subprocess.run(
            ["bash", "-c", 'source "$1"; software_github_convergence_detect unknown',
             "--", str(MODULE)], text=True, capture_output=True, check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
