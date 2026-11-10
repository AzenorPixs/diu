import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class FlatpakConvergenceTests(unittest.TestCase):
    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'source "$1/modules/softwares/flatpak-convergence.sh"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            'print_info() { printf "%s\\n" "$*"; }\n'
            'print_success() { printf "%s\\n" "$*"; }\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_install_and_remove_convergence(self):
        for initial, desired, action in ((0, 1, "install"), (1, 0, "uninstall")):
            with self.subTest(initial=initial, desired=desired):
                result = self.run_shell(
                    f'installed={initial}\n'
                    'flatpak() { case "$1" in\n'
                    '  list) [[ "$installed" == 1 ]] && printf "org.example.App\\n"; return 0;;\n'
                    '  remotes) printf "flathub\\n";;\n'
                    '  info) [[ "$installed" == 1 ]];;\n'
                    '  install) echo install; installed=1;;\n'
                    '  uninstall) echo uninstall; installed=0;;\n'
                    'esac; }\n'
                    f'software_flatpak_converge org.example.App {desired}'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(action, result.stdout)
                self.assertIn(f"état réel {desired}, conforme", result.stdout)

    def test_failed_listing_does_not_install_or_remove(self):
        result = self.run_shell(
            'flatpak() { [[ "$1" == list ]] && return 1; echo unexpected; }\n'
            'software_flatpak_converge org.example.App 1'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
