#!/usr/bin/env python3
"""Génération sudoers isolée, sans installation ni modification système."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'
VISUDO = shutil.which('visudo')
if not VISUDO and os.access('/usr/sbin/visudo', os.X_OK):
    VISUDO = '/usr/sbin/visudo'


class DevopsSudoersTests(unittest.TestCase):
    SCOPE = 'devops'
    LABEL = 'DevOps'
    TARGET = 'builder'

    @classmethod
    def setUpClass(cls):
        source = SCRIPT.read_text()
        functions = []
        for name in ('configure_environment_sudoers', 'configure_devops_sudoers',
                     'configure_docker_sudoers'):
            match = re.search(r'^' + name + r'\(\) \{\n.*?^\}', source, re.M | re.S)
            if not match:
                raise AssertionError(f'fonction {name} absente')
            functions.append(match.group())
        cls.function = '\n'.join(functions)
        variable = 'ENVIRONMENTS_DEVOPS' if cls.SCOPE == 'devops' else 'ENVIRONMENT_DOCKER'
        next_condition = ('if [ "${ENVIRONMENT_DOCKER:-0}" -eq 1 ]\nthen\n'
                          if cls.SCOPE == 'devops' else 'if [ "$ENV_IA" -eq 1 ]\nthen\n')
        condition = ('if [ "${ENVIRONMENTS_DEVOPS:-0}" -eq 1 ]\nthen\n'
                     if cls.SCOPE == 'devops' else 'if [ "${ENVIRONMENT_DOCKER:-0}" -eq 1 ]\nthen\n')
        start = source.index(condition)
        end = source.index(next_condition, start)
        block = source[start:end]
        cls.environment_block = block
        call = f'  configure_{cls.SCOPE}_sudoers /etc/passwd /etc/login.defs /etc/sudoers.d\n'
        if block.count(call) != 1:
            raise AssertionError(f'appel unique {cls.SCOPE} absent')
        # Préserver la branche réelle de l'appel ; aucune installation du monolithe.
        if cls.SCOPE == 'docker':
            active, inactive = block.split('\nelse\n', 1)
            active_tail = active[active.index(call):] if call in active else '  :\n'
            inactive_tail = inactive[inactive.index(call):] if call in inactive else '  :\nfi\n'
            cls.activation = (f'if [ "${variable}" -eq 1 ]; then\n' + active_tail
                              + '\nelse\n' + inactive_tail)
        else:
            tail = block[block.index(call):]
            cls.activation = f'if [ "${{ENVIRONMENTS_DEVOPS:-0}}" -eq 1 ]; then\n' + tail

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='.diu-sudoers-test.', dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name)
        self.passwd = self.path / 'passwd'
        self.login_defs = self.path / 'login.defs'
        self.sudoers = self.path / 'sudoers.d'
        self.sudoers.mkdir()
        self.destination = self.sudoers / f'99-diu-{self.SCOPE}'
        self.calls = self.path / 'calls'
        self.login_defs.write_text('UID_MIN 1000\nUID_MAX 60000\n')
        self.passwd.write_text(
            'root:x:0:0::/root:/bin/bash\n'
            'alice:x:1000:1000::/home/alice:/bin/bash\n'
            'bob:x:60000:60000::/home/bob:/bin/sh\n'
            'below:x:999:999::/home/below:/bin/bash\n'
            'above:x:60001:60001::/home/above:/bin/bash\n'
            'nobody:x:65534:65534::/nonexistent:/usr/sbin/nologin\n'
            'blocked:x:1001:1001::/home/blocked:/usr/sbin/nologin\n'
            'false_shell:x:1002:1002::/home/false_shell:/bin/false\n'
            'empty_shell:x:1003:1003::/home/empty_shell:\n'
            'missing_shell:x:1004:1004::/home/missing_shell:/nonexistent/shell\n'
            'builder:x:1005:1005::/home/builder:/bin/bash\n'
            'containers:x:1006:1006::/home/containers:/bin/bash\n'
            'assistant:x:1007:1007::/home/assistant:/bin/bash\n'
        )

    def run_generator(self, fault='', enabled=1, target=None, activation=False, scope=None):
        target = self.TARGET if target is None else target
        scope = self.SCOPE if scope is None else scope
        # Les arguments privilégiés sont journalisés ; seul chmod/mv agit
        # réellement, exclusivement dans le répertoire temporaire du test.
        stubs = r'''
id() { [ "$MISSING_TARGET" != 1 ]; }
visudo() {
    printf 'visudo <%s> <%s>\n' "$1" "$2" >> "$CALLS"
    [ "$FAULT" != visudo ] || return 1
    if [ "$FAULT" = invalid_candidate ]; then printf 'invalid )\n' > "$2"; fi
    if [ -n "$REAL_VISUDO" ]; then "$REAL_VISUDO" "$@"; fi
}
chown() {
    printf 'chown <%s>\n' "$1" >> "$CALLS"
    [ "$FAULT" != chown ]
}
chmod() {
    printf 'chmod <%s>\n' "$1" >> "$CALLS"
    [ "$FAULT" != chmod ] || return 1
    command chmod "$@"
}
mv() {
    printf 'mv <%s> <%s>\n' "$1" "$2" >> "$CALLS"
    [ "$FAULT" != mv ] || return 1
    command mv "$@"
}
install() {
    printf 'install\n' >> "$CALLS"
    [ "$FAULT" != install ] || return 1
    command mkdir -p -- "${@: -1}"
}
mktemp() {
    [ "$FAULT" != mktemp ] || return 1
    command mktemp "$@"
}
awk() {
    if [ "$FAULT" = summary_awk ] && [[ "${@: -1}" == "$SUDOERS_DIR"/.diu-* ]]; then return 1; fi
    command awk "$@"
}
command() {
    if [ "$*" = '-v visudo' ] && [ "$FAULT" = missing_visudo ]; then return 1; fi
    builtin command "$@"
}
'''
        env = dict(os.environ, ENV_DEVOPS_USER='builder', ENV_DOCKER_USER='containers',
                   ENV_IA_USER='assistant', ENVIRONMENTS_DEVOPS=str(enabled),
                   ENVIRONMENT_DOCKER=str(enabled), REQUESTED_SCOPE=scope, FAULT=fault,
                   MISSING_TARGET='1' if fault == 'missing_target' else '0',
                   REAL_VISUDO=VISUDO or '', CALLS=str(self.calls),
                   SUDOERS_DIR=str(self.sudoers))
        if scope in ('devops', 'docker'):
            env['ENV_' + scope.upper() + '_USER'] = target
        if activation:
            # Remplacer les chemins système uniquement dans cet appel isolé.
            call = self.activation.replace(
                f'  configure_{self.SCOPE}_sudoers /etc/passwd /etc/login.defs /etc/sudoers.d\n',
                f'  configure_{self.SCOPE}_sudoers "$@"\n')
        elif scope != self.SCOPE:
            call = 'configure_environment_sudoers "$REQUESTED_SCOPE" "$@"\n'
        else:
            call = f'configure_{self.SCOPE}_sudoers "$@"\n'
        return subprocess.run(
            ['bash', '--noprofile', '--norc', '-c',
             'set -Eeuo pipefail\n' + stubs + self.function + '\n' + call,
             'bash', str(self.passwd), str(self.login_defs), str(self.sudoers)],
            env=env, text=True, capture_output=True)

    def assert_no_candidate(self):
        self.assertEqual(list(self.sudoers.glob('.diu-*.*')), [])

    def test_selection_publication_and_permissions(self):
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text(),
                         f'# Managed by DIU: local human accounts to {self.LABEL}\n'
                         f'alice ALL=({self.TARGET}) NOPASSWD: ALL\n'
                         f'bob ALL=({self.TARGET}) NOPASSWD: ALL\n')
        self.assertEqual(self.destination.stat().st_mode & 0o777, 0o440)
        calls = self.calls.read_text().splitlines()
        self.assertTrue(calls[0].startswith('visudo <-cf> '))
        self.assertEqual(calls[1:], ['chown <root:root>', 'chmod <0440>', 'mv <-fT> <-->'])
        self.assertEqual(result.stdout.splitlines()[-1],
                         f'✅ Sudoers {self.LABEL} configuré pour alice bob.')
        self.assert_no_candidate()

    def test_summary_follows_filtered_rule_order(self):
        self.passwd.write_text('ignored:x:1000:1000::/home/ignored:/bin/false\n'
                               'zoe:x:1001:1001::/home/zoe:/bin/bash\n'
                               'alice:x:1002:1002::/home/alice:/bin/sh\n'
                               'zoe:x:1001:1001::/home/zoe:/bin/bash\n')
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1],
                         f'✅ Sudoers {self.LABEL} configuré pour zoe alice.')
        self.assertEqual(self.destination.read_text(),
                         f'# Managed by DIU: local human accounts to {self.LABEL}\n'
                         f'zoe ALL=({self.TARGET}) NOPASSWD: ALL\n'
                         f'alice ALL=({self.TARGET}) NOPASSWD: ALL\n')

    def test_idempotence_and_other_fragments_preserved(self):
        other = self.sudoers / 'other-policy'
        other.write_text('# unrelated\n')
        self.assertEqual(self.run_generator().returncode, 0)
        content = self.destination.read_bytes()
        self.assertEqual(self.run_generator().returncode, 0)
        self.assertEqual(self.destination.read_bytes(), content)
        self.assertEqual(other.read_text(), '# unrelated\n')
        self.assert_no_candidate()

    def test_configured_uid_limits(self):
        self.login_defs.write_text('# custom range\nUID_MIN 1001\nUID_MAX 1001\n')
        self.passwd.write_text('custom:x:1001:1001::/home/custom:/bin/sh\n')
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'custom ALL=({self.TARGET}) NOPASSWD: ALL\n', self.destination.read_text())

    def test_non_executable_shell_and_directory_excluded(self):
        shell = self.path / 'shell'
        shell.write_text('#!/bin/sh\n')
        shell.chmod(0o644)
        self.passwd.write_text(f'nonexec:x:1000:1000::/home/nonexec:{shell}\n'
                               f'directory:x:1001:1001::/home/directory:{self.path}\n')
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('NOPASSWD', self.destination.read_text())

    def test_empty_selection_replaces_managed_rules(self):
        self.destination.write_text('old rule\n')
        self.passwd.write_text('root:x:0:0::/root:/bin/bash\n')
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text(),
                         f'# Managed by DIU: local human accounts to {self.LABEL}\n')
        self.assertEqual(result.stdout.splitlines()[-1],
                         f'ℹ️ Sudoers {self.LABEL} : aucun compte humain retenu.')
        self.assertNotIn('configuré pour', result.stdout)

    def test_duplicate_local_account_has_one_rule(self):
        self.passwd.write_text('alice:x:1000:1000::/home/alice:/bin/bash\n' * 2)
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text().count('alice ALL='), 1)

    def test_invalid_uid_limits_preserve_previous_fragment(self):
        self.destination.write_text('previous policy\n')
        for content in ('', 'UID_MIN 1000\n', 'UID_MIN invalid\nUID_MAX 60000\n',
                        'UID_MIN 0\nUID_MAX 60000\n', 'UID_MIN 60000\nUID_MAX 1000\n'):
            with self.subTest(content=content):
                self.login_defs.write_text(content)
                result = self.run_generator()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('UID_MIN/UID_MAX invalides', result.stderr)
                self.assertEqual(self.destination.read_text(), 'previous policy\n')
                self.assert_no_candidate()

    def test_unreadable_inputs_fail_without_replacing_policy(self):
        self.destination.write_text('previous policy\n')
        for path in (self.passwd, self.login_defs):
            with self.subTest(path=path.name):
                content = path.read_text()
                path.unlink()
                result = self.run_generator()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.destination.read_text(), 'previous policy\n')
                self.assert_no_candidate()
                path.write_text(content)

    def test_missing_target_preserves_existing_rules(self):
        self.destination.write_text('previous policy\n')
        result = self.run_generator(fault='missing_target')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('ignoré', result.stdout)
        self.assertNotIn('configuré pour', result.stdout)
        self.assertEqual(self.destination.read_text(), 'previous policy\n')
        self.assertFalse(self.calls.exists())
        self.assert_no_candidate()

    def test_activation_at_end_of_environment_block(self):
        result = self.run_generator(activation=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.destination.exists())
        self.assertEqual(result.stdout.splitlines()[-1],
                         f'✅ Sudoers {self.LABEL} configuré pour alice bob.')

    def test_disabled_environment_leaves_policy_unchanged(self):
        self.destination.write_text('previous policy\n')
        result = self.run_generator(enabled=0, activation=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text(), 'previous policy\n')
        self.assertFalse(self.calls.exists())
        self.assertEqual(result.stdout, '')
        self.assert_no_candidate()

    def test_failure_preserves_policy_and_cleans_candidate(self):
        self.destination.write_text('previous policy\n')
        for fault in ('visudo', 'chown', 'chmod', 'mv', 'mktemp', 'missing_visudo', 'summary_awk'):
            with self.subTest(fault=fault):
                result = self.run_generator(fault=fault)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Sudoers ' + self.LABEL, result.stderr)
                self.assertNotIn('configuré pour', result.stdout)
                self.assertEqual(self.destination.read_text(), 'previous policy\n')
                self.assert_no_candidate()

    def test_missing_directory_created_or_error_reported(self):
        self.sudoers.rmdir()
        result = self.run_generator(fault='install')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.sudoers.exists())
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.destination.exists())

    def test_unsafe_account_names_preserve_previous_policy(self):
        for name in ('bad,user', 'bad user', '!alice', 'bad:account'):
            with self.subTest(name=name):
                self.destination.write_text('# previous policy\n')
                result = self.run_generator(target=name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('nom du compte cible incompatible', result.stderr)
                self.assertEqual(self.destination.read_text(), '# previous policy\n')
        self.passwd.write_text('bad,user:x:1000:1000::/home/bad:/bin/bash\n')
        result = self.run_generator()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('nom de compte local incompatible', result.stderr)
        self.assertEqual(self.destination.read_text(), '# previous policy\n')
        self.assert_no_candidate()

    @unittest.skipUnless(VISUDO, 'visudo non disponible')
    def test_real_visudo_rejects_invalid_candidate(self):
        self.destination.write_text('# previous policy\n')
        result = self.run_generator(fault='invalid_candidate')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.destination.read_text(), '# previous policy\n')
        self.assert_no_candidate()


if __name__ == '__main__':
    unittest.main()
