import os
import importlib
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "modules/softwares/crowdsec_configuration.py"


class CrowdsecConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".crowdsec-config-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.agent = self.base / "etc/crowdsec/config.yaml"
        self.bouncer = self.base / "etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml"
        self.bouncer.parent.mkdir(parents=True)
        self.agent.write_text("common:\n  log_dir: /old\napi:\n  listen_uri: 127.0.0.1:8080\n", encoding="utf-8")
        self.bouncer.write_text("api_url: http://127.0.0.1:8080/\napi_key: old\nlog_dir: /old\n"
                                "log_mode: file\ndisable_ipv6: true\n", encoding="utf-8")
        self.secret = "fixture-crowdsec-secret"
        self.environment = dict(os.environ, SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY=self.secret,
                                SOFTWARE_APT_CROWDSEC_BOUNCER_API_URL="https://example.invalid:8080/")

    def run_helper(self, action, mode):
        return subprocess.run([sys.executable, "-B", str(HELPER), action, mode, str(self.base)],
                              env=self.environment, text=True, capture_output=True, check=False)

    def test_agent_configures_local_api_without_exposing_key(self):
        result = self.run_helper("agent", "local")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(self.secret, result.stdout + result.stderr)
        self.assertEqual(stat.S_IMODE(self.bouncer.stat().st_mode), 0o600)
        self.assertIn('api_url: "http://127.0.0.1:8080/"', self.bouncer.read_text(encoding="utf-8"))
        self.assertEqual(self.run_helper("check-agent", "local").returncode, 0)

    def test_standalone_role_is_marked_and_can_be_disabled_without_deleting_shared_package(self):
        self.assertEqual(self.run_helper("bouncer", "remote").returncode, 0)
        marker = self.bouncer.parent / ".diu-standalone-enabled"
        self.assertEqual(marker.read_text(encoding="utf-8"), "1\n")
        self.assertEqual(self.run_helper("check-bouncer", "remote").returncode, 0)
        result = self.run_helper("disable-bouncer", "local")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(marker.exists())
        self.assertIn('api_url: "http://127.0.0.1:8080/"', self.bouncer.read_text(encoding="utf-8"))

    def test_ambiguous_yaml_is_rejected_without_changes_or_secret_output(self):
        self.bouncer.write_text("api_url: http://one.invalid/\napi_url: http://two.invalid/\napi_key: old\n", encoding="utf-8")
        before = self.bouncer.read_bytes()
        result = self.run_helper("bouncer", "remote")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.bouncer.read_bytes(), before)
        self.assertNotIn(self.secret, result.stdout + result.stderr)

    def test_disabling_absent_agent_needs_no_key_or_bouncer_config(self):
        marker = self.bouncer.parent / ".diu-standalone-enabled"
        marker.write_text("1\n", encoding="utf-8")
        self.bouncer.unlink()
        self.environment.pop("SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY")
        result = self.run_helper("disable-bouncer", "absent")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(marker.exists())

    def test_failed_second_publication_restores_first_file(self):
        sys.path.insert(0, str(ROOT / "modules/softwares"))
        self.addCleanup(sys.path.remove, str(ROOT / "modules/softwares"))
        module = importlib.import_module("crowdsec_configuration")
        transaction = importlib.import_module("configuration_transaction")
        before_agent = self.agent.read_bytes()
        before_bouncer = self.bouncer.read_bytes()
        real_replace = os.replace

        def fail_bouncer(source, destination):
            if Path(destination) == self.bouncer:
                raise OSError("simulated publication failure")
            return real_replace(source, destination)

        with mock.patch.dict(os.environ, self.environment), mock.patch.object(transaction.os, "replace", side_effect=fail_bouncer):
            changes = module.plan("agent", "local", self.base)
            with self.assertRaises(OSError):
                transaction.publish(changes)
        self.assertEqual(self.agent.read_bytes(), before_agent)
        self.assertEqual(self.bouncer.read_bytes(), before_bouncer)


if __name__ == "__main__":
    unittest.main()
