import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / "modules/diu/variables/softwares"


class SoftwareGlobalTransitionTests(unittest.TestCase):
    def test_all_apt_declarations_initialize_once_and_retire_legacy(self):
        for new in sorted(DIRECTORY.glob("desired_apt_*.sh")):
            name = new.stem.removeprefix("desired_apt_")
            old = DIRECTORY / f"software_apt_{name}.sh"
            with self.subTest(software=name), tempfile.TemporaryDirectory(dir=ROOT) as folder:
                directory = Path(folder)
                config = directory / "softwares.env"
                old_script = directory / "old.sh"
                new_script = directory / "new.sh"
                old_text = old.read_text(encoding="utf-8")
                self.assertIn('state="DISABLE"', old_text)
                replacement = 'variable_config_file="$TEST_CONFIG"'
                target = 'variable_config_file="/root/diu/config/${scope}.env"'
                old_script.write_text(old_text.replace(target, replacement), encoding="utf-8")
                new_script.write_text(new.read_text(encoding="utf-8").replace(target, replacement), encoding="utf-8")
                env = dict(os.environ, TEST_CONFIG=str(config), TEST_OLD=str(old_script),
                           TEST_NEW=str(new_script), TEST_ROOT=str(ROOT))
                for key in list(env):
                    if key.startswith(("SOFTWARE_APT_", "SOFTWARES_APT_")):
                        del env[key]
                script = r'''
set -Eeuo pipefail
source "$TEST_ROOT/modules/softwares/bootstrap.sh"
software_load_convergence_modules "$TEST_ROOT"
software_apt_convergence_detect() { printf '%s\n' "$ACTUAL"; }
ACTUAL=1
source "$TEST_NEW"
ACTUAL=0
source "$TEST_NEW"
source "$TEST_OLD"
[[ "$(grep -c '^export SOFTWARE_APT_' "$TEST_CONFIG")" == 1 ]]
grep -qx "export SOFTWARE_APT_${1^^}=1" "$TEST_CONFIG"
'''
                result = subprocess.run(["bash", "-c", script, "--", name], env=env,
                                        text=True, capture_output=True, check=False)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
