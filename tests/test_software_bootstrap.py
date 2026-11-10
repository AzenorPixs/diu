import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SoftwareBootstrapTests(unittest.TestCase):
    def test_reloading_restores_detector_after_legacy_declaration(self):
        script = r'''
set -Eeuo pipefail
source "$1/modules/softwares/bootstrap.sh"
software_load_convergence_modules "$1"
software_apt_jsvc_detect() { printf 'legacy\n'; }
software_load_convergence_modules "$1"
software_apt_package_state() { [[ "$1" == jsvc ]] && printf '1\n'; }
[[ "$(software_apt_jsvc_detect)" == 1 ]]
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_module_loader_exposes_all_three_engines_and_versions(self):
        script = r'''
set -Eeuo pipefail
source "$1/modules/softwares/bootstrap.sh"
software_load_convergence_modules "$1"
for function in software_prepare_migration software_apt_manage_one \
    software_flatpak_manage_one software_github_manage_one software_dispatch \
    system_apt_update_external_applications system_flatpak_update_applications \
    system_github_update_applications; do
    declare -F "$function" >/dev/null || exit 1
done
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_every_legacy_software_flag_has_a_migration_and_catalogue_entry(self):
        script = r'''
source "$1/modules/softwares/migration.sh"
source "$1/modules/softwares/apt-convergence.sh"
software_desired_migration_pairs | while read -r old new; do printf 'MAP %s %s\n' "$old" "$new"; done
while IFS= read -r software; do
    variable="$(software_apt_convergence_variable "$software")" || exit 1
    printf 'APT %s\n' "$variable"
done < <(software_apt_convergence_names)
'''
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        pairs = {}
        apt_names = set()
        for line in result.stdout.splitlines():
            fields = line.split()
            if fields[0] == "MAP":
                pairs[fields[1]] = fields[2]
            elif fields[0] == "APT":
                apt_names.add(fields[1])
        legacy = {"SOFTWARES_APT_" + path.stem.removeprefix("software_apt_").upper()
                  for path in (ROOT / "modules/diu/variables/softwares").glob("software_apt_*.sh")}
        self.assertEqual(set(pairs), legacy)
        self.assertEqual(pairs["SOFTWARES_APT_CODEX_CLI"], "SOFTWARE_GITHUB_CODEX_CLI")
        expected_apt = {new for old, new in pairs.items() if old not in {
            "SOFTWARES_APT_CODEX_CLI", "SOFTWARES_APT_CROWDSEC"}}
        self.assertEqual(apt_names, expected_apt)

    def test_migration_and_first_declaration_preserve_existing_values(self):
        with tempfile.TemporaryDirectory(prefix=".software-bootstrap-test-", dir=ROOT) as directory:
            config = Path(directory) / "config"
            secret = "fixture-crowdsec-secret"
            config.write_text("export SOFTWARES_APT_JSVC=1\nexport SOFTWARES_APT_SSH_SERVER=0\n"
                              "export SOFTWARES_APT_CODEX_CLI=0\n"
                              f"export SOFTWARES_CROWDSEC_BOUNCER_API_KEY={secret}\n", encoding="utf-8")
            config.chmod(0o644)
            script = r'''
set -Eeuo pipefail
source "$1/modules/softwares/convergence.sh"
source "$1/modules/softwares/desired-state.sh"
source "$1/modules/softwares/migration.sh"
source "$1/modules/softwares/global-declarations.sh"
source "$1/modules/softwares/apt-state.sh"
source "$1/modules/softwares/crowdsec-state.sh"
source "$1/modules/softwares/syslog-state.sh"
source "$1/modules/softwares/apt-convergence.sh"
source "$1/modules/softwares/apt-management.sh"
source "$1/modules/softwares/github-state.sh"
source "$1/modules/softwares/github-management.sh"
software_prepare_migration "$2"
source "$2"
software_prepare_loaded_environment "$2"
SYSTEM_DEBIAN_RELEASE=trixie
dpkg-query() { return 0; }
software_github_codex_cli_detect() { printf '0\n'; }
software_crowdsec_repository_detect() { printf '0\n'; }
while IFS= read -r software; do
    software_apt_declare_desired "$2" "$software"
done < <(software_apt_convergence_names)
software_github_declare_desired "$2" codex-cli
software_declare_crowdsec_repository "$2"
software_declare_crowdsec_secret "$2"
[[ "$SOFTWARE_APT_JSVC" == 1 && "$SOFTWARE_APT_SSH_SERVER" == 0 && "$SOFTWARE_GITHUB_CODEX_CLI" == 0 ]]
[[ ! -v SOFTWARES_APT_JSVC && ! -v SOFTWARES_APT_CODEX_CLI && ! -v SOFTWARES_CROWDSEC_BOUNCER_API_KEY ]]
'''
            env = {key: value for key, value in os.environ.items() if not key.startswith(("SOFTWARE_APT_", "SOFTWARES_APT_", "SOFTWARE_GITHUB_", "SOFTWARES_CROWDSEC_"))}
            result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(config)],
                                    env=env, text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn(secret, result.stdout + result.stderr)
            content = config.read_text(encoding="utf-8")
            self.assertIn("export SOFTWARE_APT_JSVC=1\n", content)
            self.assertIn("export SOFTWARE_GITHUB_CODEX_CLI=0\n", content)
            self.assertIn(f"export SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY={secret}\n", content)
            self.assertNotIn("SOFTWARES_APT_", content)
            self.assertEqual(stat.S_IMODE(config.stat().st_mode), 0o600)


if __name__ == "__main__":
    unittest.main()
