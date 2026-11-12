import os
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "modules/softwares/zsh_configuration.py"


class ZshConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".zsh-configuration-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        (self.base / "root").mkdir()
        self.config = self.base / "root/.zshrc"

    def run_helper(self, action):
        return subprocess.run([sys.executable, "-B", str(HELPER), action, str(self.base)],
                              text=True, capture_output=True, check=False)

    def test_existing_content_is_preserved_without_disclosing_it(self):
        self.config.write_text("export EXISTING_TEST_SECRET=fixture-value\nalias custom='echo ok'\n", encoding="utf-8")
        self.config.chmod(0o600)
        result = self.run_helper("configure")
        self.assertEqual(result.returncode, 0, result.stderr)
        content = self.config.read_text(encoding="utf-8")
        self.assertTrue(content.startswith("export EXISTING_TEST_SECRET=fixture-value\nalias custom='echo ok'\n"))
        self.assertNotIn("fixture-value", result.stdout + result.stderr)
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertEqual(self.run_helper("check").returncode, 0)
        self.assertEqual(self.run_helper("configure").returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), content)

    def test_new_file_is_private_and_contains_no_credential_exports(self):
        result = self.run_helper("configure")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertNotIn("API_", self.config.read_text(encoding="utf-8"))

    def test_global_defaults_are_literal_and_preserve_existing_content(self):
        script = 'source "$1/modules/softwares/apt-recipes.sh"; software_apt_load_recipes; software_apt_zsh_defaults'
        env = dict(os.environ, API_DEEPSEEK_KEY='sensitive-fixture-value',
                   API_GEMINI_KEY='sensitive-fixture-value', API_OPENROUTER_KEY='sensitive-fixture-value')
        defaults = subprocess.run(['bash', '-c', script, '--', str(ROOT)], text=True,
                                  capture_output=True, env=env, check=False)
        self.assertEqual(defaults.returncode, 0, defaults.stderr)
        self.assertNotIn('sensitive-fixture-value', defaults.stdout + defaults.stderr)
        self.assertIn('if ! alias -- diu', defaults.stdout)
        self.config.write_text("alias diu='custom-command'\n", encoding='utf-8')
        for _ in range(2):
            result = subprocess.run([sys.executable, '-B', str(HELPER), 'configure-defaults', str(self.base)],
                                    input=defaults.stdout, text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
        content = self.config.read_text(encoding='utf-8')
        self.assertTrue(content.startswith("alias diu='custom-command'\n"))
        self.assertEqual(content.count('# BEGIN DIU ZSH CONVERGENCE'), 1)
        self.assertNotIn('sensitive-fixture-value', content)

    def test_sshhvp1_is_guarded_and_contains_the_requested_ssh_route(self):
        script = 'source "$1/modules/softwares/apt-recipes.sh"; software_apt_load_recipes; software_apt_zsh_defaults'
        result = subprocess.run(['bash', '-c', script, '--', str(ROOT)], text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        for expected in ('if ! alias -- sshhvp1', "alias sshhvp1='diu_sshhvp1'", 'ssh -f -X -S none -o ExitOnForwardFailure=yes root@hvp1',
                         'runuser -u ade -- xauth -f /tmp/.hvp1-chatgpt-xauth nmerge -',
                         '/usr/bin/chatgpt --ozone-platform=x11', "' >/dev/null 2>&1"):
            self.assertIn(expected, result.stdout)

    def test_symlink_and_duplicate_block_are_rejected(self):
        target = self.base / "foreign"
        target.write_text("unchanged\n", encoding="utf-8")
        os.symlink(target, self.config)
        self.assertNotEqual(self.run_helper("configure").returncode, 0)
        self.assertEqual(target.read_text(encoding="utf-8"), "unchanged\n")
        self.config.unlink()
        data = "# BEGIN DIU ZSH CONVERGENCE\n# END DIU ZSH CONVERGENCE\n" * 2
        self.config.write_text(data, encoding="utf-8")
        self.assertNotEqual(self.run_helper("configure").returncode, 0)
        self.assertEqual(self.config.read_text(encoding="utf-8"), data)


if __name__ == "__main__":
    unittest.main()
