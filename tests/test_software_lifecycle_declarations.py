import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SoftwareLifecycleDeclarationsTests(unittest.TestCase):
    def test_all_apt_recipes_expose_own_configuration_and_cleanup(self):
        script = r'''
set -eu
source "$1/modules/softwares/apt-convergence.sh"
while IFS= read -r name; do
    configuration="$(software_apt_recipe "$name" configuration_hook)"
    cleanup="$(software_apt_recipe "$name" cleanup_hook)"
    [[ "$configuration" == "software_apt_configure_${name//-/_}" ]]
    [[ "$cleanup" == "software_apt_cleanup_${name//-/_}" ]]
    declare -F "$configuration" >/dev/null
    declare -F "$cleanup" >/dev/null
done < <(software_apt_recipe_names)
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_converged_crowdsec_does_not_refresh_or_restart(self):
        script = r'''
set -eu
SOFTWARE_GLOBAL_DECLARATIONS_ONLY=1
source "$1/modules/diu/variables/softwares/desired_apt_crowdsec_agent.sh"
software_apt_check_crowdsec_agent_configuration() { return 0; }
cscli() { echo unexpected; return 1; }
systemctl() { echo unexpected; return 1; }
service() { echo unexpected; return 1; }
software_apt_configure_crowdsec_agent
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")

    def test_converged_ssh_and_postfix_do_not_restart(self):
        script = r'''
set -eu
SOFTWARE_GLOBAL_DECLARATIONS_ONLY=1
source "$1/modules/diu/variables/softwares/desired_apt_ssh_server.sh"
source "$1/modules/diu/variables/softwares/desired_apt_postfix.sh"
software_apt_check_ssh_server_configuration() { return 0; }
software_apt_check_postfix_configuration() { return 0; }
systemctl() { echo unexpected; return 1; }
service() { echo unexpected; return 1; }
software_apt_configure_ssh_server
software_apt_configure_postfix
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
