import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/softwares/apt-configuration.sh"


class AptConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".apt-configuration-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)

    def prepare_openjdk(self, major):
        properties = self.base / f"etc/java-{major}-openjdk/net.properties"
        properties.parent.mkdir(parents=True)
        properties.write_text(
            "java.net.useSystemProxies=false\n# http.proxyHost=\n# http.proxyPort=80\n"
            "# https.proxyHost=\n# https.proxyPort=443\nhttp.nonProxyHosts=localhost\n",
            encoding="utf-8",
        )
        (self.base / f"usr/lib/jvm/java-{major}-openjdk-amd64/lib/server").mkdir(parents=True)
        return properties

    def run_shell(self, body):
        script = 'source "$1"\nsoftware_apt_package_state() { echo 1; }\n' + body
        return subprocess.run(["bash", "-c", script, "--", str(MODULE), str(self.base)],
                              text=True, capture_output=True, check=False)

    def test_openjdk_17_configures_proxy_with_literal_special_characters(self):
        properties = self.prepare_openjdk(17)
        result = self.run_shell(
            'SYSTEM_DEBIAN_RELEASE=bookworm; SYSTEM_PROXY=1\n'
            "PROXY_HTTP_HOST='proxy&name'; PROXY_HTTP_PORT=3128\n"
            "PROXY_HTTPS_HOST='secure%proxy'; PROXY_HTTPS_PORT=8443\n"
            'software_apt_configure_openjdk "$2" || exit $?\n'
            'software_apt_check_openjdk_configuration "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("http.proxyHost=proxy&name\n", properties.read_text(encoding="utf-8"))
        self.assertIn("https.proxyHost=secure%proxy\n", properties.read_text(encoding="utf-8"))

    def test_openjdk_21_configures_system_proxy(self):
        properties = self.prepare_openjdk(21)
        result = self.run_shell(
            'SYSTEM_DEBIAN_RELEASE=trixie; PROXY_HTTP=1\n'
            'software_apt_configure_openjdk "$2" || exit $?\n'
            'software_apt_check_openjdk_configuration "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("java.net.useSystemProxies=true\n", properties.read_text(encoding="utf-8"))

    def test_invalid_proxy_input_is_rejected_before_writing(self):
        properties = self.prepare_openjdk(17)
        original = properties.read_text(encoding="utf-8")
        result = self.run_shell(
            'SYSTEM_DEBIAN_RELEASE=bookworm; SYSTEM_PROXY=1\n'
            "PROXY_HTTP_HOST=$'bad\\nhost'; PROXY_HTTP_PORT=3128\n"
            'PROXY_HTTPS_HOST=proxy; PROXY_HTTPS_PORT=8443\n'
            'software_apt_configure_openjdk "$2"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(properties.read_text(encoding="utf-8"), original)
        self.assertFalse((self.base / "usr/lib/jvm/java-17-openjdk-amd64/lib/amd64/server").exists())

    def test_postfix_relay_is_configured_and_verified(self):
        configuration = self.base / "etc/postfix/main.cf"
        configuration.parent.mkdir(parents=True)
        configuration.write_text("relayhost = old\nother = keep\n", encoding="utf-8")
        result = self.run_shell(
            "POSTFIX_RELAY_HOST='[smtp.example]:25'\n"
            'service() { printf "%s\\n" "$*"; }\n'
            'systemctl() { [[ "$1" == show ]] && echo loaded; return 0; }\n'
            'software_apt_configure_postfix "$2" || exit $?\n'
            'software_apt_check_postfix_configuration "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("postfix restart", result.stdout)
        self.assertEqual(configuration.read_text(encoding="utf-8"), "relayhost = [smtp.example]:25\nother = keep\n")

    def test_postfix_rejects_invalid_relay_without_restarting(self):
        configuration = self.base / "etc/postfix/main.cf"
        configuration.parent.mkdir(parents=True)
        configuration.write_text("relayhost = old\n", encoding="utf-8")
        result = self.run_shell(
            "POSTFIX_RELAY_HOST=$'bad\\nrelay'\n"
            'service() { echo unexpected; }\n'
            'software_apt_configure_postfix "$2"'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(configuration.read_text(encoding="utf-8"), "relayhost = old\n")
        self.assertNotIn("unexpected", result.stdout)

    def test_postfix_stopped_service_is_not_converged(self):
        configuration = self.base / "etc/postfix/main.cf"
        configuration.parent.mkdir(parents=True)
        configuration.write_text("relayhost = [smtp.example]:25\n", encoding="utf-8")
        result = self.run_shell(
            "POSTFIX_RELAY_HOST='[smtp.example]:25'\n"
            'systemctl() { [[ "$1" == show ]] && { echo loaded; return 0; }; return 3; }\n'
            'software_apt_check_postfix_configuration "$2"'
        )
        self.assertEqual(result.returncode, 1)

    def test_mongodb_service_is_started_enabled_and_checked(self):
        result = self.run_shell(
            'systemctl() { case "$1" in show) echo loaded;; *) printf "systemctl %s\\n" "$*";; esac; }\n'
            'mongosh() { :; }; mongod() { echo version; }\n'
            'software_apt_configure_mongodb || exit $?\n'
            'software_apt_check_mongodb_configuration'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("systemctl start mongod", result.stdout)
        self.assertIn("systemctl enable mongod", result.stdout)

    def test_wazuh_server_configuration_requires_all_components(self):
        result = self.run_shell(
            'software_apt_package_state() { [[ "$1" == filebeat ]] && echo 0 || echo 1; }\n'
            'software_apt_check_wazuh_server_configuration'
        )
        self.assertNotEqual(result.returncode, 0)

    def test_zsh_removal_refuses_when_another_account_uses_it(self):
        result = self.run_shell(
            'getent() { printf "root:x:0:0:root:/root:/bin/zsh\\nother:x:1000:1000::/home/other:/usr/bin/zsh\\n"; }\n'
            'chsh() { echo unexpected; }\n'
            'software_apt_prepare_zsh_removal'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_zsh_removal_restores_root_bash_before_package_removal(self):
        result = self.run_shell(
            'fixture_shell=/bin/zsh\n'
            'getent() { printf "root:x:0:0:root:/root:%s\\n" "$fixture_shell"; }\n'
            'chsh() { fixture_shell="$2"; }\n'
            'software_apt_prepare_zsh_removal || exit $?\n'
            '[[ "$fixture_shell" == */bash ]]'
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_zsh_preflight_refuses_to_replace_a_custom_root_shell(self):
        result = self.run_shell(
            'getent() { printf "root:x:0:0:root:/root:/usr/bin/fish\\n"; }\n'
            'software_apt_preflight_zsh'
        )
        self.assertNotEqual(result.returncode, 0)

    def test_ssh_preflight_checks_docker_account_before_installation(self):
        (self.base / "home/docker").mkdir(parents=True)
        result = self.run_shell(
            'ENVIRONMENT_DOCKER=1; ENVIRONMENT_DOCKER_USER=docker\n'
            'KEY_SSH_ADMIN="ssh-ed25519 TEST"; KEY_SSH_ACME=""\n'
            'getent() { printf "docker:x:1000:1000::/home/docker:/bin/bash\\n"; }\n'
            'software_apt_preflight_ssh_server "$2"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("ssh-ed25519 TEST", result.stdout + result.stderr)

    def test_ssh_preflight_refuses_missing_docker_account(self):
        result = self.run_shell(
            'ENVIRONMENT_DOCKER=1; ENVIRONMENT_DOCKER_USER=docker\n'
            'KEY_SSH_ADMIN="ssh-ed25519 TEST"\n'
            'getent() { return 2; }\n'
            'software_apt_preflight_ssh_server "$2"'
        )
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
