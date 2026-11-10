import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/apt-state.sh"


class AptStateTests(unittest.TestCase):
    def run_detector(self, rows, function="software_apt_jsvc_detect", status=0):
        # The test double captures the values before its own positional arguments replace them.
        script = (
            'source "$1"\n'
            'test_rows="$2"; test_status="$3"; detector="$4"\n'
            'dpkg-query() { printf "%s" "$test_rows"; return "$test_status"; }\n'
            '"$detector"'
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(MODULE), rows, str(status), function],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_installed_and_absent(self):
        for rows, expected in (("jsvc\tinstalled\n", "1"), ("other\tinstalled\n", "0"),
                               ("jsvc\tconfig-files\n", "0"), ("jsvc:amd64\tinstalled\n", "1")):
            with self.subTest(rows=rows):
                result = self.run_detector(rows)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)

    def test_partial_install_and_database_error_are_not_absence(self):
        for rows, status in (("jsvc\tunpacked\n", 0), ("", 1)):
            with self.subTest(rows=rows, status=status):
                result = self.run_detector(rows, status=status)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")

    def test_detector_uses_its_own_package(self):
        result = self.run_detector("postgresql\tinstalled\npostgresql-17\tinstalled\n", "software_apt_postgresql_detect")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "1")

    def test_postgresql_meta_without_server_and_database_failure_are_not_absence(self):
        for rows, status in (("postgresql\tinstalled\n", 0), ("", 1)):
            with self.subTest(rows=rows, status=status):
                result = self.run_detector(rows, "software_apt_postgresql_detect", status)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")

    def test_postgresql_absent_is_reported_as_zero(self):
        result = self.run_detector("other\tinstalled\n", "software_apt_postgresql_detect")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "0\n")

    def test_openjdk_detects_installed_versions_and_rejects_partial_state(self):
        present = self.run_detector("openjdk-17-jre-headless\tinstalled\n", "software_apt_openjdk_detect")
        self.assertEqual(present.returncode, 0, present.stderr)
        self.assertEqual(present.stdout, "1\n")
        partial = self.run_detector("openjdk-21-jre-headless\tunpacked\n", "software_apt_openjdk_detect")
        self.assertNotEqual(partial.returncode, 0)
        self.assertEqual(partial.stdout, "")

    def test_mongodb_requires_real_server_not_only_meta_package(self):
        present = self.run_detector("mongodb-org\tinstalled\nmongodb-org-server\tinstalled\n", "software_apt_mongodb_detect")
        self.assertEqual(present.returncode, 0, present.stderr)
        self.assertEqual(present.stdout, "1\n")
        partial = self.run_detector("mongodb-org\tinstalled\n", "software_apt_mongodb_detect")
        self.assertNotEqual(partial.returncode, 0)
        self.assertEqual(partial.stdout, "")

    def test_wazuh_server_partial_install_is_still_present(self):
        result = self.run_detector("wazuh-manager\tinstalled\n", "software_apt_wazuh_server_detect")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "1\n")

    def test_release_is_read_literally_without_executing_content(self):
        with tempfile.TemporaryDirectory(prefix=".software-release-test-", dir=ROOT) as directory:
            release = Path(directory) / "os-release"
            sentinel = Path(directory) / "executed"
            script = 'source "$1"; unset SYSTEM_DEBIAN_RELEASE; software_apt_effective_release "$2"'
            release.write_text('VERSION_CODENAME="trixie"\n', encoding="utf-8")
            valid = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(release)],
                                   text=True, capture_output=True, check=False)
            self.assertEqual((valid.returncode, valid.stdout), (0, "trixie\n"))
            release.write_text(f'VERSION_CODENAME=$(touch {sentinel})\n', encoding="utf-8")
            invalid = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(release)],
                                     text=True, capture_output=True, check=False)
            self.assertNotEqual(invalid.returncode, 0)
            self.assertFalse(sentinel.exists())


if __name__ == "__main__":
    unittest.main()
