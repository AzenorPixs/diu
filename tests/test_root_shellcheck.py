#!/usr/bin/env python3
"""Contrôles isolés du monolithe, sans exécuter son installation."""
import hashlib
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'


def function(source, name):
    match = re.search(r'^' + name + r'\(\) \{\n.*?^\}', source, re.M | re.S)
    if not match:
        raise AssertionError(name)
    return match.group()


def generated_commands(source, target):
    """Extrait seulement echo/printf ; les redirections ne sont jamais exécutées."""
    # Les corps heredoc sont des données, pas des commandes du générateur.
    source = re.sub(r"^[^\n]*<<'EOF'[^\n]*\n.*?^EOF\n", '', source, flags=re.M | re.S)
    # Rétablir une cible explicite pour les commandes des groupes de redirection.
    def flatten(match):
        body, destination = match.group(1), match.group(2).strip()
        if any(line.strip() and not line.lstrip().startswith(('echo ', 'printf ', '#'))
               for line in body.splitlines()):
            return match.group()
        return '\n'.join(line + ' >> ' + destination
                         if line.lstrip().startswith(('echo ', 'printf ')) else line
                         for line in body.splitlines()) + '\n'
    source = re.sub(r'^[ \t]*\{\n((?:(?:[ \t]*(?:echo |printf |#)[^\n]*|[ \t]*)\n)*)[ \t]*\} >> ([^\n]+)\n', flatten,
                    source, flags=re.M | re.S)
    commands = []
    for line in source.splitlines():
        match = re.match(r'^\s*((?:echo|printf) .*) >>? (.+?)\s*$', line)
        if match and match.group(2) == target:
            commands.append(match.group(1))
    if not commands:
        raise AssertionError(target)
    return '\n'.join(commands)


def render_commands(commands):
    env = {'PATH': '/nonexistent', 'LC_ALL': 'C.UTF-8'}
    for name in re.findall(r'\$\{?([A-Z][A-Z0-9_]*)', commands):
        env[name] = 'test-value'
    return subprocess.run(['/bin/bash', '--noprofile', '--norc', '-c',
                           'set -Eeuo pipefail\n' + commands],
                          env=env, text=True, capture_output=True)


class RootShellCheckTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = SCRIPT.read_text()

    def run_shell(self, code, args=()):
        return subprocess.run(['bash', '-c', 'set -Eeuo pipefail\n' + code, 'bash', *args],
                              env={'PATH': os.defpath}, text=True, capture_output=True)

    def test_syntax_and_shellcheck(self):
        for command in (['bash', '-n', str(SCRIPT)], ['shellcheck', str(SCRIPT)]):
            with self.subTest(command=command[0]):
                result = subprocess.run(command, text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_project_shell_argument(self):
        code = function(self.source, 'manage_project_action')
        code += '\nlaunch_oc_shell() { printf "<%s>\\n" "$@"; }\nmanage_project_action "$@"'
        result = self.run_shell(code, ('ocsh', 'demo'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<demo>\n')

    def test_rootless_inspect_argument(self):
        code = function(self.source, 'manage_docker_action')
        code += '\ndocker_rootless_inspect() { printf "<%s>\\n" "$@"; }\nmanage_docker_action "$@"'
        result = self.run_shell(code, ('rootless', 'inspect', 'devops', 'demo'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<devops>\n<demo>\n')

    def test_scalar_argument_preserves_spaces_and_glob(self):
        code = function(self.source, 'launch_oc_shell')
        code += '\nENV_DEVOPS_PROJECTS_ROOT=/controlled\nENV_DEVOPS_USER="a b*"\n'
        code += 'su() { printf "<%s>\\n" "$@"; }\nlaunch_oc_shell demo'
        result = self.run_shell(code)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<->\n<a b*>\n<-c>\n<docker exec -it demo-opencode sh>\n')

    def test_docker_image_list(self):
        start = self.source.index('if ! DOCKER_IMAGE_IDS=')
        end = self.source.index('echo "🔧 REMOVE SYSTEM DOCKER"', start)
        code = self.source[start:end]
        for output, status, expected in [('id1\nid2\n', 0, '<id1>\n<id2>\n'),
                                         ('', 0, ''), ('', 1, '')]:
            with self.subTest(output=output, status=status):
                # Valeurs contrôlées : aucun appel Docker réel.
                stub = ('docker() { if [[ "$*" == "images -q" ]]; then '
                        + 'printf "%s" "$IMAGE_OUTPUT"; return ' + str(status)
                        + '; else shift; printf "<%s>\\n" "$@"; fi; }\n')
                prefix = "IMAGE_OUTPUT='" + output + "'\n"
                result = self.run_shell(prefix + stub + code)
                self.assertEqual(result.returncode, 1 if status else 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected.strip())
                if status:
                    self.assertIn('découverte des images Docker impossible', result.stderr)

    def test_acme_package_list(self):
        start = self.source.index('ACMESH_MISSING_PACKAGES=()')
        end = self.source.index('\n    fi', self.source.index('apt-get install -y', start)) + len('\n    fi')
        code = self.source[start:end]
        for missing in (False, True):
            with self.subTest(missing=missing):
                stub = ('dpkg-query() { return 1; }\n' if missing else
                        "dpkg-query() { printf 'install ok installed\\n'; }\n")
                stub += 'apt-get() { printf "ARG=<%s>\\n" "$@"; }\n'
                result = self.run_shell(stub + code)
                self.assertEqual(result.returncode, 0, result.stderr)
                arguments = [x for x in result.stdout.splitlines() if x.startswith('ARG=')]
                expected = ['update', 'install', '-y', 'cron', 'coreutils', 'curl', 'git', 'grep', 'sed', 'wget'] if missing else []
                self.assertEqual(arguments, [f'ARG=<{x}>' for x in expected])

    def test_acme_cron_separator(self):
        start = self.source.index('if [ -s "${ACMESH_CRON_TMP}" ]; then')
        end = self.source.index('\n\tACMESH_CURRENT_CRON=', start)
        code = self.source[start:end]
        for content in ('', 'existing\n'):
            with self.subTest(content=content), tempfile.TemporaryDirectory(dir=ROOT) as directory:
                path = Path(directory) / 'crontab'
                path.write_text(content)
                prelude = 'ACMESH_CRON_TMP="$1"\nACMESH_CRON_MARKER=marker\nACMESH_CRON_ENTRY=entry\n'
                result = self.run_shell(prelude + code, (str(path),))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(path.read_text(), content + ('\n' if content else '') + 'marker\nentry\n')

    def test_generated_contents(self):
        expected = GENERATED_HASHES
        for target, digest in expected.items():
            with self.subTest(target=target):
                result = render_commands(generated_commands(self.source, target))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(hashlib.sha256(result.stdout.encode()).hexdigest(), digest)

    def test_literal_zsh_functions(self):
        blocks = re.findall(r"^\s*cat <<'EOF'\n(.*?)^EOF\n", self.source, re.M | re.S)
        # Z1 : 14 fonctions et un bloc de données adoptés ; leurs corps restent littéraux.
        self.assertEqual(len(blocks), 15)
        names = [name for block in blocks for name in re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\(\)\s*\{", block, re.M)]
        self.assertEqual(names, ZSH_FUNCTION_NAMES)
        self.assertEqual(hashlib.sha256(''.join(blocks).encode()).hexdigest(), ZSH_FUNCTIONS_HASH)


GENERATED_HASHES = {
    '/etc/rsyslog.conf': '467a371b3c5f12237dbee636fbe5b15b2cece32c149ba557011d26d81438abbd',
    '/etc/rsyslog.d/kernel.conf': '94ac7b1b5dc6812900e91eb8e9250221a86007eadb9a3adb3259a0b5420a3ce0',
    '/etc/rsyslog.d/1-kernel.conf': 'afd33f82261824b1e55f5d76226f9655f366b68948c78d42f3bf25072644998f',
    '/etc/rsyslog.d/2-omada.conf': 'd62055a4acfdaa2b3cc736dfaf4c4badc7301691528ee9d4fd5c2bcf5a6845e2',
    '/etc/rsyslog.d/3-sso.conf': '84dd2f9501c6764da4b2c508e5f084c0226ed6c65799427b1878d63f65e1d734',
    '/etc/rsyslog.d/4-suricata.conf': 'e510eac867c69edab88b36c71c0a2475f01436dcc742d29afb25c19e4fc49ca5',
    '/etc/rsyslog.d/default.conf': '80d05fd5ca87bf8e95d6781ad550db1f19c33c64fde225d5694db075d1256d98',
    '/root/.zshrc': 'a7fc4d33f1b03c51044a7a5e631c8a22dc63d2b9269ddf6944319176b7cb1d68',
    '/etc/rc.local': '9075a7a5e32efc18e6d89237740c866bc232beff9b38910f04b419c85f14b06d',
    '/root/fwon.sh': '8d142776193a2040ad9c0372132edbb8ac9795fbe9b69c0989711a4800f95eaa',
    '/root/fwoff.sh': 'd1111481c8e99f8521ffa30c44adf55ff40577e661288f41a9467e48b47a636a',
    '/etc/profile.d/proxy.sh': '8c23b11df309423cdea3dca81b790e645de71c3e1c8e9764c28e6b13214732a0',
    '/etc/environment': '376126bb503e5f715a756e053e3337b064a5ace20e44c7285b7a6467bcaaffed',
}
ZSH_FUNCTION_NAMES = ['sc', 'ai', 'aid', 'aidc', 'aig', 'aiod', 'aiodc', 'aiog', 'aiok', 'aiol', 'aiom5', 'aiom7', 'aioq', 'aip']
ZSH_FUNCTIONS_HASH = '223b009ec4b473332aa78284b5d27dc7cb30f3df7ae026a1baf435f8fc35a71c'

if __name__ == '__main__':
    unittest.main()
