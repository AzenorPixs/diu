"""Tests isolés de configuration des moteurs logiciels."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SoftwareEnginesTests(unittest.TestCase):
    def run_engine(self, script):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            env = dict(os.environ, ROOT=str(ROOT), FIXTURE=directory)
            prelude = r'''
set -Eeuo pipefail
print_error() { printf 'ERROR %s\n' "$*" >&2; }
print_info() { :; }
SYSTEM_ENGINE_CONFIG_FILE="$FIXTURE/system.env"
source "$ROOT/modules/system/apt.sh"
apt-get() { printf '%s\n' "$*" >> "$FIXTURE/calls"; }
dpkg-query() { printf installed; }
command() { return 0; }
'''
            return subprocess.run(['bash', '-c', prelude + script], env=env,
                                  text=True, capture_output=True)

    def test_enable_then_disable_preserves_dependencies(self):
        for engine in ('apt', 'github', 'flatpak'):
            with self.subTest(engine=engine):
                script = f'''
flatpak() {{ printf 'flatpak %s\\n' "$*" >> "$FIXTURE/calls"; }}
system_engine_action install {engine}
system_engine_action remove {engine}
[[ "$(cat "$FIXTURE/system.env")" == "export SYSTEM_{engine.upper()}_ENGINE=0" ]]
! grep -q 'remove' "$FIXTURE/calls" 2>/dev/null
'''
                result = self.run_engine(script)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_failed_install_does_not_activate(self):
        result = self.run_engine(r'''
printf 'export SYSTEM_GITHUB_ENGINE=0\n' > "$FIXTURE/system.env"
dpkg-query() { return 1; }
apt-get() { return 1; }
if system_engine_action install github; then exit 1; fi
[[ "$(cat "$FIXTURE/system.env")" == 'export SYSTEM_GITHUB_ENGINE=0' ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_failed_persistence_keeps_previous_state(self):
        result = self.run_engine(r'''
printf 'export SYSTEM_APT_ENGINE=1\n' > "$FIXTURE/system.env"
SYSTEM_APT_ENGINE=1
mv() { return 1; }
if system_engine_action remove apt; then exit 1; fi
[[ "$SYSTEM_APT_ENGINE" == 1 ]]
[[ "$(cat "$FIXTURE/system.env")" == 'export SYSTEM_APT_ENGINE=1' ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_package_after_install_fails(self):
        result = self.run_engine(r'''
dpkg-query() { return 1; }
apt-get() { return 0; }
if system_engine_action install github; then exit 1; fi
[[ ! -e "$FIXTURE/system.env" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_commands_do_not_persist(self):
        result = self.run_engine(r'''
if system_engine_action install unknown; then exit 1; fi
if system_engine_action invalid apt; then exit 1; fi
[[ ! -e "$FIXTURE/system.env" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_disabled_motors_block_actions_and_skip_global_updates(self):
        result = self.run_engine(r'''
source "$ROOT/modules/softwares/apt.sh"
software_apt_update_all() { echo apt >> "$FIXTURE/actions"; }
software_github_update_all() { echo github >> "$FIXTURE/actions"; }
software_flatpak_update_all() { echo flatpak >> "$FIXTURE/actions"; }
SYSTEM_APT_ENGINE=0 SYSTEM_GITHUB_ENGINE=0 SYSTEM_FLATPAK_ENGINE=0
if manage_softwares_action install apt chatgpt; then exit 1; fi
if manage_softwares_action install github codex-cli; then exit 1; fi
if manage_softwares_action flatpak update; then exit 1; fi
manage_softwares_action update
[[ ! -e "$FIXTURE/actions" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_system_update_checks_only_enabled_engines(self):
        result = self.run_engine(r'''
system_engine_ensure_dependencies() { echo "$1" >> "$FIXTURE/actions"; }
system_apt_update() { echo system-apt >> "$FIXTURE/actions"; }
system_flatpak_apply() { echo flatpak-apply >> "$FIXTURE/actions"; }
system_network_update() { echo network >> "$FIXTURE/actions"; }
SYSTEM_APT_ENGINE=1 SYSTEM_GITHUB_ENGINE=0
system_update
[[ "$(cat "$FIXTURE/actions")" == $'apt\nsystem-apt\nflatpak-apply\nnetwork' ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_routing_and_legacy_commands(self):
        result = self.run_engine(r'''
manage_system_action engine install apt
[[ "$SYSTEM_APT_ENGINE" == 1 ]]
manage_system_action engine remove apt
[[ "$SYSTEM_APT_ENGINE" == 0 ]]
if manage_system_action install flatpak; then exit 1; fi
if manage_system_action engine remove apt extra; then exit 1; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_legacy_flatpak_state_is_not_persisted(self):
        result = self.run_engine(r'''
sed "s#^variable_config_file=.*#variable_config_file=\"$FIXTURE/system.env\"#" \
    "$ROOT/modules/diu/variables/system/system_flatpak.sh" > "$FIXTURE/declaration.sh"
SYSTEM_FLATPAK=invalid
unset SYSTEM_FLATPAK_ENGINE
if source "$FIXTURE/declaration.sh"; then exit 1; fi
[[ ! -e "$FIXTURE/system.env" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_migrates_legacy_flatpak_state(self):
        result = self.run_engine(r'''
sed "s#^variable_config_file=.*#variable_config_file=\"$FIXTURE/system.env\"#" \
    "$ROOT/modules/diu/variables/system/system_flatpak.sh" > "$FIXTURE/declaration.sh"
SYSTEM_FLATPAK=0
unset SYSTEM_FLATPAK_ENGINE
source "$FIXTURE/declaration.sh"
[[ "$SYSTEM_FLATPAK_ENGINE" == 0 ]]
grep -Fx 'export SYSTEM_FLATPAK_ENGINE=0' "$FIXTURE/system.env"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
