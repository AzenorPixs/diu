#!/usr/bin/env python3
"""Tests isolés du moteur Flatpak du module system."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = ROOT / "modules/diu/variables/system/system_flatpak.sh"


class SystemFlatpakTests(unittest.TestCase):
    def run_declaration(self, code, **variables):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            env = dict(os.environ, DECLARATION=str(DECLARATION), TMPDIR=directory,
                       **variables)
            env.pop("SYSTEM_FLATPAK", None)
            return subprocess.run(["bash", "-c", "set -Eeuo pipefail\n" + code],
                                  env=env, text=True, capture_output=True)

    def run_engine(self, code, **variables):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            calls = Path(directory) / "calls"
            env = dict(os.environ, ROOT=str(ROOT), TMPDIR=directory,
                       CALLS=str(calls), **variables)
            result = subprocess.run(["bash", "-c", ENGINE_PRELUDE + "\n" + code],
                                    env=env, text=True, capture_output=True)
            return result, calls.read_text() if calls.exists() else ""

    def test_detection_and_persistence(self):
        for package_state, expected in (("installed", "1"), ("absent", "0"),
                                        ("error", "UNSET")):
            with self.subTest(package_state=package_state):
                result = self.run_declaration(r'''
variable_source="$TMPDIR/system_flatpak.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/system.env\"#" \
    "$DECLARATION" > "$variable_source"
dpkg-query() {
    case "$PACKAGE_STATE" in
        installed) printf installed ;;
        absent) return 1 ;;
        error) return 2 ;;
    esac
}
source "$variable_source"
[[ "$SYSTEM_FLATPAK" == "$EXPECTED" ]]
grep -Fx "export SYSTEM_FLATPAK=$EXPECTED" "$TMPDIR/system.env"
''', PACKAGE_STATE=package_state, EXPECTED=expected)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_existing_value_is_preserved_and_invalid_value_fails(self):
        result = self.run_declaration(r'''
variable_source="$TMPDIR/system_flatpak.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/system.env\"#" \
    "$DECLARATION" > "$variable_source"
SYSTEM_FLATPAK=UNSET
dpkg-query() { return 2; }
source "$variable_source"
[[ "$SYSTEM_FLATPAK" == UNSET && ! -e "$TMPDIR/system.env" ]]
SYSTEM_FLATPAK=invalid
if source "$variable_source"; then exit 1; fi
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("valeur invalide", result.stderr)

    def test_install_remove_update_and_apply_are_isolated(self):
        result, calls = self.run_engine(r'''
PACKAGE_STATE=absent
system_flatpak_install
grep -Fx 'export SYSTEM_FLATPAK=1' "$SYSTEM_FLATPAK_CONFIG_FILE"
PACKAGE_STATE=installed
system_flatpak_remove
grep -Fx 'export SYSTEM_FLATPAK=0' "$SYSTEM_FLATPAK_CONFIG_FILE"
PACKAGE_STATE=installed
system_flatpak_update
SYSTEM_FLATPAK=UNSET
system_flatpak_apply
! grep -q 'flatpak update' "$CALLS"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("apt-get install -y -- flatpak", calls)
        self.assertIn("flatpak remote-add --if-not-exists flathub", calls)
        self.assertIn("apt-get remove -y -- flatpak", calls)
        self.assertIn("apt-get install --only-upgrade -y -- flatpak", calls)
        self.assertNotIn("flatpak update", calls)

    def test_failures_do_not_persist_enabled_state(self):
        result, _ = self.run_engine(r'''
printf 'export SYSTEM_FLATPAK=0\n' > "$SYSTEM_FLATPAK_CONFIG_FILE"
PACKAGE_STATE=absent
APT_FAILURE=1
if system_flatpak_install; then exit 1; fi
grep -Fx 'export SYSTEM_FLATPAK=0' "$SYSTEM_FLATPAK_CONFIG_FILE"
! grep -Fx 'export SYSTEM_FLATPAK=1' "$SYSTEM_FLATPAK_CONFIG_FILE"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

        result, _ = self.run_engine(r'''
printf 'export SYSTEM_FLATPAK=0\n' > "$SYSTEM_FLATPAK_CONFIG_FILE"
PACKAGE_STATE=installed
FLATPAK_FAILURE=1
if system_flatpak_install; then exit 1; fi
grep -Fx 'export SYSTEM_FLATPAK=0' "$SYSTEM_FLATPAK_CONFIG_FILE"
! grep -Fx 'export SYSTEM_FLATPAK=1' "$SYSTEM_FLATPAK_CONFIG_FILE"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_apply_converges_all_states_idempotently(self):
        result, calls = self.run_engine(r'''
PACKAGE_STATE=absent
SYSTEM_FLATPAK=1
system_flatpak_apply
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("apt-get install -y -- flatpak", calls)

        result, calls = self.run_engine(r'''
PACKAGE_STATE=installed
SYSTEM_FLATPAK=0
system_flatpak_apply
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ["apt-get remove -y -- flatpak"])

        result, calls = self.run_engine(r'''
PACKAGE_STATE=absent
SYSTEM_FLATPAK=UNSET
system_flatpak_apply
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls, "")

        result, calls = self.run_engine(r'''
PACKAGE_STATE=installed
system_flatpak_install
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("apt-get", calls)

    def test_update_absent_and_routing(self):
        result, calls = self.run_engine(r'''
PACKAGE_STATE=absent
manage_system_action update flatpak
manage_system_action install flatpak
PACKAGE_STATE=installed
manage_system_action remove flatpak
if manage_system_action install flatpak extra; then exit 1; fi
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Flatpak est absent", result.stdout)
        self.assertNotIn("--only-upgrade", calls)
        self.assertIn("apt-get install -y -- flatpak", calls)
        self.assertIn("apt-get remove -y -- flatpak", calls)

    def test_help_includes_flatpak_commands(self):
        for arguments in (("system", "help"), ("system", "install", "help"),
                          ("system", "remove", "flatpak", "help"),
                          ("system", "update", "flatpak", "help")):
            result = subprocess.run(["bash", str(ROOT / "root-install-debian.sh"), *arguments],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("flatpak", result.stdout.lower())


ENGINE_PRELUDE = r'''
set -Eeuo pipefail
print_error() { printf 'ERROR %s\n' "$*" >&2; }
print_info() { printf 'INFO %s\n' "$*"; }
apt-get() { printf 'apt-get %s\n' "$*" >> "$CALLS"; return "${APT_FAILURE:-0}"; }
flatpak() { printf 'flatpak %s\n' "$*" >> "$CALLS"; return "${FLATPAK_FAILURE:-0}"; }
dpkg-query() {
    case "${PACKAGE_STATE:-absent}" in
        installed) printf installed ;;
        absent) return 1 ;;
        error) return 2 ;;
    esac
}
SYSTEM_FLATPAK_CONFIG_FILE="$TMPDIR/system.env"
source "$ROOT/modules/system/apt.sh"
'''


if __name__ == "__main__":
    unittest.main()
