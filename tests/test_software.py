#!/usr/bin/env python3
"""Tests des commandes software avec APT et les participants globaux simulés."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PRELUDE = r'''
set -Eeuo pipefail
print_error() { printf 'ERROR %s\n' "$*"; }
print_info() { printf 'INFO %s\n' "$*"; }
print_success() { printf 'OK %s\n' "$*"; }
print_title() { printf '%s\n' "$*"; }
source "$ROOT/modules/softwares/software.sh"
source "$ROOT/modules/softwares/deb.sh"
source "$ROOT/modules/softwares/apt.sh"
source "$ROOT/modules/diu/update-all.sh"
apt-get() {
    printf 'apt-get %s\n' "$*" >> "$CALLS"
    if [[ "$*" == *indextargets* ]]; then
        . /etc/os-release
        printf 'Debian|%s|https://deb.debian.org/debian/|main|Packages\n' "$VERSION_CODENAME"
        printf 'Vendor|%s|https://vendor.invalid/|main|Packages\n' "$VERSION_CODENAME"
        return
    fi
    local arg sources=''
    for arg in "$@"; do
        if [[ "$arg" == Dir::Etc::sourcelist=* ]]; then sources="${arg#*=}"; fi
    done
    if [[ -n "$sources" ]]; then
        cat "$sources" >> "$SOURCES"
    fi
    if [[ "${*: -1}" == update ]]; then return "${INDEX_FAILURE:-0}"; fi
    if [[ "$*" == *--simulate* ]]; then
        if [[ "$*" == *remove* && "$*" != *--no-remove* ]]; then
            echo 'Remv foo [1.0]'
            if [[ "${BAD_REMOVAL:-0}" == 1 ]]; then echo 'Remv vendor [1.0]'; fi
        else
            echo 'Inst foo [1.0] (2.0 Debian:stable [amd64])'
            if [[ "${BAD_DEPENDENCY:-0}" != 0 ]]; then
                echo 'Inst vendor [1.0] (9.0 Vendor:stable [amd64])'
            fi
        fi
        return "${RESOLVE_FAILURE:-0}"
    fi
    printf 'MUTATION\n' >> "$CALLS"
    return "${APT_FAILURE:-0}"
}
apt-cache() {
    local name="${*: -1}" installed="${INSTALLED:-1.0}" candidate="${CANDIDATE:-2.0}"
    if [[ "$name" == vendor ]]; then
        printf 'vendor:\n Installed: 1.0\n Candidate: 1.0\n Version table:\n *** 1.0 100\n 100 /var/lib/dpkg/status\n'
        if [[ "${BAD_DEPENDENCY:-0}" == 2 ]]; then
            printf ' 9.0 500\n 500 https://deb.debian.org/debian trixie/main amd64 Packages\n'
        fi
        return
    fi
    if [[ "${UNKNOWN:-0}" == 1 ]]; then
        echo 'foo: (no versions)'
        return
    fi
    printf '%s:\n Installed: %s\n Candidate: %s\n Version table:\n' "$name" "$installed" "$candidate"
    printf ' 2.0 500\n 500 https://deb.debian.org/debian trixie/main amd64 Packages\n'
    if [[ "${UNKNOWN_INSTALLED:-0}" == 0 ]]; then
        printf ' 1.0 500\n 500 https://deb.debian.org/debian trixie/main amd64 Packages\n'
    else
        printf ' *** 1.0 100\n 100 /var/lib/dpkg/status\n'
    fi
}
dpkg-query() { printf 'foo\t1.0\tinstalled\nvendor\t1.0\tinstalled\n'; }
apt() { printf 'apt %s\n' "$*" >> "$CALLS"; return "${APT_FAILURE:-0}"; }
'''


class SoftwareTests(unittest.TestCase):
    def run_shell(self, script, **variables):
        with tempfile.TemporaryDirectory(prefix='.software-test-', dir=ROOT) as directory:
            env = dict(os.environ, ROOT=str(ROOT), TMPDIR=directory,
                       CALLS=f'{directory}/calls', SOURCES=f'{directory}/sources', **variables)
            result = subprocess.run(['bash', '-c', PRELUDE + '\n' + script], env=env,
                                    text=True, capture_output=True)
            calls = Path(env['CALLS']).read_text() if Path(env['CALLS']).exists() else ''
            sources = Path(env['SOURCES']).read_text() if Path(env['SOURCES']).exists() else ''
            return result, calls, sources

    def test_invalid_arguments_do_not_call_apt(self):
        for args in ('install deb', 'remove deb', 'install deb --bad',
                     'install deb "foo;id"', 'update deb foo extra', 'update unknown',
                     'update deb ""'):
            with self.subTest(args=args):
                result, calls, _ = self.run_shell(f'manage_software_action {args}')
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertEqual(calls, '')

    def test_apt_future_is_explicit(self):
        result, calls, _ = self.run_shell('manage_software_action install apt foo')
        self.assertEqual(result.returncode, 1)
        self.assertIn('non pris en charge', result.stdout)
        self.assertEqual(calls, '')

    def test_github_unknown_recipe_does_not_call_system(self):
        result, calls, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
manage_software_action() { :; }
software_github_action install unknown
''')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(calls, '')

    def test_github_recipe_registry_routes_explicitly(self):
        result, calls, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
software_github_recipe() { [[ "$1:$2" == demo:install ]] && printf '%s' demo_install; }
demo_install() { echo install >> "$CALLS"; }
software_github_action install demo
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['install'])

    def test_codex_cli_remove_keeps_profile(self):
        result, _, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
codex_root="$TMPDIR/codex-home"
codex_install_root="$TMPDIR/codex-install"
mkdir -p "$codex_root/packages/standalone" "$codex_install_root/packages/standalone" "$TMPDIR/bin"
printf 'profile' > "$codex_root/config.toml"
printf '#!/bin/sh\n' > "$TMPDIR/bin/codex"
chmod 0755 "$TMPDIR/bin/codex"
    SOFTWARES_APT_CODEX_CLI=1 SOFTWARES_APT_CODEX_CLI_INSTALL_ROOT="$codex_install_root" SOFTWARES_APT_CODEX_CLI_BIN="$TMPDIR/bin/codex" \
    software_github_codex_cli_remove
[[ -f "$codex_root/config.toml" && ! -e "$TMPDIR/bin/codex" && ! -e "$codex_install_root/packages/standalone" ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_codex_cli_recipe_is_explicit(self):
        result, _, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
[[ "$(software_github_recipe codex-cli install)" == software_github_codex_cli_install ]]
[[ "$(software_github_recipe unknown install 2>/dev/null || true)" == '' ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_codex_cli_has_no_home_variable(self):
        result, _, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
    [[ ! "$(declare -F | awk '{print $3}')" =~ software_github_codex_cli_root ]]
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_github_codex_cli_remove_reports_version(self):
        result, _, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
codex_root="$TMPDIR/codex-home"
codex_install_root="$TMPDIR/codex-install"
mkdir -p "$codex_root/packages/standalone" "$codex_install_root/packages/standalone" "$TMPDIR/bin"
printf '#!/bin/sh\nprintf "codex-cli 1.2.3\\n"\n' > "$TMPDIR/bin/codex"
chmod 0755 "$TMPDIR/bin/codex"
    SOFTWARES_APT_CODEX_CLI=1 SOFTWARES_APT_CODEX_CLI_INSTALL_ROOT="$codex_install_root" SOFTWARES_APT_CODEX_CLI_BIN="$TMPDIR/bin/codex" \
    software_github_codex_cli_remove
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('OK softwares/github/codex-cli (1.2.3): désinstallé.', result.stdout)

    def test_codex_cli_remove_persists_disabled_state(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_codex_cli.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_codex_cli.sh" > "$variable_source"
source "$variable_source"
source "$ROOT/modules/softwares/github.sh"
codex_install_root="$TMPDIR/codex-install"
mkdir -p "$codex_install_root/packages/standalone" "$TMPDIR/bin"
printf '#!/bin/sh\nprintf "codex-cli 1.2.3\\n"\n' > "$TMPDIR/bin/codex"
chmod 0755 "$TMPDIR/bin/codex"
SOFTWARES_APT_CODEX_CLI=1 SOFTWARES_APT_CODEX_CLI_INSTALL_ROOT="$codex_install_root" SOFTWARES_APT_CODEX_CLI_BIN="$TMPDIR/bin/codex" \
    software_github_codex_cli_remove
grep -Fx 'export SOFTWARES_APT_CODEX_CLI=0' "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_codex_cli_update_after_remove_is_noop(self):
        result, calls, _ = self.run_shell(r'''
source "$ROOT/modules/softwares/github.sh"
SOFTWARES_APT_CODEX_CLI=0
software_github_codex_cli_update
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Codex CLI n'est pas installé.", result.stdout)
        self.assertNotIn('curl', calls)

    def test_apt_chatgpt_remove_reports_version(self):
        result, _, _ = self.run_shell(r'''
    dpkg-query() {
        if [[ "$*" == *db:Status-Status* ]]; then printf 'installed'; else printf '2.4.0'; fi
    }
apt() { :; }
system_apt_remove_repository() { :; }
manage_softwares_action remove apt chatgpt
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('OK softwares/apt/chatgpt (2.4.0): désinstallé.', result.stdout)

    def test_chatgpt_variables_detect_package_and_default_home(self):
        result, _, _ = self.run_shell(r'''
source "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh"
    printf '%s\n' "$SOFTWARES_APT_CHATGPT"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1], '0')

    def test_codex_cli_variables_persist_defaults(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_codex_cli.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_codex_cli.sh" > "$variable_source"
SOFTWARES_APT_CODEX_CLI=0
source "$variable_source"
    cat "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1:], ['export SOFTWARES_APT_CODEX_CLI=0'])

    def test_chatgpt_variables_persist_without_home(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_chatgpt.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh" > "$variable_source"
dpkg-query() { printf 'unknown'; }
source "$variable_source"
    cat "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1:], ['export SOFTWARES_APT_CHATGPT=0'])

    def test_chatgpt_static_value_is_not_redetected_when_defined(self):
        result, _, _ = self.run_shell(r'''
SOFTWARES_APT_CHATGPT=0
dpkg-query() { printf 'installed'; }
source "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh"
    printf '%s\n' "$SOFTWARES_APT_CHATGPT"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1], '0')

    def test_chatgpt_home_is_removed_from_persisted_config(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_chatgpt.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh" > "$variable_source"
printf 'export SOFTWARES_APT_CHATGPT=0\nexport SOFTWARES_APT_CHATGPT_HOME=\\~/.codex\n' > "$TMPDIR/softwares.env"
source "$TMPDIR/softwares.env"
source "$variable_source"
    cat "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1:], ['export SOFTWARES_APT_CHATGPT=0'])

    def test_chatgpt_install_prepares_repository_without_changing_desktop(self):
        result, calls, _ = self.run_shell(r'''
desktop="$TMPDIR/chatgpt.desktop"
printf 'Name=ChatGPT\nExec=chatgpt %%U\n' > "$desktop"
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'unknown' || printf 'foo\t1.0\tinstalled\n'; }
system_apt_install_repository() { echo repository >> "$CALLS"; }
SYSTEM_APT_CGPT=0
SOFTWARES_APT_CHATGPT_DESKTOP_FILE="$desktop"
    before="$(cat "$desktop")"
manage_softwares_action install apt chatgpt
cat "$desktop"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['repository', 'apt -y update', 'apt -y install chatgpt'])
        self.assertIn('Exec=chatgpt %U', result.stdout)

    def test_chatgpt_install_skips_repository_when_enabled(self):
        result, calls, _ = self.run_shell(r'''
desktop="$TMPDIR/chatgpt.desktop"
printf 'Exec=chatgpt %%U\n' > "$desktop"
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'unknown' || printf 'foo\t1.0\tinstalled\n'; }
system_apt_install_repository() { echo repository >> "$CALLS"; }
SYSTEM_APT_CGPT=1
SOFTWARES_APT_CHATGPT_DESKTOP_FILE="$desktop"
manage_softwares_action install apt chatgpt
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['apt -y install chatgpt'])

    def test_chatgpt_install_persists_enabled_state(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_chatgpt.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh" > "$variable_source"
source "$variable_source"
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'unknown' || printf 'foo\t1.0\tinstalled\n'; }
system_apt_install_repository() { :; }
SYSTEM_APT_CGPT=0
manage_softwares_action install apt chatgpt
grep -Fx 'export SOFTWARES_APT_CHATGPT=1' "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_chatgpt_remove_orders_package_repository_and_update(self):
        result, calls, _ = self.run_shell(r'''
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'installed' || printf 'foo\t1.0\tinstalled\n'; }
system_apt_remove_repository() { echo repository >> "$CALLS"; }
manage_softwares_action remove apt chatgpt
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['apt -y remove chatgpt', 'repository', 'apt -y update'])

    def test_chatgpt_remove_persists_disabled_state(self):
        result, _, _ = self.run_shell(r'''
variable_source="$TMPDIR/software_apt_chatgpt.sh"
sed "s#^variable_config_file=.*#variable_config_file=\"$TMPDIR/softwares.env\"#" \
    "$ROOT/modules/diu/variables/softwares/software_apt_chatgpt.sh" > "$variable_source"
source "$variable_source"
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'installed' || printf 'foo\t1.0\tinstalled\n'; }
system_apt_remove_repository() { :; }
SOFTWARES_APT_CHATGPT=1
manage_softwares_action remove apt chatgpt
grep -Fx 'export SOFTWARES_APT_CHATGPT=0' "$TMPDIR/softwares.env"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_chatgpt_update_does_not_rewrite_desktop_or_call_apt(self):
        result, calls, _ = self.run_shell(r'''
desktop="$TMPDIR/chatgpt.desktop"
printf 'Exec=chatgpt %%U\n' > "$desktop"
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'installed' || printf 'foo\t1.0\tinstalled\n'; }
SOFTWARES_APT_CHATGPT_DESKTOP_FILE="$desktop"
manage_softwares_action update apt chatgpt
cat "$desktop"
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls, '')
        self.assertIn('Exec=chatgpt %U', result.stdout)

    def test_chatgpt_update_absent_does_not_call_apt(self):
        result, calls, _ = self.run_shell(r'''
dpkg-query() { [[ "$*" == *chatgpt* ]] && printf 'unknown' || printf 'foo\t1.0\tinstalled\n'; }
manage_softwares_action update apt chatgpt
''')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(calls, '')

    def test_official_install_uses_isolated_sources(self):
        result, calls, sources = self.run_shell('manage_software_action install deb foo', INSTALLED='(none)')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('MUTATION', calls)
        self.assertIn('--no-remove install -- foo=2.0', calls)
        self.assertIn('signed-by=/usr/share/keyrings/debian-archive-keyring.gpg', sources)
        self.assertNotIn('vendor.invalid', sources)

    def test_targeted_update(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('install -- foo=2.0', calls)

    def test_remove(self):
        result, calls, _ = self.run_shell('manage_software_action remove deb foo')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('remove -- foo', calls)
        self.assertNotIn('purge', calls)

    def test_absent_update_does_not_install(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo', INSTALLED='(none)')
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('MUTATION', calls)

    def test_absent_remove_is_idempotent(self):
        result, calls, _ = self.run_shell('manage_software_action remove deb foo', INSTALLED='(none)')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('MUTATION', calls)

    def test_up_to_date_no_transaction(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo', INSTALLED='2.0')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('MUTATION', calls)

    def test_unknown_origin_is_blocked(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo', UNKNOWN_INSTALLED='1')
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('MUTATION', calls)

    def test_unknown_package_is_blocked(self):
        result, calls, _ = self.run_shell('manage_software_action install deb foo', UNKNOWN='1')
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('MUTATION', calls)

    def test_nonofficial_dependency_is_blocked(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo', BAD_DEPENDENCY='1')
        self.assertEqual(result.returncode, 1)
        self.assertIn('Version non officielle', result.stdout)
        self.assertNotIn('MUTATION', calls)

    def test_update_all_deb_skips_vendor(self):
        result, calls, _ = self.run_shell('manage_update_action deb')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn('vendor : non applicable', result.stdout)
        self.assertIn('install -- foo=2.0', calls)
        self.assertNotIn('vendor=', calls)
        self.assertEqual(calls.count('MUTATION'), 1)

    def test_apt_failures_propagate(self):
        for failure in ('INDEX_FAILURE', 'RESOLVE_FAILURE', 'APT_FAILURE'):
            with self.subTest(failure=failure):
                result, calls, _ = self.run_shell('manage_update_action deb foo', **{failure: '1'})
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                if failure != 'APT_FAILURE':
                    self.assertNotIn('MUTATION', calls)

    def test_universal_order_and_exec_isolation(self):
        result, calls, _ = self.run_shell(r'''
software_deb() { echo deb >> "$CALLS"; }
system_apt_update() { echo apt >> "$CALLS"; }
update_diu() { echo diu >> "$CALLS"; exec bash -c 'exit 0'; }
unset ENV_IA_USER
manage_update_action
printf 'AFTER\n'
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['apt', 'diu'])
        self.assertIn('AFTER', result.stdout)

    def test_global_failure_keeps_independent_diu(self):
        result, calls, _ = self.run_shell(r'''
software_deb() { echo deb >> "$CALLS"; return 1; }
system_apt_update() { echo apt >> "$CALLS"; return 1; }
update_diu() { echo diu >> "$CALLS"; return 0; }
unset ENV_IA_USER
manage_update_action
''')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(calls.splitlines(), ['apt', 'diu'])
        self.assertIn('globale incomplète', result.stdout)

    def test_hermes_installed_but_stopped_is_included(self):
        result, calls, _ = self.run_shell(r'''
software_deb() { echo deb >> "$CALLS"; }
system_apt_update() { echo apt >> "$CALLS"; }
update_diu() { echo diu >> "$CALLS"; }
ENV_IA_USER=test
_hermes_dir() { echo "$TMPDIR/hermes"; }
mkdir "$TMPDIR/hermes"
touch "$TMPDIR/hermes/compose.yml"
update_agent_hermes() { echo hermes >> "$CALLS"; }
manage_update_action
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(calls.splitlines(), ['apt', 'hermes', 'diu'])

    def test_diu_specific_route(self):
        result, calls, _ = self.run_shell('update_diu() { echo diu >> "$CALLS"; }; manage_update_action diu')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(calls.strip(), 'diu')

    def test_dispatch_propagates_failure_and_does_not_start_installation(self):
        source = (ROOT / 'root-install-debian.sh').read_text()
        dispatch = source.split('dispatch_arguments() {', 1)[1].split('\n}\n', 1)[0]
        script = 'dispatch_arguments() {' + dispatch + '\n}\n'
        result, calls, _ = self.run_shell(script + '\ndispatch_arguments remove deb\necho UNEXPECTED')
        self.assertEqual(result.returncode, 2)
        self.assertEqual(calls, '')
        self.assertNotIn('UNEXPECTED', result.stdout)

    def test_hermes_failure_is_in_global_summary(self):
        result, calls, _ = self.run_shell(r"""
