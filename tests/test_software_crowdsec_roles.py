import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class CrowdsecRolesTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".crowdsec-roles-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def run_shell(self, body):
        script = (
            'set -Eeuo pipefail\n'
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/shared-resource.sh"\n'
            'source "$1/modules/softwares/apt-state.sh"\n'
            'source "$1/modules/softwares/crowdsec-state.sh"\n'
            'source "$1/modules/softwares/crowdsec-hooks.sh"\n'
            'source "$1/modules/softwares/apt-convergence.sh"\n'
            'source "$1/modules/softwares/apt-management.sh"\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                              text=True, capture_output=True, check=False)

    def test_disabling_standalone_bouncer_keeps_agent_dependency(self):
        self.config.write_text("export SOFTWARE_APT_CROWDSEC_AGENT=1\nexport SOFTWARE_APT_CROWDSEC_BOUNCER=1\n", encoding="utf-8")
        result = self.run_shell(
            'SOFTWARE_APT_CROWDSEC_AGENT=1; SOFTWARE_APT_CROWDSEC_BOUNCER=1; role_state=1\n'
            'software_apt_crowdsec_agent_detect() { echo 1; }\n'
            'software_apt_crowdsec_bouncer_role_detect() { echo "$role_state"; }\n'
            'software_apt_crowdsec_helper() { [[ "$1:$2" == disable-bouncer:local ]] || return 1; role_state=0; }\n'
            'service() { :; }; apt() { echo unexpected; }; apt-get() { echo unexpected; }\n'
            'software_apt_manage_one "$2" remove crowdsec-bouncer'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)
        self.assertIn("export SOFTWARE_APT_CROWDSEC_BOUNCER=0\n", self.config.read_text(encoding="utf-8"))

    def test_removing_agent_preserves_enabled_bouncer_by_switching_first(self):
        self.config.write_text("export SOFTWARE_APT_CROWDSEC_BOUNCER=1\n", encoding="utf-8")
        result = self.run_shell(
            'software_management_config="$2"; SOFTWARE_APT_CROWDSEC_BOUNCER=1\n'
            'software_apt_configure_crowdsec_bouncer() { echo "configure $1"; }\n'
            'apt-get() { printf "Remv crowdsec [1]\\n"; }\n'
            'apt() { echo "apt $*"; }\n'
            'software_apt_remove crowdsec-agent'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(result.stdout.index("configure remote"), result.stdout.index("apt -y remove"))


if __name__ == "__main__":
    unittest.main()
