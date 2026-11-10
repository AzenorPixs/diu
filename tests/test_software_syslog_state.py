import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/syslog-state.sh"


class SyslogStateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".syslog-state-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.config = self.base / "etc/rsyslog.conf"
        self.config.parent.mkdir(parents=True)
        self.config.write_text("# default configuration\n", encoding="utf-8")
        (self.base / "etc/rsyslog.d").mkdir()

    def detect(self, role, package="1"):
        script = (
            'source "$1"\n'
            'fixture_package="$3"; software_apt_package_state() { printf "%s\\n" "$fixture_package"; }\n'
            '"$4" "$2"'
        )
        return subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.base), package,
                               f"software_apt_syslog_{role}_detect"],
                              text=True, capture_output=True, check=False)

    def test_client_and_server_roles_are_distinct_on_shared_package(self):
        self.config.write_text('*.* @example.invalid:514\n', encoding="utf-8")
        client = self.detect("client")
        server = self.detect("server")
        self.assertEqual((client.returncode, client.stdout), (0, "1\n"))
        self.assertEqual((server.returncode, server.stdout), (0, "0\n"))
        (self.base / "etc/rsyslog.d/server.conf").write_text('input(type="imudp" port="514")\n', encoding="utf-8")
        server = self.detect("server")
        self.assertEqual((server.returncode, server.stdout), (0, "1\n"))

    def test_missing_package_makes_both_roles_absent(self):
        self.config.write_text('*.* @example.invalid:514\n', encoding="utf-8")
        result = self.detect("client", "0")
        self.assertEqual((result.returncode, result.stdout), (0, "0\n"))

    def test_ambiguous_symlink_is_not_treated_as_absence(self):
        self.config.unlink()
        self.config.symlink_to(self.base / "missing")
        result = self.detect("client")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
