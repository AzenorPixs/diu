import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class AptConvergenceTests(unittest.TestCase):
    def run_shell(self, body):
        script = (
            'set -Eeuo pipefail\n'
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/apt-state.sh"\n'
            'source "$1/modules/softwares/apt-configuration.sh"\n'
            'source "$1/modules/softwares/crowdsec-state.sh"\n'
            'source "$1/modules/softwares/crowdsec-hooks.sh"\n'
            'source "$1/modules/softwares/syslog-state.sh"\n'
            'source "$1/modules/softwares/syslog-hooks.sh"\n'
            'source "$1/modules/softwares/apt-convergence.sh"\n'
            'system_apt_source_state() { printf "%s\\n" "${!1:-0}"; }\n'
            'apt() { :; }\n'
            'apt-get() { printf "Remv %s [1]\\n" "${@: -1}"; }\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_converges_missing_package(self):
        result = self.run_shell(
            'installed=0\n'
            'dpkg-query() { [[ "$installed" == 1 ]] && printf "jsvc\\tinstalled\\n"; return 0; }\n'
            'apt() { printf "apt %s\\n" "$*"; installed=1; }\n'
            'software_apt_converge jsvc 1'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y install --no-upgrade -- jsvc", result.stdout)
        self.assertIn("état réel 1, conforme", result.stdout)

    def test_converges_installed_package_to_absence(self):
        result = self.run_shell(
            'installed=1\n'
            'dpkg-query() { [[ "$installed" == 1 ]] && printf "jsvc\\tinstalled\\n"; return 0; }\n'
            'apt() { printf "apt %s\\n" "$*"; installed=0; }\n'
            'software_apt_converge jsvc 0'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y remove -- jsvc", result.stdout)
        self.assertIn("état réel 0, conforme", result.stdout)

    def test_unknown_identifier_never_calls_apt(self):
        result = self.run_shell(
            'apt() { echo unexpected; }\n'
            'software_apt_install "jsvc;unexpected"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_declared_repository_is_prepared_before_install(self):
        result = self.run_shell(
            'installed=0; SYSTEM_APT_CGPT=0\n'
            'dpkg-query() { [[ "$installed" == 1 ]] && printf "chatgpt\\tinstalled\\n"; return 0; }\n'
            'system_apt_install_repository() { echo "repository $1"; SYSTEM_APT_CGPT=1; }\n'
            'apt() { printf "apt %s\\n" "$*"; [[ "$2" == install ]] && installed=1; return 0; }\n'
            'software_apt_converge chatgpt 1'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(result.stdout.index("repository cgpt"), result.stdout.index("apt -y install --no-upgrade -- chatgpt"))
        self.assertIn("apt -y update", result.stdout)

    def test_apache_dependencies_follow_debian_release(self):
        for release, perl in (("bullseye", "perl-modules-5.32"),
                              ("bookworm", "perl-modules-5.36"),
                              ("trixie", "perl-modules-5.40")):
            with self.subTest(release=release):
                result = self.run_shell(
                    f'SYSTEM_DEBIAN_RELEASE={release}\n'
                    'apt() { printf "%s\\n" "$*"; }\n'
                    'software_apt_install apache2'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(perl, result.stdout)
                self.assertIn("libapache2-mod-fcgid", result.stdout)

    def test_lemonldap_installs_declared_dependencies(self):
        result = self.run_shell(
            'SYSTEM_APT_LEMONLDAP=1\n'
            'apt() { printf "%s\\n" "$*"; }\n'
            'software_apt_install lemonldap'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("lemonldap-ng lemonldap-ng-doc liblasso-perl krb5-user", result.stdout)

    def test_webmin_retains_install_and_purge_options(self):
        result = self.run_shell(
            'SYSTEM_APT_WEBMIN=1\n'
            'apt() { printf "%s\\n" "$*"; }\n'
            'software_apt_install webmin\n'
            'software_apt_remove webmin'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [
            "-y update", "-y install --no-upgrade --install-recommends -- webmin", "-y purge -- webmin"
        ])

    def test_fastfetch_selects_package_and_runs_configuration_hook(self):
        for release, package in (("bookworm", "neofetch"), ("trixie", "fastfetch")):
            with self.subTest(release=release):
                result = self.run_shell(
                    f'SYSTEM_DEBIAN_RELEASE={release}\n'
                    'apt() { printf "apt %s\\n" "$*"; }\n'
                    'software_apt_configure_fastfetch() { echo configured; }\n'
                    'software_apt_install fastfetch'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f"apt -y install --no-upgrade -- {package}", result.stdout)
                self.assertIn("configured", result.stdout)

    def test_removal_refuses_additional_packages(self):
        for verb in ("Remv", "Purg"):
            with self.subTest(verb=verb):
                result = self.run_shell(
                    f'apt-get() {{ printf "{verb} jsvc [1]\\n{verb} protected-service [1]\\n"; }}\n'
                    'apt() { echo unexpected; }\n'
                    'software_apt_remove jsvc'
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("protected-service", result.stderr)
                self.assertNotIn("unexpected", result.stdout)

    def test_removal_refuses_unverified_simulation(self):
        result = self.run_shell(
            'apt-get() { return 0; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_remove jsvc'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_shared_role_can_be_disabled_without_removing_package(self):
        result = self.run_shell(
            'software_apt_convergence_remove_packages() { printf ""; }\n'
            'software_apt_convergence_pre_remove_hook() { echo disable_role; }\n'
            'disable_role() { echo ROLE_DISABLED; }\n'
            'apt-get() { echo unexpected; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_remove jsvc'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("ROLE_DISABLED", result.stdout)
        self.assertNotIn("unexpected", result.stdout)

    def test_installed_fastfetch_repairs_incomplete_configuration(self):
        result = self.run_shell(
            'SYSTEM_DEBIAN_RELEASE=trixie; configured=0; software_management_action=install\n'
            'dpkg-query() { printf "fastfetch\\tinstalled\\n"; }\n'
            'software_apt_check_fastfetch_configuration() { [[ "$configured" == 1 ]]; }\n'
            'software_apt_configure_fastfetch() { echo REPAIR; configured=1; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_converge fastfetch 1'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("configuration non conforme", result.stdout)
        self.assertIn("REPAIR", result.stdout)
        self.assertNotIn("unexpected", result.stdout)
        self.assertTrue(result.stdout.rstrip().endswith("état réel 1, conforme."))

    def test_postgresql_removes_server_packages_and_meta_without_dependencies(self):
        result = self.run_shell(
            'dpkg-query() { printf "postgresql\\tinstalled\\npostgresql-17\\tinstalled\\n"; }\n'
            'apt-get() { printf "Remv postgresql [1]\\nRemv postgresql-17 [1]\\n"; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_remove postgresql'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y remove -- postgresql postgresql-17", result.stdout)

    def test_openjdk_removes_only_installed_runtime_packages(self):
        result = self.run_shell(
            'dpkg-query() { printf "openjdk-17-jre-headless\\tinstalled\\nopenjdk-21-jre-headless\\tinstalled\\n"; }\n'
            'apt-get() { printf "Remv openjdk-17-jre-headless [1]\\nRemv openjdk-21-jre-headless [1]\\n"; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_remove openjdk'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y remove -- openjdk-17-jre-headless openjdk-21-jre-headless", result.stdout)

    def test_mongodb_repository_version_and_service_hook(self):
        result = self.run_shell(
            'MONGODB_VERSION=7.0; SYSTEM_APT_MONGODB=0\n'
            'system_apt_install_repository() { echo "repository $1"; SYSTEM_APT_MONGODB=7; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_configure_mongodb() { echo configured; }\n'
            'software_apt_install mongodb'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("repository mongodb-7", result.stdout)
        self.assertIn("apt -y install --no-upgrade -- mongodb-org", result.stdout)
        self.assertIn("configured", result.stdout)

    def test_mongodb_keeps_an_explicit_repository_version(self):
        result = self.run_shell(
            'MONGODB_VERSION=7.0; SYSTEM_APT_MONGODB=8\n'
            'system_apt_install_repository() { echo unexpected; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_configure_mongodb() { :; }\n'
            'software_apt_install mongodb'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_invalid_repository_state_is_not_overwritten(self):
        result = self.run_shell(
            'MONGODB_VERSION=7.0; SYSTEM_APT_MONGODB=9\n'
            'system_apt_install_repository() { echo unexpected; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_install mongodb'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_omada_artifact_is_validated_before_install(self):
        with tempfile.TemporaryDirectory(prefix=".omada-artifact-test-", dir=ROOT) as directory:
            script = (
                'source "$1/modules/softwares/apt-convergence.sh"\n'
                'export TMPDIR="$2"; OMADA_VERSION=5.14.26.1\n'
                'curl() { printf fixture > "${@: -1}"; }\n'
                'dpkg-deb() { case "$3" in Package) echo omadac;; Architecture) echo amd64;; esac; }\n'
                'dpkg() { echo amd64; }\n'
                'apt() { printf "apt %s\\n" "$*"; }\n'
                'software_apt_install omada'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), directory],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("apt -y install --no-upgrade --", result.stdout)
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_wrong_downloaded_package_is_never_installed(self):
        with tempfile.TemporaryDirectory(prefix=".omada-artifact-test-", dir=ROOT) as directory:
            script = (
                'source "$1/modules/softwares/apt-convergence.sh"\n'
                'export TMPDIR="$2"; OMADA_VERSION=5.14.26.1\n'
                'curl() { printf fixture > "${@: -1}"; }\n'
                'dpkg-deb() { case "$3" in Package) echo wrong-package;; Architecture) echo amd64;; esac; }\n'
                'dpkg() { echo amd64; }\n'
                'apt() { [[ "$2" != install ]] || echo unexpected; }\n'
                'software_apt_install omada'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), directory],
                                    text=True, capture_output=True, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn("unexpected", result.stdout)
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_wazuh_server_installs_existing_composite_package_set(self):
        result = self.run_shell(
            'SYSTEM_APT_WAZUH=4\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_install wazuh-server'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("wazuh-indexer wazuh-manager filebeat wazuh-dashboard", result.stdout)

    def test_wazuh_server_removal_preserves_filebeat(self):
        result = self.run_shell(
            'dpkg-query() { printf "wazuh-manager\\tinstalled\\nfilebeat\\tinstalled\\n"; }\n'
            'apt-get() { printf "Remv wazuh-manager [1]\\n"; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_remove wazuh-server'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("apt -y remove -- wazuh-manager", result.stdout)
        self.assertNotIn("filebeat", result.stdout)

    def test_zoom_install_uses_declared_artifact_and_expected_package(self):
        result = self.run_shell(
            'software_apt_install_artifact() { printf "artifact %s %s\\n" "$1" "$2"; }\n'
            'software_apt_install zoom'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("artifact https://zoom.us/client/latest/zoom_amd64.deb zoom", result.stdout)

    def test_installed_zoom_is_not_updated_by_convergence(self):
        result = self.run_shell(
            'dpkg-query() { printf "zoom\\tinstalled\\n"; }\n'
            'software_apt_install_artifact() { echo unexpected; }\n'
            'software_apt_converge zoom 1'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_catalogue_entries_have_complete_resolvable_metadata(self):
        result = self.run_shell(
            'SYSTEM_DEBIAN_RELEASE=trixie; MONGODB_VERSION=8.0; OMADA_VERSION=5.14.26.1; WAZUH_CLIENT_VERSION=4.11.2-1\n'
            'while IFS= read -r item; do\n'
            '  software_apt_convergence_variable "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_package "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_install_packages "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_install_options "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_remove_action "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_repository "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_repository_variable "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_repository_expected "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_remove_repository "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_artifact_url "$item" >/dev/null || exit 1\n'
            '  environment_hook="$(software_apt_convergence_environment_hook "$item")" || exit 1\n'
            '  [[ -z "$environment_hook" ]] || declare -F "$environment_hook" >/dev/null || exit 1\n'
            '  pre_install="$(software_apt_convergence_pre_install_hook "$item")" || exit 1\n'
            '  [[ -z "$pre_install" ]] || declare -F "$pre_install" >/dev/null || exit 1\n'
            '  pre_remove="$(software_apt_convergence_pre_remove_hook "$item")" || exit 1\n'
            '  [[ -z "$pre_remove" ]] || declare -F "$pre_remove" >/dev/null || exit 1\n'
            '  software_apt_convergence_sensitive_install "$item" >/dev/null || exit 1\n'
            '  software_apt_convergence_update_configuration_policy "$item" >/dev/null || exit 1\n'
            '  detector="$(software_apt_convergence_detector "$item")" || exit 1\n'
            '  declare -F "$detector" >/dev/null || exit 1\n'
            '  for field in configuration_hook configuration_check; do\n'
            '    function="software_apt_convergence_$field"; callback="$("$function" "$item")" || exit 1\n'
            '    [[ -z "$callback" ]] || declare -F "$callback" >/dev/null || exit 1\n'
            '  done\n'
            'done < <(software_apt_convergence_names)'
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wazuh_agent_refuses_missing_enrollment_before_download(self):
        result = self.run_shell(
            'WAZUH_CLIENT_VERSION=4.11.2-1\n'
            'curl() { echo unexpected; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_install wazuh-agent'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_wazuh_agent_uses_secret_without_exposing_installer_output(self):
        with tempfile.TemporaryDirectory(prefix=".wazuh-artifact-test-", dir=ROOT) as directory:
            script = (
                'source "$1/modules/softwares/apt-configuration.sh"\n'
                'source "$1/modules/softwares/apt-convergence.sh"\n'
                'export TMPDIR="$2"; WAZUH_CLIENT_VERSION=4.11.2-1\n'
                'SOFTWARE_APT_WAZUH_AGENT_MANAGER=manager.example\n'
                'SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD=fixture-secret-value\n'
                'curl() { printf fixture > "${@: -1}"; }\n'
                'dpkg-deb() { case "$3" in Package) echo wazuh-agent;; Architecture) echo amd64;; esac; }\n'
                'dpkg() { echo amd64; }\n'
                'apt() { [[ "$2" != update ]] || return 0; [[ "$WAZUH_MANAGER" == manager.example && "$WAZUH_REGISTRATION_PASSWORD" == fixture-secret-value ]] || return 1; '
                'printf "%s\\n" "$WAZUH_REGISTRATION_PASSWORD"; }\n'
                'systemctl() { return 0; }\n'
                'software_apt_install wazuh-agent'
            )
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), directory],
                                    text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("fixture-secret-value", result.stdout + result.stderr)
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_existing_wazuh_agent_repairs_service_without_secret_or_download(self):
        result = self.run_shell(
            'configured=0; software_management_action=install\n'
            'dpkg-query() { printf "wazuh-agent\\tinstalled\\n"; }\n'
            'software_apt_check_wazuh_agent_configuration() { [[ "$configured" == 1 ]]; }\n'
            'software_apt_configure_wazuh_agent() { configured=1; }\n'
            'software_apt_prepare_wazuh_agent_environment() { echo unexpected; return 1; }\n'
            'apt() { echo unexpected; return 1; }\n'
            'software_apt_converge wazuh-agent 1'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)
        self.assertIn("configuration non conforme", result.stdout)


if __name__ == "__main__":
    unittest.main()
