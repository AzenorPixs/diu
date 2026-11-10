import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class AptExternalVersionsTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".apt-external-version-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"
        self.config.write_text("export SOFTWARE_APT_ZOOM=1\n", encoding="utf-8")

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/apt-convergence.sh"\n'
            'source "$1/modules/system/software-versions.sh"\n'
            'export TMPDIR="$3"; SOFTWARE_APT_ZOOM=1\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config), self.directory.name],
                              text=True, capture_output=True, check=False)

    def test_newer_artifact_updates_without_mutating_desired_state(self):
        result = self.run_shell(
            'software_apt_convergence_detect() { echo 1; }\n'
            'software_apt_fetch_artifact() { printf "%s/package.deb\\n" "$3"; }\n'
            'dpkg-query() { echo 1.0; }; dpkg-deb() { echo 2.0; }; dpkg() { return 0; }\n'
            'apt() { echo INSTALL; }\n'
            'system_apt_update_external_one "$2" zoom'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("INSTALL", result.stdout)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_ZOOM=1\n")

    def test_absent_software_is_not_downloaded(self):
        result = self.run_shell(
            'software_apt_convergence_detect() { echo 0; }\n'
            'software_apt_fetch_artifact() { echo unexpected; }\n'
            'system_apt_update_external_one "$2" zoom'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_same_or_older_version_does_not_install(self):
        result = self.run_shell(
            'software_apt_convergence_detect() { echo 1; }\n'
            'software_apt_fetch_artifact() { printf "%s/package.deb\\n" "$3"; }\n'
            'dpkg-query() { echo 2.0; }; dpkg-deb() { echo 1.0; }; dpkg() { return 1; }\n'
            'apt() { echo unexpected; }\n'
            'system_apt_update_external_one "$2" zoom'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
