import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/desired-state.sh"
VARIABLE = "SOFTWARE_GITHUB_CODEX_CLI"


class SoftwareDesiredStateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".software-desired-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def write_state(self, value="1", variable=VARIABLE):
        return subprocess.run(
            ["bash", "-c", 'source "$1"; software_write_desired_state "$2" "$3" "$4"',
             "--", str(MODULE), str(self.config), variable, value],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_create_is_private_and_idempotent(self):
        self.assertEqual(self.write_state().returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export {VARIABLE}=1\n")
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        inode = self.config.stat().st_ino
        self.assertEqual(self.write_state().returncode, 0)
        self.assertEqual(self.config.stat().st_ino, inode)

    def test_update_preserves_other_settings_and_mode(self):
        self.config.write_text(f"export OTHER=example\nexport {VARIABLE}=0\n", encoding="utf-8")
        self.config.chmod(0o600)
        self.assertEqual(self.write_state().returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export OTHER=example\nexport {VARIABLE}=1\n")
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)

    def test_invalid_existing_data_is_never_overwritten(self):
        for data in (f'export {VARIABLE}="1"\n', f"export {VARIABLE}=0\nexport {VARIABLE}=1\n"):
            with self.subTest(data=data):
                self.config.write_text(data, encoding="utf-8")
                self.assertNotEqual(self.write_state().returncode, 0)
                self.assertEqual(self.config.read_text(encoding="utf-8"), data)

    def test_invalid_name_value_or_symlink_is_rejected(self):
        self.assertNotEqual(self.write_state(variable="OTHER").returncode, 0)
        self.assertNotEqual(self.write_state(value="2").returncode, 0)
        destination = Path(self.directory.name) / "target"
        destination.write_text("unchanged\n", encoding="utf-8")
        os.symlink(destination, self.config)
        self.assertNotEqual(self.write_state().returncode, 0)
        self.assertEqual(destination.read_text(encoding="utf-8"), "unchanged\n")

    def test_concurrent_write_is_not_overwritten(self):
        self.config.write_text(f"export {VARIABLE}=0\n", encoding="utf-8")
        script = (
            'source "$1"\n'
            'cmp() { printf "external change\\n" >> "$4"; command cmp "$@"; }\n'
            'software_write_desired_state "$2" "$3" 1'
        )
        result = subprocess.run(
            ["bash", "-c", script, "--", str(MODULE), str(self.config), VARIABLE],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export {VARIABLE}=0\nexternal change\n")

    def test_noop_also_detects_concurrent_change(self):
        self.config.write_text(f"export {VARIABLE}=1\n", encoding="utf-8")
        script = (
            'source "$1"\n'
            'cmp() { printf "external change\\n" >> "$4"; command cmp "$@"; }\n'
            'software_write_desired_state "$2" "$3" 1'
        )
        result = subprocess.run(
            ["bash", "-c", script, "--", str(MODULE), str(self.config), VARIABLE],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export {VARIABLE}=1\nexternal change\n")

    def test_declaration_defers_unknown_real_state_without_creating_a_value(self):
        script = (
            'source "$1"\n'
            'detect() { return 1; }\n'
            'software_declare_one "$2" demo SOFTWARE_APT_DEMO detect || exit $?\n'
            '[[ ! -v SOFTWARE_APT_DEMO ]]'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("différée", result.stderr)
        self.assertFalse(self.config.exists())

    def test_declaration_persists_an_existing_environment_value(self):
        script = (
            'source "$1"\n'
            'SOFTWARE_APT_DEMO=1\n'
            'detect() { echo unexpected; return 1; }\n'
            'software_declare_one "$2" demo SOFTWARE_APT_DEMO detect'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_DEMO=1\n")


if __name__ == "__main__":
    unittest.main()
