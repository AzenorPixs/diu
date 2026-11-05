"""Validation isolée du bilan de mise à jour système."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SystemUpdateReportTests(unittest.TestCase):
    def run_update(self, extra=''):
        with tempfile.TemporaryDirectory(dir=ROOT) as fixture:
            env = dict(os.environ, ROOT=str(ROOT), FIXTURE=fixture)
            script = r'''
source "$ROOT/modules/system/apt.sh"
print_error() { printf 'ERROR %s\n' "$*" >&2; }
system_engine_ensure_dependencies() { :; }
system_network_update() { :; }
system_update_package_versions() {
    if [[ -f "$FIXTURE/updated" ]]; then printf 'chatgpt\t2\n'; else printf 'chatgpt\t1\n'; fi
}
software_apt_chatgpt_version() {
    if [[ -f "$FIXTURE/updated" ]]; then printf 2; else printf 1; fi
}
system_apt_update() { touch "$FIXTURE/updated"; printf 'sortie apt masquée\n'; }
SYSTEM_APT_ENGINE=1 SYSTEM_GITHUB_ENGINE=0 SYSTEM_FLATPAK_ENGINE=0
SOFTWARES_APT_CHATGPT=1
''' + extra + '\nsystem_update\n'
            return subprocess.run(['bash', '-c', script], env=env, text=True,
                                  capture_output=True)

    def test_updated_versions_and_hidden_apt_output(self):
        result = self.run_update()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('chatgpt : 1 → 2', result.stdout)
        self.assertIn('ChatGPT : 1 → 2', result.stdout)
        self.assertIn('moteur désactivé', result.stdout)
        self.assertNotIn('sortie apt masquée', result.stdout)

    def test_unchanged_software_version_is_shown(self):
        result = self.run_update('system_apt_update() { :; }')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('ChatGPT : 1', result.stdout)
        self.assertNotIn('chatgpt : 1 →', result.stdout)

    def test_failure_exposes_diagnostic_and_returns_failure(self):
        result = self.run_update("system_apt_update() { echo 'erreur simulée'; return 3; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('mise à jour échouée', result.stdout)
        self.assertIn('erreur simulée', result.stdout)
        self.assertIn('ChatGPT : 1', result.stdout)
        self.assertNotRegex(result.stdout, r'✅ Système Debian .* à jour')

    def test_warning_exposes_output_and_returns_failure(self):
        result = self.run_update("system_apt_update() { echo 'W: dépôt inaccessible'; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('avertissements', result.stdout)
        self.assertIn('W: dépôt inaccessible', result.stdout)

    def test_apt_cli_notice_alone_does_not_report_warning(self):
        notice = 'WARNING: apt does not have a stable CLI interface. Use with caution in scripts.'
        result = self.run_update(f"system_apt_update() {{ printf '%s\\n' '{notice}' '{notice}'; }}")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(result.stdout, r'✅ Système Debian .* à jour')
        self.assertNotIn(notice, result.stdout)
        self.assertNotIn('avertissements', result.stdout)

    def test_apt_cli_notice_does_not_hide_real_warning(self):
        result = self.run_update(r"""system_apt_update() {
            echo 'WARNING: apt does not have a stable CLI interface. Use with caution in scripts.'
            echo 'W: dépôt inaccessible'
        }""")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('avertissements', result.stdout)
        self.assertIn('W: dépôt inaccessible', result.stdout)

    def test_similar_warning_is_not_suppressed(self):
        result = self.run_update("system_apt_update() { echo 'WARNING: apt does not have a stable CLI interface. Other issue.'; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Other issue.', result.stdout)

    def test_apt_cli_notice_does_not_hide_failure(self):
        result = self.run_update(r"""system_apt_update() {
            echo 'WARNING: apt does not have a stable CLI interface. Use with caution in scripts.'
            echo 'échec APT'
            return 1
        }""")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('mise à jour échouée', result.stdout)
        self.assertIn('échec APT', result.stdout)

    def test_disabled_software_is_not_shown(self):
        result = self.run_update('SOFTWARES_APT_CHATGPT=0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('ChatGPT :', result.stdout)

    def test_partial_failure_reports_changed_package(self):
        result = self.run_update("system_apt_update() { touch \"$FIXTURE/updated\"; echo 'échec nettoyage'; return 4; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('mise à jour partielle', result.stdout)
        self.assertIn('échec nettoyage', result.stdout)
        self.assertIn('chatgpt : 1 → 2', result.stdout)

    def test_enabled_github_software_is_updated_and_reported(self):
        result = self.run_update(r'''
SYSTEM_GITHUB_ENGINE=1 SOFTWARES_APT_CODEX_CLI=1
software_github_codex_cli_version() { if [[ -f "$FIXTURE/codex" ]]; then echo 2; else echo 1; fi; }
software_github_codex_cli_update() { touch "$FIXTURE/codex"; }
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Codex CLI : 1 → 2', result.stdout)
        self.assertEqual(result.stdout.count('Codex CLI'), 1)

    def test_github_up_to_date_is_reported_once(self):
        result = self.run_update(r'''
SYSTEM_GITHUB_ENGINE=1 SOFTWARES_APT_CODEX_CLI=1
software_github_codex_cli_version() { echo 0.166.0; }
software_github_codex_cli_update() { echo 'Codex CLI est déjà à jour (0.166.0).'; }
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('Codex CLI'), 1)
        self.assertIn('• Codex CLI : 0.166.0', result.stdout)

    def test_github_failure_keeps_recipe_diagnostics(self):
        result = self.run_update(r'''
SYSTEM_GITHUB_ENGINE=1 SOFTWARES_APT_CODEX_CLI=1
software_github_codex_cli_version() { echo 0.166.0; }
software_github_codex_cli_update() { echo 'détail de la recette'; echo 'erreur GitHub' >&2; return 1; }
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('détail de la recette', result.stdout)
        self.assertIn('erreur GitHub', result.stderr)
        self.assertIn('mise à jour échouée', result.stdout)

    def test_other_enabled_apt_software_is_reported(self):
        result = self.run_update(r'''
SOFTWARES_APT_APACHE2=1
system_update_package_versions() { printf 'chatgpt\t1\napache2\t2.4\n'; }
system_apt_update() { :; }
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('apache2 : 2.4', result.stdout)

    def test_apt_cleanup_sequence_and_failure_propagation(self):
        result = self.run_update(r'''
source "$ROOT/modules/system/apt.sh"
system_apt_regenerate() { :; }
system_install_prerequisites() { printf 'prerequisites\n' >> "$FIXTURE/calls"; }
apt() { printf '%s\n' "$*" >> "$FIXTURE/calls"; [[ "$1" != autopurge ]]; }
if system_apt_update; then exit 2; fi
grep -qx 'autopurge -y' "$FIXTURE/calls"
grep -qx 'autoremove -y' "$FIXTURE/calls"
[[ "$(tail -n 1 "$FIXTURE/calls")" == prerequisites ]]
exit 0
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_apt_cannot_wait_for_invisible_input(self):
        result = self.run_update("system_apt_update() { read -r answer || { echo 'saisie nécessaire'; return 1; }; }")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('saisie nécessaire', result.stdout)

    def test_github_version_is_visible_when_dependencies_fail(self):
        result = self.run_update(r'''
SYSTEM_GITHUB_ENGINE=1 SOFTWARES_APT_CODEX_CLI=1
software_github_codex_cli_version() { echo 1.2; }
system_engine_ensure_dependencies() { [[ "$1" != github ]]; }
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('GitHub : dépendances indisponibles', result.stdout)
        self.assertIn('Codex CLI : 1.2', result.stdout)
