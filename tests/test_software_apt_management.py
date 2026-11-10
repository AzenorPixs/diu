import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class AptManagementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".apt-management-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config"

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/apt-state.sh"\n'
            'source "$1/modules/softwares/apt-convergence.sh"\n'
            'source "$1/modules/softwares/apt-management.sh"\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), str(self.config)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_failed_install_keeps_desired_state(self):
        result = self.run_shell(
            'dpkg-query() { return 0; }\n'
            'apt() { return 1; }\n'
            'software_apt_manage_one "$2" install jsvc'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_JSVC=1\n")

    def test_first_update_initializes_from_real_state(self):
        result = self.run_shell(
            'dpkg-query() { printf "jsvc\\tinstalled\\n"; }\n'
            'apt() { echo unexpected; return 1; }\n'
            'software_apt_manage_one "$2" update jsvc'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_JSVC=1\n")
        self.assertNotIn("unexpected", result.stdout)

    def test_preexisting_file_value_is_not_replaced_by_detection(self):
        data = "export SOFTWARE_APT_JSVC=1\n"
        self.config.write_text(data, encoding="utf-8")
        result = self.run_shell(
            'dpkg-query() { return 0; }\n'
            'apt() { echo unexpected; }\n'
            'software_apt_manage_one "$2" update jsvc'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)
        self.assertNotIn("unexpected", result.stdout)

    def test_loaded_state_must_match_persisted_state_before_convergence(self):
        data = "export SOFTWARE_APT_JSVC=0\n"
        self.config.write_text(data, encoding="utf-8")
        result = self.run_shell(
            'SOFTWARE_APT_JSVC=1\n'
            'dpkg-query() { echo unexpected; return 1; }\n'
            'apt() { echo unexpected; return 1; }\n'
            'software_apt_manage_one "$2" update jsvc'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)
        self.assertNotIn("unexpected", result.stdout)

    def test_explicit_remove_cleans_repository_even_when_package_is_absent(self):
        result = self.run_shell(
            'SYSTEM_APT_CGPT=1\n'
            'dpkg-query() { return 0; }\n'
            'system_apt_remove_repository() { echo "repository $1"; SYSTEM_APT_CGPT=0; }\n'
            'apt() { printf "apt %s\\n" "$*"; }\n'
            'software_apt_manage_one "$2" remove chatgpt'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("repository cgpt", result.stdout)
        self.assertIn("apt -y update", result.stdout)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_APT_CHATGPT=0\n")

    def test_update_does_not_change_ssh_configuration_when_package_is_present(self):
        self.config.write_text("export SOFTWARE_APT_SSH_SERVER=1\n", encoding="utf-8")
        result = self.run_shell(
            'SOFTWARE_APT_SSH_SERVER=1\n'
            'dpkg-query() { printf "openssh-server\\tinstalled\\n"; }\n'
            'software_apt_check_ssh_server_configuration() { echo unexpected; return 1; }\n'
            'software_apt_configure_ssh_server() { echo unexpected; }\n'
            'software_apt_manage_one "$2" update ssh-server'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("unexpected", result.stdout)
        self.assertIn("état réel 1, conforme", result.stdout)

    def test_update_does_not_reconfigure_present_zsh_or_crowdsec_agent(self):
        for software, variable, package in (("zsh", "SOFTWARE_APT_ZSH", "zsh"),
                                             ("crowdsec-agent", "SOFTWARE_APT_CROWDSEC_AGENT", "crowdsec")):
            with self.subTest(software=software):
                self.config.write_text(f"export {variable}=1\n", encoding="utf-8")
                result = self.run_shell(
                    f'{variable}=1\n'
                    f'dpkg-query() {{ printf "{package}\\tinstalled\\n"; }}\n'
                    'software_apt_apply_configuration() { echo unexpected; }\n'
                    f'software_apt_manage_one "$2" update {software}'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
