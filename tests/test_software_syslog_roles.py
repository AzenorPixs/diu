import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SyslogRolesTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".syslog-roles-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"
        self.config.write_text("export SOFTWARE_APT_SYSLOG_CLIENT=1\nexport SOFTWARE_APT_SYSLOG_SERVER=1\n", encoding="utf-8")

    def run_shell(self, body):
        script = (
            'set -Eeuo pipefail\n'
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/shared-resource.sh"\n'
            'source "$1/modules/softwares/apt-state.sh"\n'
            'source "$1/modules/softwares/syslog-state.sh"\n'
            'source "$1/modules/softwares/syslog-hooks.sh"\n'
            'source "$1/modules/softwares/apt-convergence.sh"\n'
            'source "$1/modules/softwares/apt-management.sh"\n'
            'SOFTWARE_APT_SYSLOG_CLIENT=1; SOFTWARE_APT_SYSLOG_SERVER=1\n'
            'fixture_package_state=1; client_state=1; server_state=1\n'
            'software_apt_package_state() { echo "$fixture_package_state"; }\n'
            'software_apt_syslog_client_detect() { [[ "$fixture_package_state" == 0 ]] && echo 0 || echo "$client_state"; }\n'
            'software_apt_syslog_server_detect() { [[ "$fixture_package_state" == 0 ]] && echo 0 || echo "$server_state"; }\n'
            'software_apt_syslog_helper() { case "$2" in client) client_state=0;; server) server_state=0;; esac; }\n'
            'apt-get() { printf "Remv rsyslog [1]\\n"; }\n'
            'apt() { echo "apt $*"; fixture_package_state=0; }\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                              text=True, capture_output=True, check=False)

    def test_disabling_client_preserves_package_for_server(self):
        result = self.run_shell('software_apt_manage_one "$2" remove syslog-client')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("apt -y remove", result.stdout)
        self.assertIn("export SOFTWARE_APT_SYSLOG_SERVER=1\n", self.config.read_text(encoding="utf-8"))

    def test_last_role_removal_removes_shared_package(self):
        result = self.run_shell(
            'software_apt_manage_one "$2" remove syslog-client || exit $?\n'
            'software_apt_manage_one "$2" remove syslog-server'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y remove -- rsyslog", result.stdout)
        content = self.config.read_text(encoding="utf-8")
        self.assertIn("export SOFTWARE_APT_SYSLOG_CLIENT=0\n", content)
        self.assertIn("export SOFTWARE_APT_SYSLOG_SERVER=0\n", content)

    def test_local_only_rsyslog_is_not_removed_when_both_roles_are_absent(self):
        self.config.write_text("export SOFTWARE_APT_SYSLOG_CLIENT=0\nexport SOFTWARE_APT_SYSLOG_SERVER=0\n", encoding="utf-8")
        result = self.run_shell(
            'SOFTWARE_APT_SYSLOG_CLIENT=0; SOFTWARE_APT_SYSLOG_SERVER=0\n'
            'client_state=0; server_state=0\n'
            'software_apt_manage_one "$2" update syslog-client || exit $?\n'
            'software_apt_manage_one "$2" update syslog-server'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("apt -y remove", result.stdout)


if __name__ == "__main__":
    unittest.main()
