#!/usr/bin/env python3
"""Tests isolés de la déclaration dynamique SYSTEM_DEBIAN_RELEASE."""
import os
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = ROOT / "modules/diu/variables/system/system_debian_release.sh"


class SystemDebianReleaseTests(unittest.TestCase):
    def run_shell(self, code, codename="trixie"):
        env = dict(os.environ, DECLARATION=str(DECLARATION), TEST_CODENAME=codename)
        env.pop("SYSTEM_DEBIAN_RELEASE", None)
        return subprocess.run(["bash", "-c", "set -Eeuo pipefail\n" + code],
                              env=env, text=True, capture_output=True)

    def test_releases_and_isolation(self):
        for value in ("trixie", "Bookworm", "BULLSEYE"):
            with self.subTest(value=value):
                result = self.run_shell('''
source() {
    if [[ "$1" == /etc/os-release ]]; then
        VERSION_CODENAME="$TEST_CODENAME"
        ID=changed
    else
        builtin source "$@"
    fi
}
ID=original
source "$DECLARATION"
[[ "$ID" == original && "$scope" == system && "$config" == DYNAMIC && "$state" == ENABLE ]]
[[ "$SYSTEM_DEBIAN_RELEASE" == "${TEST_CODENAME,,}" ]]
bash -c '[[ "$SYSTEM_DEBIAN_RELEASE" == "${TEST_CODENAME,,}" ]]'
source "$DECLARATION"
[[ "$SYSTEM_DEBIAN_RELEASE" == "${TEST_CODENAME,,}" ]]
''', value)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_existing_values_are_preserved(self):
        for value in ("custom", ""):
            result = self.run_shell('''
SYSTEM_DEBIAN_RELEASE="$TEST_CODENAME"
source() {
    if [[ "$1" == /etc/os-release ]]; then return 99; fi
    builtin source "$@"
}
source "$DECLARATION"
[[ "$SYSTEM_DEBIAN_RELEASE" == "$TEST_CODENAME" ]]
''', value)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_detection_errors(self):
        for mode in ("empty", "invalid", "read_error", "missing"):
            result = self.run_shell('''
source() {
    if [[ "$1" == /etc/os-release ]]; then
        case "$TEST_CODENAME" in
            empty) VERSION_CODENAME="" ;;
            invalid) VERSION_CODENAME="bad release" ;;
            read_error) return 1 ;;
            missing) return 0 ;;
        esac
    else
        builtin source "$@"
    fi
}
VERSION_CODENAME=inherited
if source "$DECLARATION"; then exit 10; fi
[[ -z "${SYSTEM_DEBIAN_RELEASE+x}" ]]
''', mode)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("SYSTEM_DEBIAN_RELEASE", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_current_system(self):
        result = self.run_shell('''
source "$DECLARATION"
actual="$SYSTEM_DEBIAN_RELEASE"
source /etc/os-release
[[ "$actual" == "${VERSION_CODENAME,,}" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
