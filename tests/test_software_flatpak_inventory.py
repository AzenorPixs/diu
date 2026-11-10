import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class FlatpakInventoryTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".flatpak-inventory-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'source "$1/modules/softwares/flatpak-inventory.sh"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                              text=True, capture_output=True, check=False)

    def test_initial_inventory_is_persisted_once_without_mutations(self):
        result = self.run_shell(
            'apps="org.example.App"\n'
            'flatpak() { [[ "$1" == list ]] || { echo unexpected; return 1; }; printf "%s\\n" "$apps"; }\n'
            'software_flatpak_inventory_initialize "$2" || exit $?\n'
            'apps="org.example.Other"\n'
            'software_flatpak_inventory_initialize "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        content = self.config.read_text(encoding="utf-8")
        first = "SOFTWARE_FLATPAK_X" + "org.example.App".encode().hex().upper()
        second = "SOFTWARE_FLATPAK_X" + "org.example.Other".encode().hex().upper()
        self.assertIn(f"export {first}=1\n", content)
        self.assertNotIn(second, content)
        self.assertEqual(content.count("# DIU_FLATPAK_INVENTORY_INITIALIZED=1"), 1)
        self.assertNotIn("unexpected", result.stdout)

    def test_unavailable_inventory_does_not_mark_or_create_config(self):
        result = self.run_shell(
            'flatpak() { return 1; }\n'
            'software_flatpak_inventory_initialize "$2"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.config.exists())

    def test_invalid_inventory_does_not_mark_initialization(self):
        result = self.run_shell(
            'flatpak() { printf "not-a-valid-id\\n"; }\n'
            'software_flatpak_inventory_initialize "$2"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.config.exists())

    def test_duplicate_marker_is_rejected_without_mutation(self):
        data = "# DIU_FLATPAK_INVENTORY_INITIALIZED=1\n" * 2
        self.config.write_text(data, encoding="utf-8")
        result = self.run_shell('software_flatpak_inventory_initialize "$2"')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)


if __name__ == "__main__":
    unittest.main()
