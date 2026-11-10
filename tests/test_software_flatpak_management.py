import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class FlatpakManagementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".flatpak-management-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'source "$1/modules/softwares/flatpak-convergence.sh"\n'
            'source "$1/modules/softwares/flatpak-inventory.sh"\n'
            'source "$1/modules/softwares/flatpak-management.sh"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            'print_info() { printf "%s\\n" "$*"; }\n'
            'print_success() { printf "%s\\n" "$*"; }\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), str(self.config)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_first_update_initializes_from_actual_state_without_installing(self):
        result = self.run_shell(
            'flatpak() { case "$1" in list) printf "org.example.App\\n";; '
            '*) echo unexpected; return 1;; esac; }\n'
            'software_flatpak_manage_one "$2" update org.example.App'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)
        self.assertIn("=1\n", self.config.read_text(encoding="utf-8"))

    def test_failed_install_keeps_desired_state(self):
        result = self.run_shell(
            'flatpak() { case "$1" in list) return 0;; remotes) printf "flathub\\n";; '
            'info) return 1;; install) return 1;; esac; }\n'
            'software_flatpak_manage_one "$2" install org.example.App'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("=1\n", self.config.read_text(encoding="utf-8"))

    def test_unknown_actual_state_does_not_initialize(self):
        result = self.run_shell(
            'flatpak() { return 1; }\n'
            'software_flatpak_manage_one "$2" update org.example.App'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.config.exists())

    def test_first_initialization_never_overwrites_existing_config(self):
        variable = "SOFTWARE_FLATPAK_X" + "org.example.App".encode().hex().upper()
        data = f"export {variable}=1\n"
        self.config.write_text(data, encoding="utf-8")
        result = self.run_shell(
            'flatpak() { return 0; }\n'
            'software_flatpak_manage_one "$2" update org.example.App'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)

    def test_global_update_decodes_each_managed_variable(self):
        first = "SOFTWARE_FLATPAK_X" + "org.example.App".encode().hex().upper()
        second = "SOFTWARE_FLATPAK_X" + "org.example.Other".encode().hex().upper()
        self.config.write_text(f"export {first}=1\nexport {second}=1\n", encoding="utf-8")
        result = self.run_shell(
            'flatpak() { [[ "$1" == list ]] && printf "org.example.App\\norg.example.Other\\n"; return 0; }\n'
            'first="$(software_flatpak_variable_name org.example.App)"\n'
            'second="$(software_flatpak_variable_name org.example.Other)"\n'
            'printf -v "$first" 1; printf -v "$second" 1\n'
            'software_flatpak_manage_all "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("org.example.App : état réel 1, conforme", result.stdout)
        self.assertIn("org.example.Other : état réel 1, conforme", result.stdout)

    def test_invalid_registry_entry_is_reported(self):
        result = self.run_shell(
            'SOFTWARE_FLATPAK_X00=1\n'
            'flatpak() { echo unexpected; }\n'
            'software_flatpak_manage_all "$2"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
