import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AptRecipeSourceTests(unittest.TestCase):
    def run_case(self, body):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            script = r'''
set -Eeuo pipefail
source "$TEST_ROOT/modules/softwares/apt-convergence.sh"
apt() { printf 'apt %s\n' "$*"; }
system_apt_source_state() {
    [[ ! -e "$FIXTURE/$1" ]] && printf '0\n' || cat "$FIXTURE/$1"
}
system_apt_install_repository() {
    printf 'prepare %s\n' "$1"
    case "$1" in
        contrib) variable=SYSTEM_APT_DEBIAN_CONTRIB ;;
        non-free) variable=SYSTEM_APT_DEBIAN_NONFRFEE ;;
        non-free-firmware) variable=SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE ;;
        cgpt) variable=SYSTEM_APT_CGPT ;;
        *) return 2 ;;
    esac
    printf -v "$variable" 1
    printf '1\n' > "$FIXTURE/$variable"
}
''' + body
            return subprocess.run(['bash', '-c', script], text=True, capture_output=True,
                                  env=dict(os.environ, TEST_ROOT=str(ROOT), FIXTURE=folder), check=False)

    def test_missing_real_repository_is_repaired_despite_enabled_variable(self):
        r = self.run_case('SYSTEM_APT_CGPT=1\nsoftware_apt_prepare_sources chatgpt')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.splitlines(), ['prepare cgpt', 'apt -y update'])

    def test_cumulative_components_are_prepared_before_one_index_refresh(self):
        r = self.run_case(r'''
software_apt_recipe_jsvc() {
    case "$1" in components) printf 'contrib\nnon-free\nnon-free-firmware\n' ;; repository) printf '\n' ;; esac
}
software_apt_prepare_sources jsvc
[[ "$SYSTEM_APT_DEBIAN_CONTRIB" == 1 && "$SYSTEM_APT_DEBIAN_NONFRFEE" == 1 && "$SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE" == 1 ]]
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.splitlines(), ['prepare contrib', 'prepare non-free', 'prepare non-free-firmware', 'apt -y update'])

    def test_existing_sources_do_not_trigger_regeneration(self):
        r = self.run_case('SYSTEM_APT_CGPT=1\nprintf "1\\n" > "$FIXTURE/SYSTEM_APT_CGPT"\nsoftware_apt_prepare_sources chatgpt')
        self.assertEqual((r.returncode, r.stdout), (0, ''), r.stderr)

    def test_incomplete_preparation_stops_before_index_refresh(self):
        r = self.run_case('system_apt_install_repository() { :; }\nsoftware_apt_prepare_sources chatgpt')
        self.assertNotEqual(r.returncode, 0)
        self.assertNotIn('apt -y update', r.stdout)

    def test_recipe_loading_has_no_persistence_or_installation_side_effect(self):
        r = self.run_case(r'''
unset SOFTWARE_APT_JSVC
software_apt_declare_desired() { echo unexpected; return 99; }
software_apt_load_recipes
[[ ! -v SOFTWARE_APT_JSVC ]]
''')
        self.assertEqual((r.returncode, r.stdout), (0, ''), r.stderr)

    def test_monolith_has_no_catalogue_install_blocks(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertNotRegex(source, r'(?m)^if \[\[ "\$\{SOFTWARES_APT_')
        # The Docker account preparation remains outside this refactoring.
        self.assertIn('"${SOFTWARES_APT_SSH_SERVER:-0}"', source)
        self.assertIn('"${SOFTWARE_APT_OMADA:-0}"', source)

    def test_desktop_precondition_precedes_install_and_propagates_failure(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        start = source.index('\t\techo "🔧 INSTALL CHRIMIUM"')
        end = source.index('\n\t\ttee ', start)
        block = source[start:end]
        for fail in (False, True):
            script = ('system_apt_require_component() { echo "component $1"; return ' +
                      ('7' if fail else '0') + '; }\napt() { echo installed; }\n' + block)
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True)
            self.assertEqual(result.returncode, 1 if fail else 0, result.stderr)
            self.assertIn('component non-free', result.stdout)
            self.assertEqual('installed' in result.stdout, not fail)

    def test_system_component_helper_refreshes_only_when_needed(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as folder:
            script = r'''
set -Eeuo pipefail
source "$TEST_ROOT/modules/system/apt.sh"
SYSTEM_APT_DEBIAN_NONFRFEE=0
system_apt_source_state() { [[ ! -e "$FIXTURE/source" ]] && printf '0\n' || printf '1\n'; }
system_apt_install_repository() { printf 'prepare %s\n' "$1"; SYSTEM_APT_DEBIAN_NONFRFEE=1; touch "$FIXTURE/source"; }
apt() { printf 'apt %s\n' "$*"; }
system_apt_require_component non-free
system_apt_require_component non-free
'''
            result = subprocess.run(['bash', '-c', script], text=True, capture_output=True,
                                    env=dict(os.environ, TEST_ROOT=str(ROOT), FIXTURE=folder))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), ['prepare non-free', 'apt -y update'])

    def test_bullseye_refuses_separate_firmware_before_persistence(self):
        script = r'''
source "$1/modules/system/apt.sh"
print_error() { printf '%s\n' "$*" >&2; }
SYSTEM_DEBIAN_RELEASE=bullseye
system_apt_set_repository_variable() { echo unexpected; }
system_apt_install_repository non-free-firmware
'''
        result = subprocess.run(['bash', '-c', script, '--', str(ROOT)], text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('unexpected', result.stdout)


if __name__ == '__main__':
    unittest.main()
