import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/migration.sh"
OLD = "SOFTWARES_APT_CODEX_CLI"
NEW = "SOFTWARE_GITHUB_CODEX_CLI"


class SoftwareDesiredMigrationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".software-migration-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def migrate(self):
        return subprocess.run(
            ["bash", "-c", 'source "$1"; software_migrate_desired_variable "$2" "$3" "$4"',
             "--", str(MODULE), str(self.config), OLD, NEW],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_migrates_without_changing_other_values_or_permissions(self):
        self.config.write_text(f"export {OLD}=1\nexport OTHER=example\n", encoding="utf-8")
        self.config.chmod(0o600)
        result = self.migrate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export OTHER=example\nexport {NEW}=1\n")
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertEqual(self.migrate().returncode, 0)

    def test_existing_new_value_is_authoritative(self):
        self.config.write_text(f"export {OLD}=1\nexport {NEW}=0\n", encoding="utf-8")
        result = self.migrate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export {NEW}=0\n")

    def test_ambiguous_or_duplicate_value_is_preserved(self):
        for text in (f'export {OLD}="1"\n', f"export {OLD}=0\nexport {OLD}=1\n"):
            with self.subTest(text=text):
                self.config.write_text(text, encoding="utf-8")
                result = self.migrate()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.config.read_text(encoding="utf-8"), text)

    def test_symlink_is_rejected(self):
        destination = Path(self.directory.name) / "target"
        destination.write_text(f"export {OLD}=1\n", encoding="utf-8")
        os.symlink(destination, self.config)
        result = self.migrate()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(destination.read_text(encoding="utf-8"), f"export {OLD}=1\n")

    def test_concurrent_change_aborts_without_overwriting_it(self):
        self.config.write_text(f"export {OLD}=1\n", encoding="utf-8")
        script = (
            'source "$1"\n'
            'cmp() { printf "external change\\n" >> "$4"; command cmp "$@"; }\n'
            'software_migrate_desired_variable "$2" "$3" "$4"'
        )
        result = subprocess.run(
            ["bash", "-c", script, "--", str(MODULE), str(self.config), OLD, NEW],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), f"export {OLD}=1\nexternal change\n")

    def test_catalogue_migrates_apt_and_github_values_idempotently(self):
        self.config.write_text(
            "export SOFTWARES_APT_JSVC=1\nexport SOFTWARES_APT_CODEX_CLI=0\nexport OTHER=keep\n",
            encoding="utf-8",
        )
        script = 'source "$1"; software_migrate_desired_states "$2"'
        command = ["bash", "-c", script, "--", str(MODULE), str(self.config)]
        first = subprocess.run(command, text=True, capture_output=True, check=False)
        self.assertEqual(first.returncode, 0, first.stderr)
        content = self.config.read_text(encoding="utf-8")
        self.assertIn("export SOFTWARE_APT_JSVC=1\n", content)
        self.assertIn("export SOFTWARE_GITHUB_CODEX_CLI=0\n", content)
        self.assertIn("export OTHER=keep\n", content)
        self.assertNotIn("SOFTWARES_APT_", content)
        second = subprocess.run(command, text=True, capture_output=True, check=False)
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), content)

    def test_environment_value_is_preserved_before_old_declaration_is_disabled(self):
        script = (
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/migration.sh"\n'
            'SOFTWARES_APT_CODEX_CLI=1\n'
            'software_migrate_desired_environment "$2" || exit $?\n'
            '[[ "${SOFTWARE_GITHUB_CODEX_CLI:-}" == 1 && ! -v SOFTWARES_APT_CODEX_CLI ]]'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_GITHUB_CODEX_CLI=1\n")

    def test_new_environment_value_wins_and_is_persisted(self):
        script = (
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/migration.sh"\n'
            'SOFTWARES_APT_JSVC=0; SOFTWARE_APT_JSVC=1\n'
            'software_migrate_desired_environment "$2" || exit $?\n'
            '[[ "$SOFTWARE_APT_JSVC" == 1 && ! -v SOFTWARES_APT_JSVC ]]'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_JSVC=1\n")

    def test_crowdsec_secret_is_migrated_privately_without_output(self):
        secret = "fixture-secret+1/test"
        self.config.write_text(f"export SOFTWARES_CROWDSEC_BOUNCER_API_KEY={secret}\nexport OTHER=keep\n", encoding="utf-8")
        self.config.chmod(0o644)
        script = 'source "$1"; software_migrate_crowdsec_secret "$2"'
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"),
                         f"export OTHER=keep\nexport SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY={secret}\n")
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)

    def test_crowdsec_secret_ambiguity_and_shell_trace_do_not_leak(self):
        secret = "fixture-secret"
        data = f"export SOFTWARES_CROWDSEC_BOUNCER_API_KEY={secret}\n"
        self.config.write_text(data, encoding="utf-8")
        script = 'source "$1"; set -x; software_migrate_crowdsec_secret "$2"'
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)

    def test_crowdsec_secret_from_environment_is_persisted_without_leaking(self):
        self.config.write_text("export OTHER=keep", encoding="utf-8")
        script = (
            'source "$1"\n'
            'SOFTWARES_CROWDSEC_BOUNCER_API_KEY=fixture-secret\n'
            'software_migrate_crowdsec_secret_environment "$2" || exit $?\n'
            '[[ "$SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY" == fixture-secret ]] || exit 1\n'
            '[[ ! -v SOFTWARES_CROWDSEC_BOUNCER_API_KEY ]]'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("fixture-secret", result.stdout + result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"),
                         "export OTHER=keep\nexport SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY=fixture-secret\n")
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)

    def test_secret_file_is_secured_before_migrating_other_variables(self):
        secret = "fixture-sensitive-value"
        self.config.write_text(f"export SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD={secret}\n"
                               "export SOFTWARES_APT_JSVC=1\n", encoding="utf-8")
        self.config.chmod(0o644)
        script = (
            'source "$1"\n'
            'software_secure_sensitive_configuration "$2" || exit $?\n'
            'software_migrate_desired_states "$2"'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertIn("export SOFTWARE_APT_JSVC=1\n", self.config.read_text(encoding="utf-8"))

    def test_complete_migration_preserves_values_and_does_not_leak_key(self):
        secret = "fixture-secret"
        self.config.write_text(f"export SOFTWARES_APT_JSVC=1\nexport SOFTWARES_APT_CODEX_CLI=0\n"
                               f"export SOFTWARES_CROWDSEC_BOUNCER_API_KEY={secret}\n", encoding="utf-8")
        script = (
            'set -Eeuo pipefail\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/migration.sh"\n'
            'software_secure_sensitive_configuration "$2"\n'
            'software_migrate_crowdsec_secret "$2"\n'
            'software_migrate_desired_states "$2"\n'
            'source "$2"\n'
            'software_migrate_desired_environment "$2"\n'
            'software_migrate_crowdsec_secret_environment "$2"\n'
            '[[ "$SOFTWARE_APT_JSVC" == 1 && "$SOFTWARE_GITHUB_CODEX_CLI" == 0 ]]\n'
            '[[ "$SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY" == fixture-secret ]]\n'
            '[[ ! -v SOFTWARES_APT_JSVC && ! -v SOFTWARES_APT_CODEX_CLI && ! -v SOFTWARES_CROWDSEC_BOUNCER_API_KEY ]]'
        )
        result = subprocess.run(["bash", "-c", script, "--", str(ROOT), str(self.config)],
                                text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)


if __name__ == "__main__":
    unittest.main()
