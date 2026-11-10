import os
import importlib.util
import stat
import subprocess
import sys
import tempfile
import types
import unittest
from unittest import mock
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "modules/softwares/ssh_configuration.py"


class SshConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".ssh-configuration-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.config = self.base / "etc/ssh/sshd_config"
        self.config.parent.mkdir(parents=True)
        self.config.write_text("# existing configuration\nPermitRootLogin no\n", encoding="utf-8")
        self.keys = self.base / "root/.ssh/authorized_keys"
        self.keys.parent.mkdir(parents=True)
        self.keys.write_text("existing-test-key\n", encoding="utf-8")
        self.keys.chmod(0o600)
        binary = self.base / "bin/sshd"
        binary.parent.mkdir()
        binary.write_text(
            '#!/bin/sh\n'
            'if [ "$1" = "-t" ]; then exit "${FAKE_SSHD_FAIL:-0}"; fi\n'
            'printf "%s\\n" "authorizedkeysfile .ssh/authorized_keys .ssh/authorized_keys2" '
            '"permitrootlogin yes" "usepam yes" "x11forwarding no"\n',
            encoding="utf-8",
        )
        binary.chmod(0o700)
        self.environment = dict(os.environ, PATH=f"{binary.parent}:{os.environ.get('PATH', '')}",
                                KEY_SSH_ADMIN="ssh-ed25519 TEST-ADMIN", KEY_SSH_ACME="ssh-ed25519 TEST-ACME")

    def run_helper(self, action, **extra):
        environment = dict(self.environment, **extra)
        return subprocess.run([sys.executable, "-B", str(HELPER), action, str(self.base)],
                              env=environment, text=True, capture_output=True, check=False)

    def test_configuration_preserves_existing_keys_and_is_idempotent(self):
        result = self.run_helper("configure")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.keys.read_text(encoding="utf-8"),
                         "existing-test-key\nssh-ed25519 TEST-ADMIN\nssh-ed25519 TEST-ACME\n")
        self.assertEqual(stat.S_IMODE(self.keys.stat().st_mode), 0o600)
        config = self.config.read_text(encoding="utf-8")
        self.assertIn("# existing configuration\nPermitRootLogin no\n", config)
        self.assertEqual(config.count("# BEGIN DIU SSH CONVERGENCE"), 1)
        self.assertNotIn("TEST-ADMIN", result.stdout + result.stderr)
        second = self.run_helper("configure")
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), config)
        self.assertEqual(self.run_helper("check").returncode, 0)

    def test_invalid_candidate_keeps_original_files(self):
        before_config = self.config.read_bytes()
        before_keys = self.keys.read_bytes()
        result = self.run_helper("configure", FAKE_SSHD_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_bytes(), before_config)
        self.assertEqual(self.keys.read_bytes(), before_keys)

    def test_symlinked_authorized_keys_are_refused(self):
        self.keys.unlink()
        target = self.base / "foreign"
        target.write_text("unchanged\n", encoding="utf-8")
        self.keys.symlink_to(target)
        result = self.run_helper("configure")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_text(encoding="utf-8"), "unchanged\n")

    def test_invalid_key_is_not_printed_or_applied(self):
        before = self.keys.read_bytes()
        result = self.run_helper("configure", KEY_SSH_ADMIN="secret-fixture\ninvalid")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("secret-fixture", result.stdout + result.stderr)
        self.assertEqual(self.keys.read_bytes(), before)

    def test_failed_config_publication_restores_existing_keys(self):
        spec = importlib.util.spec_from_file_location("diu_ssh_configuration_test", HELPER)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        before_keys = self.keys.read_bytes()
        before_config = self.config.read_bytes()
        real_replace = os.replace

        def fail_config(source, destination):
            if Path(destination) == self.config:
                raise OSError("simulated publication failure")
            return real_replace(source, destination)

        with mock.patch.dict(os.environ, self.environment), mock.patch.object(module.os, "replace", side_effect=fail_config):
            with self.assertRaises(OSError):
                module.converge(self.base)
        self.assertEqual(self.keys.read_bytes(), before_keys)
        self.assertEqual(self.config.read_bytes(), before_config)

    def test_docker_account_keys_are_completed_without_replacing_existing_keys(self):
        docker_home = self.base / "home/docker"
        docker_home.mkdir(parents=True)
        docker_keys = docker_home / ".ssh/authorized_keys"
        docker_keys.parent.mkdir()
        docker_keys.write_text("existing-docker-key\n", encoding="utf-8")
        docker_keys.chmod(0o600)
        spec = importlib.util.spec_from_file_location("diu_ssh_configuration_docker_test", HELPER)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        account = types.SimpleNamespace(pw_dir="/home/docker", pw_uid=os.getuid(), pw_gid=os.getgid())
        environment = dict(self.environment, ENVIRONMENT_DOCKER="1", ENVIRONMENT_DOCKER_USER="docker")
        with mock.patch.dict(os.environ, environment), mock.patch.object(module.pwd, "getpwnam", return_value=account):
            module.converge(self.base)
            self.assertEqual(module.check(self.base), 0)
        self.assertEqual(docker_keys.read_text(encoding="utf-8"),
                         "existing-docker-key\nssh-ed25519 TEST-ADMIN\nssh-ed25519 TEST-ACME\n")
        self.assertIn("existing-test-key\n", self.keys.read_text(encoding="utf-8"))

    def test_failed_publication_restores_both_accounts(self):
        docker_home = self.base / "home/docker"
        docker_home.mkdir(parents=True)
        docker_keys = docker_home / ".ssh/authorized_keys"
        docker_keys.parent.mkdir()
        docker_keys.write_text("existing-docker-key\n", encoding="utf-8")
        spec = importlib.util.spec_from_file_location("diu_ssh_configuration_rollback_test", HELPER)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        account = types.SimpleNamespace(pw_dir="/home/docker", pw_uid=os.getuid(), pw_gid=os.getgid())
        environment = dict(self.environment, ENVIRONMENT_DOCKER="1", ENVIRONMENT_DOCKER_USER="docker")
        real_replace = os.replace

        def fail_config(source, destination):
            if Path(destination) == self.config:
                raise OSError("simulated publication failure")
            return real_replace(source, destination)

        with mock.patch.dict(os.environ, environment), mock.patch.object(module.pwd, "getpwnam", return_value=account), \
             mock.patch.object(module.os, "replace", side_effect=fail_config):
            with self.assertRaises(OSError):
                module.converge(self.base)
        self.assertEqual(self.keys.read_text(encoding="utf-8"), "existing-test-key\n")
        self.assertEqual(docker_keys.read_text(encoding="utf-8"), "existing-docker-key\n")


if __name__ == "__main__":
    unittest.main()