software_deb() { echo deb >> "$CALLS"; }
system_apt_update() { echo apt >> "$CALLS"; }
update_diu() { echo diu >> "$CALLS"; }
ENV_IA_USER=test
_hermes_dir() { echo "$TMPDIR/hermes"; }
mkdir "$TMPDIR/hermes"
touch "$TMPDIR/hermes/compose.yml"
update_agent_hermes() { echo hermes >> "$CALLS"; return 1; }
manage_update_action
""")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(calls.splitlines(), ['apt', 'hermes', 'diu'])
        self.assertIn('ia/hermes : échec', result.stdout)

    def test_diu_failure_is_in_global_summary(self):
        result, _, _ = self.run_shell(r"""
software_deb() { return 0; }
update_diu() { exec bash -c 'exit 1'; }
unset ENV_IA_USER
manage_update_action
""")
        self.assertEqual(result.returncode, 1)
        self.assertIn('diu : échec', result.stdout)

    def test_diu_installed_version_failure_is_explicit(self):
        result, _, _ = self.run_shell(r"""
source "$ROOT/modules/diu/update.sh"
git_get_latest_release() { echo v2.0; }
dpkg-query() { return 1; }
if update_diu; then exit 77; else exit 1; fi
""")
        self.assertEqual(result.returncode, 1)
        self.assertIn('Impossible de lire la version installée', result.stdout)

    def test_third_party_dependency_is_not_replaced(self):
        result, calls, _ = self.run_shell('manage_update_action deb foo', BAD_DEPENDENCY='2')
        self.assertEqual(result.returncode, 1)
        self.assertIn("Remplacement d'une dépendance", result.stdout)
        self.assertNotIn('MUTATION', calls)

    def test_third_party_reverse_dependency_is_not_removed(self):
        result, calls, _ = self.run_shell('manage_software_action remove deb foo', BAD_REMOVAL='1')
        self.assertEqual(result.returncode, 1)
        self.assertIn("Suppression d'un paquet", result.stdout)
        self.assertNotIn('MUTATION', calls)


if __name__ == '__main__':
    unittest.main()
