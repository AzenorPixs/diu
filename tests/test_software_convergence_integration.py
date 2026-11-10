import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SoftwareConvergenceIntegrationTests(unittest.TestCase):
    def test_empty_installation_initializes_and_repeats_without_mutations(self):
        with tempfile.TemporaryDirectory(prefix=".software-integration-test-", dir=ROOT) as directory:
            config = Path(directory) / "softwares.conf"
            script = r'''
set -Eeuo pipefail
source "$1/modules/softwares/convergence.sh"
source "$1/modules/softwares/desired-state.sh"
source "$1/modules/softwares/apt-state.sh"
source "$1/modules/softwares/apt-configuration.sh"
source "$1/modules/softwares/shared-resource.sh"
source "$1/modules/softwares/crowdsec-state.sh"
source "$1/modules/softwares/crowdsec-hooks.sh"
source "$1/modules/softwares/syslog-state.sh"
source "$1/modules/softwares/syslog-hooks.sh"
source "$1/modules/softwares/apt-convergence.sh"
source "$1/modules/softwares/apt-management.sh"
source "$1/modules/softwares/flatpak.sh"
source "$1/modules/softwares/flatpak-state.sh"
source "$1/modules/softwares/flatpak-convergence.sh"
source "$1/modules/softwares/flatpak-inventory.sh"
source "$1/modules/softwares/flatpak-management.sh"
source "$1/modules/softwares/github-state.sh"
source "$1/modules/softwares/github-convergence.sh"
source "$1/modules/softwares/github-management.sh"
source "$1/modules/softwares/dispatch.sh"
print_error() { printf '%s\n' "$*" >&2; }
SYSTEM_APT_ENGINE=1; SYSTEM_FLATPAK_ENGINE=1; SYSTEM_GITHUB_ENGINE=1
SYSTEM_DEBIAN_RELEASE=trixie
dpkg-query() { return 0; }
flatpak() { [[ "$1" == list ]] && return 0; echo unexpected; return 1; }
software_github_codex_cli_detect() { printf '0\n'; }
apt() { echo unexpected; return 1; }
software_github_install() { echo unexpected; return 1; }
software_github_remove() { echo unexpected; return 1; }
software_dispatch "$2" update
software_dispatch "$2" update
'''
            environment = {key: value for key, value in os.environ.items()
                           if not key.startswith(("SOFTWARE_APT_", "SOFTWARE_FLATPAK_", "SOFTWARE_GITHUB_"))}
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    env=environment, text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("unexpected", result.stdout)
            self.assertLess(result.stdout.index("apache2"), result.stdout.index("Aucune application Flatpak"))
            self.assertLess(result.stdout.index("Aucune application Flatpak"), result.stdout.index("codex-cli"))
            content = config.read_text(encoding="utf-8")
            self.assertIn("export SOFTWARE_APT_JSVC=0\n", content)
            self.assertIn("export SOFTWARE_GITHUB_CODEX_CLI=0\n", content)
            self.assertEqual(content.count("# DIU_FLATPAK_INVENTORY_INITIALIZED=1"), 1)
            self.assertNotIn("SOFTWARES_APT_", content)


if __name__ == "__main__":
    unittest.main()
