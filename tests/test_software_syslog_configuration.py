import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "modules/softwares/syslog_configuration.py"


class SyslogConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".syslog-config-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.etc = self.base / "etc"
        self.managed = self.etc / "rsyslog.d"
        self.managed.mkdir(parents=True)
        self.main = self.etc / "rsyslog.conf"
        self.main.write_text('$IncludeConfig /etc/rsyslog.d/*.conf\n', encoding="utf-8")
        self.existing = self.managed / "50-user.conf"
        self.existing.write_text("# personal settings\n", encoding="utf-8")
        self.ulogd = self.etc / "ulogd.conf"
        self.ulogd.write_text(
            "#stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG\n"
            "[sys2]\nfacility=LOG_LOCAL1\n[other]\nfacility=keep\n", encoding="utf-8"
        )
        binary = self.base / "bin"
        binary.mkdir()
        for name, body in (("rsyslogd", 'exit "${FAIL_VALIDATE:-0}"'),
                           ("service", 'exit "${FAIL_RESTART:-0}"')):
            path = binary / name
            path.write_text("#!/bin/sh\n" + body + "\n", encoding="utf-8")
            path.chmod(0o700)
        self.environment = dict(os.environ, PATH=f"{binary}:{os.environ.get('PATH', '')}",
                                SYSLOG_CLIENT_SERVER="logs.example.invalid", SYSLOG_SERVER_SKIL_KERNEL="1",
                                SYSLOG_SERVER_SKIL_OMADA="1", SYSLOG_SERVER_SKIL_SSO="1",
                                SYSLOG_SERVER_SKIL_SURICATA="1", HOSTNAME="server-example")

    def run_helper(self, action, role, mode="keep-package", **extra):
        return subprocess.run([sys.executable, "-B", str(HELPER), action, role, mode, str(self.base)],
                              env=dict(self.environment, **extra), text=True, capture_output=True, check=False)

    def test_client_and_server_coexist_and_preserve_other_files(self):
        server = self.run_helper("configure", "server")
        self.assertEqual(server.returncode, 0, server.stderr)
        client = self.run_helper("configure", "client")
        self.assertEqual(client.returncode, 0, client.stderr)
        server_file = self.managed / "40-diu-server.conf"
        client_file = self.managed / "40-diu-client.conf"
        self.assertIn('ruleset="diu_server_remote"', server_file.read_text(encoding="utf-8"))
        self.assertIn("logs.example.invalid", client_file.read_text(encoding="utf-8"))
        self.assertEqual(self.existing.read_text(encoding="utf-8"), "# personal settings\n")
        self.assertIn("[other]\nfacility=keep\n", self.ulogd.read_text(encoding="utf-8"))
        self.assertEqual(self.run_helper("check", "client").returncode, 0)
        self.assertEqual(self.run_helper("check", "server").returncode, 0)

    def test_failed_validation_restores_configuration(self):
        before = self.ulogd.read_bytes()
        result = self.run_helper("configure", "client", FAIL_VALIDATE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.managed / "40-diu-client.conf").exists())
        self.assertEqual(self.ulogd.read_bytes(), before)

    def test_failed_restart_restores_files_and_reports_failed_recovery(self):
        before = self.ulogd.read_bytes()
        result = self.run_helper("configure", "client", FAIL_RESTART="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.managed / "40-diu-client.conf").exists())
        self.assertEqual(self.ulogd.read_bytes(), before)
        self.assertIn("redémarrage après restauration échoué", result.stderr)

    def test_unmanaged_client_is_preserved_on_role_only_removal(self):
        self.main.write_text('$IncludeConfig /etc/rsyslog.d/*.conf\n*.* @logs.example.invalid:514\n', encoding="utf-8")
        before = self.main.read_bytes()
        result = self.run_helper("remove", "client")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.main.read_bytes(), before)

    def test_unmanaged_role_is_preserved_when_package_is_being_removed(self):
        self.main.write_text('$IncludeConfig /etc/rsyslog.d/*.conf\n*.* @logs.example.invalid:514\n', encoding="utf-8")
        before = self.main.read_bytes()
        result = self.run_helper("remove", "client", "remove-package")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.main.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
