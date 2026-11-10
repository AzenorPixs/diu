import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/crowdsec-state.sh"


class CrowdsecStateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".crowdsec-state-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.bouncers = self.base / "etc/crowdsec/bouncers"
        self.bouncers.mkdir(parents=True)
        self.config = self.bouncers / "crowdsec-firewall-bouncer.yaml"
        self.config.write_text("api_url: http://127.0.0.1:8080/\n", encoding="utf-8")

    def detect(self, package="1", agent="1"):
        script = (
            'source "$1"\n'
            'fixture_package="$3"; fixture_agent="$4"\n'
            'software_apt_package_state() { printf "%s\\n" "$fixture_package"; }\n'
            'software_apt_crowdsec_agent_detect() { printf "%s\\n" "$fixture_agent"; }\n'
            'software_apt_crowdsec_bouncer_role_detect "$2"'
        )
        return subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.base), package, agent],
                              text=True, capture_output=True, check=False)

    def test_agent_dependency_is_not_a_standalone_role(self):
        result = self.detect()
        self.assertEqual((result.returncode, result.stdout), (0, "0\n"))

    def test_quoted_local_url_is_also_detected_as_agent_dependency(self):
        self.config.write_text('api_url: "http://127.0.0.1:8080/"\n', encoding="utf-8")
        result = self.detect()
        self.assertEqual((result.returncode, result.stdout), (0, "0\n"))

    def test_explicit_standalone_role_is_detected_even_with_agent(self):
        (self.bouncers / ".diu-standalone-enabled").write_text("1\n", encoding="utf-8")
        result = self.detect()
        self.assertEqual((result.returncode, result.stdout), (0, "1\n"))

    def test_bouncer_without_agent_is_present(self):
        result = self.detect(agent="0")
        self.assertEqual((result.returncode, result.stdout), (0, "1\n"))

    def test_ambiguous_configuration_is_not_reported_as_absent(self):
        self.config.write_text("api_url: http://one.invalid/\napi_url: http://two.invalid/\n", encoding="utf-8")
        result = self.detect()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
