"""Contrat commun des déclarations APT après migration des anciennes variables."""

import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / "modules/diu/variables/softwares"


class SoftwareGlobalContract:
    software = ""

    def test_legacy_declaration_is_disabled_and_cleans_only_its_variable(self):
        suffix = self.software.replace("-", "_")
        source = DIRECTORY / f"software_apt_{suffix}.sh"
        text = source.read_text(encoding="utf-8")
        self.assertIn('state="DISABLE"', text)
        old = f"SOFTWARES_APT_{suffix.upper()}"
        new = f"SOFTWARE_APT_{suffix.upper()}"
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            folder = Path(directory)
            config = folder / "softwares.env"
            script = folder / "declaration.sh"
            script.write_text(text.replace('variable_config_file="/root/diu/config/${scope}.env"',
                                           'variable_config_file="$TEST_CONFIG"'), encoding="utf-8")
            config.write_text(f"export {old}=1\nexport {new}=0\n", encoding="utf-8")
            env = dict(os.environ, TEST_CONFIG=str(config), TEST_SCRIPT=str(script))
            result = subprocess.run(["bash", "-c", 'set -Eeuo pipefail; source "$TEST_SCRIPT"'],
                                    env=env, capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(config.read_text(encoding="utf-8"), f"export {new}=0\n")

    def test_catalog_maps_the_software_to_its_new_variable(self):
        expected = "SOFTWARE_APT_" + self.software.replace("-", "_").upper()
        script = 'source "$1/modules/softwares/apt-convergence.sh"; software_apt_convergence_variable "$2"'
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT), self.software],
                                capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), expected)
