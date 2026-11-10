import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class FlatpakStateTests(unittest.TestCase):
    def run_detector(self, applications, status=0, software="org.example.App"):
        script = (
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'test_apps="$2"; test_status="$3"; software="$4"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            'flatpak() { printf "%s" "$test_apps"; return "$test_status"; }\n'
            'software_flatpak_application_state "$software"'
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), applications, str(status), software],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_present_and_absent_are_distinguished(self):
        for apps, expected in (("org.example.App\n", "1"), ("org.example.Other\n", "0")):
            with self.subTest(apps=apps):
                result = self.run_detector(apps)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)

    def test_failed_listing_is_not_absence(self):
        result = self.run_detector("", status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")

    def test_invalid_identifier_is_rejected(self):
        result = self.run_detector("", software="--system")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")

    def test_variable_names_are_distinct_and_each_application_has_a_detector(self):
        script = (
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            'flatpak() { printf "org.example.App-A\\n"; }\n'
            'software_flatpak_register_detector org.example.App-A || exit 1\n'
            'software_flatpak_register_detector org.example.App_A || exit 1\n'
            'name_a="$(software_flatpak_variable_name org.example.App-A)"\n'
            'name_b="$(software_flatpak_variable_name org.example.App_A)"\n'
            '[[ "$name_a" != "$name_b" ]] || exit 1\n'
            'detect_a="$(software_flatpak_detector_name org.example.App-A)"\n'
            'detect_b="$(software_flatpak_detector_name org.example.App_A)"\n'
            '"$detect_a"; "$detect_b"'
        )
        result = subprocess.run(
            ["bash", "-c", script, "--", str(ROOT)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "1\n0\n")

    def test_malicious_identifier_does_not_register_a_function(self):
        script = (
            'source "$1/modules/softwares/flatpak.sh"\n'
            'source "$1/modules/softwares/flatpak-state.sh"\n'
            'print_error() { printf "%s\\n" "$*" >&2; }\n'
            'software_flatpak_register_detector "$2"'
        )
        result = subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), "org.example.App';echo INJECTED;#"],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("INJECTED\n", result.stdout)


if __name__ == "__main__":
    unittest.main()
