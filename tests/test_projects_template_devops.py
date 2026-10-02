#!/usr/bin/env python3
"""Génération du modèle DevOps avec binaires et serveur isolés."""
import getpass
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / 'modules/projects/template.sh'


class ProjectsTemplateDevopsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-devops-')
        self.addCleanup(self.temporary.cleanup)
        self.fixture = Path(self.temporary.name)
        self.home = self.fixture / 'home'
        self.template = self.home / 'datas/template'
        self.template.mkdir(parents=True)
        self.host_bin = self.fixture / 'host-bin'
        self.metadata = self.fixture / 'python-packages'
        self.metadata.mkdir()
        self.document = self.template / 'DEVOPS.md'
        self.query_log = self.fixture / 'queries.txt'
        self.environment = dict(os.environ, TEST_DEVOPS_HOME=str(self.home),
                                TEST_HOST_BIN=str(self.host_bin),
                                TEST_METADATA=str(self.metadata),
                                TEST_QUERY_LOG=str(self.query_log),
                                TEST_VENV_STATUS='0', TEST_PG_FAILURE='0')
        self.executable(self.host_bin / 'docker', "printf 'Docker version 29.1.2, build fixture\\n'")
        self.executable(self.host_bin / 'docker-compose', "printf 'Docker Compose version v5.2.3\\n'")
        self.executable(self.host_bin / 'git', "printf 'git version 2.47.9\\n'")
        self.executable(self.host_bin / 'openssl', "printf 'OpenSSL 3.5.3 1 Jan 2026\\n'")
        self.executable(self.home / 'go/current/bin/go', "printf 'go version go1.25.3 linux/amd64\\n'")
        self.executable(self.home / '.opencode/bin/opencode', "printf '1.2.8\\n'")
        self.executable(self.home / 'node/current/bin/node', r'''
case "$1" in
    --version) printf 'v24.3.1\n' ;;
    */npm) printf '11.5.2\n' ;;
    */openspec) printf '1.3.9\n' ;;
    *) exit 1 ;;
esac
''')
        for relative in ('node/current/bin/npm', '.local/npm/bin/openspec'):
            path = self.home / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('#!/usr/bin/env node\n', encoding='utf-8')
            path.chmod(0o755)
        self.executable(self.home / 'python/current/bin/python3', r'''
if [ "$1" = --version ]; then
    printf 'Python 3.13.9\n'
elif [ "$3" = -c ]; then
    exit "$TEST_VENV_STATUS"
elif [ "$3" = "$TEST_DEVOPS_HOME/python/current/bin/pip3" ]; then
    exec /usr/bin/python3 -I -B "$3" "$4"
else
    exec /usr/bin/python3 -I -B -c 'import sys; sys.path.insert(0, sys.argv.pop(1)); exec(sys.stdin.read())' "$TEST_METADATA" "$4" "$5"
fi
''')
        self.executable(self.home / 'python/current/bin/pip3', "print('pip 25.3.7 from fixture (python 3.13)')")
        self.executable(self.host_bin / 'psql', r'''
if [ "$1" = --version ]; then
    printf 'psql (PostgreSQL) 17.6\n'
    exit 0
fi
printf '%s|%s|%s\n' "$PGHOST" "$PGPORT" "$*" >> "$TEST_QUERY_LOG"
if [ "$TEST_PG_FAILURE" = 1 ]; then
    printf 'test-only-private-value\n' >&2
    exit 1
fi
[ "$PGPASSWORD" = "${TEST_EXPECTED_PASSWORD:-test-only-private-value}" ] || exit 1
[ "$PGUSER" = 'test-only-user' ] || exit 1
[ "$PGDATABASE" = 'test-only-database' ] || exit 1
printf '16.4\n'
''')
        (self.template / 'project.env').write_text(
            'PG_HOST=database.example.test\nPG_PORT=5544\n'
            'PG_DATABASE=test-only-database\nPG_USERNAME=test-only-user\n'
            "PG_PASSWORD='test-only-private-value'\n", encoding='utf-8',
        )

    @staticmethod
    def executable(path, body):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('#!/bin/sh\n' + body + '\n', encoding='utf-8')
        path.chmod(0o755)

    def run_generation(self, extra='', user=None):
        # Remplacer uniquement le domicile fixé par le contrat public, dans le
        # code exécuté en mémoire : aucun accès à un véritable modèle utilisateur.
        source = MODULE.read_text(encoding='utf-8')
        home_assignment = 'local devops_home="/home/${ENV_DEVOPS_USER:-}"'
        self.assertEqual(source.count(home_assignment), 1,
                         'Le test doit isoler exactement le domicile, sans toucher au modèle réel')
        source = source.replace(home_assignment, 'local devops_home="$TEST_DEVOPS_HOME"')
        script = source + r'''
print_error() { printf 'ERREUR:%s\n' "$*" >&2; }
print_info() { printf 'INFO:%s\n' "$*"; }
print_success() { printf 'SUCCES:%s\n' "$*"; }
projects_template_devops_host_binary() {
    if [[ -x "${TEST_HOST_BIN}/$1" ]]; then
        printf '%s\n' "${TEST_HOST_BIN}/$1"
    else
        return 1
    fi
}
ENV_DEVOPS_USER="$1"
'''
        script += extra + '\nprojects_template_devops\n'
        return subprocess.run(['bash', '-Eeuo', 'pipefail', '-c', script, 'bash',
                               getpass.getuser() if user is None else user],
                              text=True, capture_output=True, env=self.environment,
                              timeout=30, check=False)

    def successful_document(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return self.document.read_text(encoding='utf-8')

    def test_generation_structure_versions_and_executable_paths(self):
        content = self.successful_document(self.run_generation())
        self.assertEqual(re.findall(r'^# (.+)$', content, re.M), [
            'DEVOPS.md — Template', "Système d'exploitation", 'Docker',
            'Docker-Compose', 'Git', 'Go', 'Node', 'NPM', 'OpenCode',
            'OpenSpec', 'OpenSSL', 'PostgreSQL Client', 'PostgreSQL Serveur',
            'Python', 'Python - Dépendances du projet - Source de vérité `pyproject.toml`',
            'Python - Gestionnaire de paquets',
        ])
        self.assertIn('Version : 0.2', content)
        for title, version, path in (
            ('Docker', '29.1.2', self.host_bin / 'docker'),
            ('Docker-Compose', '5.2.3', self.host_bin / 'docker-compose'),
            ('Git', '2.47.9', self.host_bin / 'git'),
            ('Go', '1.25.3', self.home / 'go/current/bin/go'),
            ('Node', '24.3.1', self.home / 'node/current/bin/node'),
            ('NPM', '11.5.2', self.home / 'node/current/bin/npm'),
            ('OpenCode', '1.2.8', self.home / '.opencode/bin/opencode'),
            ('OpenSpec', '1.3.9', self.home / '.local/npm/bin/openspec'),
            ('OpenSSL', '3.5.3', self.host_bin / 'openssl'),
            ('PostgreSQL Client', '17.6', self.host_bin / 'psql'),
            ('Python', '3.13.9', self.home / 'python/current/bin/python3'),
            ('Python - Gestionnaire de paquets', '25.3.7', self.home / 'python/current/bin/pip3'),
        ):
            self.assertIn(f'# {title}\n\n  * {version}\n  * {path}\n', content)
        self.assertIn('  * venv: disponible', content)
        self.assertIn('# PostgreSQL Serveur\n\n  * 16.4\n  * database.example.test:5544', content)
        self.assertIn('pyproject.toml absent', content)
        self.assertNotIn('psycopg', content)
        self.assertNotIn('\r', content)
        self.assertEqual(self.document.stat().st_mode & 0o777, 0o644)
        self.assertEqual(self.query_log.read_text().strip(),
                         'database.example.test|5544|-X -w -A -t -q -c SHOW server_version;')
        self.assertNotIn('test-only-private-value', content)
        self.assertNotIn('test-only-user', content)
        self.assertNotIn('test-only-database', content)

    def test_update_refreshes_versions_preserves_mode_and_is_idempotent(self):
        self.document.write_text('Version : 0.2\nancienne version 99.0.0\n', encoding='utf-8')
        self.document.chmod(0o640)
        before = self.document.stat()
        first = self.successful_document(self.run_generation())
        self.assertNotIn('99.0.0', first)
        second = self.successful_document(self.run_generation())
        self.assertEqual(first, second)
        after = self.document.stat()
        self.assertEqual(after.st_mode & 0o777, 0o640)
        self.assertEqual((before.st_uid, before.st_gid), (after.st_uid, after.st_gid))
        self.assertEqual(list(self.template.glob('.DEVOPS.md.*')), [])

    def test_missing_directory_returns_without_probing_or_creating_it(self):
        self.template.rename(self.home / 'existing-fixture')
        result = self.run_generation('projects_template_devops_render() { return 99; }')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dossier modèle absent', result.stdout)
        self.assertFalse(self.template.exists())
        self.assertFalse(self.query_log.exists())

    def test_missing_user_tools_never_use_host_versions(self):
        for relative in ('go/current/bin/go', 'node/current/bin/node',
                         '.opencode/bin/opencode', '.local/npm/bin/openspec',
                         'python/current/bin/python3', 'python/current/bin/pip3'):
            (self.home / relative).unlink()
        for name in ('go', 'node', 'npm', 'python3', 'pip3', 'openspec', 'opencode'):
            self.executable(self.host_bin / name, "printf '99.0.0\\n'")
        self.environment['PATH'] = str(self.host_bin) + ':' + os.environ['PATH']
        content = self.successful_document(self.run_generation())
        self.assertNotIn('99.0.0', content)
        self.assertIn('# NPM\n\n  * indisponible (Node DevOps absent)', content)
        self.assertIn('# Python\n\n  * indisponible (binaire absent)', content)
        self.assertIn('venv: indisponible', content)

    def test_failed_probe_and_venv_are_explicit(self):
        self.executable(self.home / '.opencode/bin/opencode', 'exit 7')
        self.environment['TEST_VENV_STATUS'] = '1'
        content = self.successful_document(self.run_generation())
        self.assertIn('# OpenCode\n\n  * indisponible (sonde échouée)', content)
        self.assertIn('venv: indisponible', content)

    def test_node_and_pip_scripts_use_devops_interpreters_despite_their_shebangs(self):
        for relative in ('node/current/bin/npm', '.local/npm/bin/openspec',
                         'python/current/bin/pip3'):
            path = self.home / relative
            body = path.read_text(encoding='utf-8').split('\n', 1)[1]
            path.write_text('#!/nonexistent/host-interpreter\n' + body, encoding='utf-8')
        content = self.successful_document(self.run_generation())
        self.assertIn('# NPM\n\n  * 11.5.2', content)
        self.assertIn('# OpenSpec\n\n  * 1.3.9', content)
        self.assertIn('# Python - Gestionnaire de paquets\n\n  * 25.3.7', content)
        (self.home / 'python/current/bin/python3').unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn('# Python - Gestionnaire de paquets\n\n  * indisponible (Python DevOps absent)', content)

    def test_host_binary_resolution_ignores_user_path(self):
        script = 'source "$1"\nprojects_template_devops_host_binary git\n'
        self.environment['PATH'] = str(self.host_bin) + ':' + os.environ['PATH']
        result = subprocess.run(['bash', '-c', script, 'bash', str(MODULE)],
                                text=True, capture_output=True, env=self.environment, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotEqual(result.stdout.strip(), str(self.host_bin / 'git'))
        self.assertTrue(result.stdout.strip().startswith(('/usr/bin/', '/usr/local/bin/', '/bin/')))

    def test_dependencies_follow_manifest_and_installed_metadata(self):
        (self.template / 'pyproject.toml').write_text(
            '[project]\ndependencies = ["psycopg>=3.2", "missing-package>=1", '
            '"direct-package @ https://user:test-only-private-value@example.test/wheel"]\n',
            encoding='utf-8',
        )
        distribution = self.metadata / 'psycopg-3.3.5.dist-info'
        distribution.mkdir()
        (distribution / 'METADATA').write_text('Name: psycopg\nVersion: 3.3.5\n', encoding='utf-8')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'psycopg >=3.2 : 3.3.5 --> {self.home}/python/current/bin/python3', content)
        self.assertIn('missing-package >=1 : non installé', content)
        self.assertIn('direct-package (référence directe déclarée dans pyproject.toml)', content)
        self.assertNotIn('https://user:', content)
        self.assertNotIn('test-only-private-value', content)

    def test_invalid_and_dynamic_manifests_are_explicit(self):
        for manifest, expected in (
            ('[project\n', 'pyproject.toml illisible ou invalide'),
            ('[project]\ndynamic = ["dependencies"]\n', 'Dépendances dynamiques'),
            ('[project]\ndependencies = []\n', 'Aucune dépendance déclarée'),
        ):
            with self.subTest(manifest=manifest):
                (self.template / 'pyproject.toml').write_text(manifest, encoding='utf-8')
                content = self.successful_document(self.run_generation())
                self.assertIn(expected, content)

    def test_server_failures_do_not_leak_errors_or_use_client_version(self):
        self.environment['TEST_PG_FAILURE'] = '1'
        result = self.run_generation()
        content = self.successful_document(result)
        self.assertIn('serveur inaccessible ou version non vérifiable', content)
        self.assertNotIn('test-only-private-value', content + result.stdout + result.stderr)
        self.assertNotIn('# PostgreSQL Serveur\n\n  * 17.6', content)

    def test_missing_configuration_does_not_connect(self):
        (self.template / 'project.env').unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn('configuration absente ou invalide', content)
        self.assertIn('fichier project.env absent ou illisible', content)
        self.assertIn('adresse non configurée', content)
        self.assertFalse(self.query_log.exists())

    def test_server_alias_host_and_port_and_missing_client(self):
        project_env = self.template / 'project.env'
        project_env.write_text(project_env.read_text().replace(
            'PG_HOST=database.example.test\nPG_PORT=5544',
            'export PG_SERVER="database.example.test:5544"'), encoding='utf-8')
        content = self.successful_document(self.run_generation())
        self.assertIn('# PostgreSQL Serveur\n\n  * 16.4\n  * database.example.test:5544', content)
        self.query_log.unlink()
        (self.host_bin / 'psql').unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn('# PostgreSQL Serveur\n\n  * indisponible (client PostgreSQL absent)', content)
        self.assertFalse(self.query_log.exists())

    def test_configuration_is_never_executed(self):
        marker = self.fixture / 'must-not-exist'
        (self.template / 'project.env').write_text(
            f'PG_HOST=$(touch {marker})\nPG_PORT=5432\n', encoding='utf-8',
        )
        content = self.successful_document(self.run_generation())
        self.assertIn('configuration absente ou invalide', content)
        self.assertIn('affectation non littérale pour PG_HOST', content)
        self.assertFalse(marker.exists())
        self.assertFalse(self.query_log.exists())

    def test_invalid_host_or_port_does_not_connect(self):
        for configuration, diagnostic in (
                ('PG_HOST=https://user:password@example.test\n', 'adresse invalide'),
                ('PG_HOST=database.example.test\nPG_PORT=99999\n', 'PG_PORT invalide'),
                ('PG_PORT=5432\n', 'PG_HOST ou PG_SERVER absent')):
            with self.subTest(configuration=configuration):
                (self.template / 'project.env').write_text(configuration, encoding='utf-8')
                content = self.successful_document(self.run_generation())
                self.assertIn('adresse non configurée', content)
                self.assertIn(diagnostic, content)
                self.assertNotIn('user:password', content)
                self.assertFalse(self.query_log.exists())

    def test_password_special_characters_remain_literal_and_private(self):
        project_env = self.template / 'project.env'
        marker = self.fixture / 'password-command-must-not-run'
        password = f'test-only-private-value$expression;$(touch {marker})`id`&<>#'
        self.environment['TEST_EXPECTED_PASSWORD'] = password
        for quote in ('"', "'"):
            with self.subTest(quote=quote):
                project_env.write_text(
                    'PG_HOST=database.example.test\nPG_DATABASE=test-only-database\n'
                    'PG_USERNAME=test-only-user\n'
                    f'PG_PASSWORD={quote}{password}{quote}\n', encoding='utf-8')
                result = self.run_generation()
                content = self.successful_document(result)
                self.assertIn('# PostgreSQL Serveur\n\n  * 16.4\n  * database.example.test:5432', content)
                self.assertNotIn(password, content + result.stdout + result.stderr)
                self.assertFalse(marker.exists())
                self.assertTrue(self.query_log.exists())

    def test_render_or_replace_failure_preserves_document_and_cleans_temporary_file(self):
        for extra in ('projects_template_devops_render() { printf partial; return 1; }',
                      'mv() { return 1; }'):
            with self.subTest(extra=extra):
                self.document.write_text('document conservé\n', encoding='utf-8')
                result = self.run_generation(extra)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.document.read_text(), 'document conservé\n')
                self.assertEqual(list(self.template.glob('.DEVOPS.md.*')), [])

    def test_real_directory_permissions_prevent_writing_without_altering_document(self):
        if os.geteuid() == 0:
            self.skipTest('Root contourne les permissions ordinaires du dossier')
        self.document.write_text('document conservé\n', encoding='utf-8')
        before = self.document.stat()
        self.template.chmod(0o555)
        try:
            result = self.run_generation()
        finally:
            self.template.chmod(0o755)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de créer le fichier temporaire', result.stderr)
        self.assertEqual(self.document.read_text(), 'document conservé\n')
        self.assertEqual(self.document.stat().st_ino, before.st_ino)
        self.assertEqual(list(self.template.glob('.DEVOPS.md.*')), [])

    def test_invalid_username_and_symlink_target_are_rejected(self):
        for user in ('', '../elsewhere', 'user;command'):
            with self.subTest(user=user):
                self.assertNotEqual(self.run_generation(user=user).returncode, 0)
        target = self.fixture / 'untouched.md'
        target.write_text('conservé\n', encoding='utf-8')
        self.document.symlink_to(target)
        self.assertNotEqual(self.run_generation().returncode, 0)
        self.assertEqual(target.read_text(), 'conservé\n')

    def test_dispatch_invokes_only_the_requested_leaf_without_configuration(self):
        source = (ROOT / 'root-install-debian.sh').read_text(encoding='utf-8')
        function = re.search(r'^manage_project_action\(\) \{\n.*?^\}', source, re.M | re.S)[0]
        script = function + r'''
projects_template_devops() { printf 'generation\n'; }
rid_display_command_error() { printf 'help:%s\n' "$*"; }
manage_project_action "$@"
'''
        for arguments, status, expected in (
            (('template', 'devops'), 0, 'generation\n'),
            (('template', 'unknown'), 2, 'help:projects template'),
            (('template',), 2, 'help:projects template'),
            (('template', 'devops', 'extra'), 2, 'help:projects template'),
        ):
            with self.subTest(arguments=arguments):
                result = subprocess.run(['bash', '-Eeuo', 'pipefail', '-c', script, 'bash', *arguments],
                                        text=True, capture_output=True, check=False)
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertIn(expected, result.stdout)
                if status:
                    self.assertNotIn('generation', result.stdout)


class ProjectsTemplateDevopsRuntimeTests(unittest.TestCase):
    """Sondes réelles ; aucun remplacement du code du module testé."""

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-runtime-')
        self.addCleanup(self.temporary.cleanup)
        self.fixture = Path(self.temporary.name)
        self.home = self.fixture / 'home with spaces'
        self.home.mkdir()
        self.environment = {'PATH': '/usr/local/bin:/usr/bin:/bin', 'LC_ALL': 'C.UTF-8'}

    def runtime(self, name):
        binary = os.environ.get(f'DIU_TEST_{name.upper()}') or shutil.which(name)
        if not binary or not os.access(binary, os.X_OK):
            self.skipTest(f'Binaire réel {name} absent ; définir DIU_TEST_{name.upper()}')
        return binary

    def call_function(self, function, *arguments, cwd=None, restrict_directory=False,
                      extra='', preserve_cwd=False):
        script = 'source "$1"\nENV_DEVOPS_USER="$2"\nshift 2\n' + extra + '\n'
        script += function + ' "$@"\n'
        if preserve_cwd:
            script += 'printf "CALLER_CWD:%s\\n" "$(readlink /proc/$$/cwd)"\n'
        directory = Path(cwd) if cwd else self.home
        try:
            return subprocess.run(
                ['bash', '-Eeuo', 'pipefail', '-c', script, 'bash', str(MODULE),
                 getpass.getuser(), *map(str, arguments)], cwd=directory,
                preexec_fn=(lambda: os.chmod('.', 0)) if restrict_directory else None,
                env=self.environment, text=True, capture_output=True, timeout=25, check=False,
            )
        finally:
            if restrict_directory:
                directory.chmod(0o700)

    def test_real_go_version_from_inaccessible_caller_directory(self):
        if os.geteuid() == 0:
            self.skipTest('La reproduction des permissions nécessite un utilisateur non root')
        go = self.runtime('go')
        reference = subprocess.run([go, 'version'], cwd=self.home,
                                   env=dict(self.environment, GOTOOLCHAIN='local'),
                                   text=True, capture_output=True, timeout=10, check=False)
        self.assertEqual(reference.returncode, 0, reference.stderr)
        expected_version = reference.stdout.split()[2].removeprefix('go')
        restricted = self.fixture / 'caller'
        restricted.mkdir()
        result = self.call_function('projects_template_devops_version', 'user', self.home,
                                    go, 'version', cwd=restricted, restrict_directory=True,
                                    preserve_cwd=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [expected_version, f'CALLER_CWD:{restricted}'])

    def test_runuser_execution_envelope_preserves_arguments_and_changes_child_directory(self):
        go = self.runtime('go')
        reference = subprocess.run([go, 'version'], cwd=self.home,
                                   env=dict(self.environment, GOTOOLCHAIN='local'),
                                   text=True, capture_output=True, timeout=10, check=False)
        self.assertEqual(reference.returncode, 0, reference.stderr)
        caller = self.fixture / 'caller'
        caller.mkdir()
        # La permission de changer réellement d'identité reste hors de ce test.
        # L'enveloppe runuser exécute néanmoins le vrai shell enfant et le vrai Go.
        extra = r'''
id() { printf 'other-user\n'; }
runuser() {
    [[ "$1" == -u && "$2" == "${ENV_DEVOPS_USER}" && "$3" == -- ]] || return 99
    shift 3
    "$@"
}
'''
        result = self.call_function('projects_template_devops_user_run', self.home, '/bin/bash', '-c',
                                    'printf "CHILD_CWD:%s\\n" "$(pwd -P)"; exec "$1" version',
                                    'bash', go, cwd=caller, preserve_cwd=True, extra=extra)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [f'CHILD_CWD:{self.home}', reference.stdout.strip(),
                                                     f'CALLER_CWD:{caller}'])

    def test_real_node_ignores_host_interpreter_and_runs_from_user_home(self):
        node = self.runtime('node')
        node_binary = self.home / 'node/current/bin/node'
        node_binary.parent.mkdir(parents=True)
        node_binary.symlink_to(Path(node).resolve())
        script_binary = node_binary.parent / 'npm'
        script_binary.write_text('''#!/nonexistent/host-node
require('fs').appendFileSync(process.env.TEST_NODE_LOG, JSON.stringify({
  executable: process.execPath, directory: process.cwd(), user: process.getuid()
}) + '\\n');
console.log(process.versions.node);
''', encoding='utf-8')
        script_binary.chmod(0o755)
        log = self.fixture / 'node-provenance.jsonl'
        self.environment['TEST_NODE_LOG'] = str(log)
        caller = self.fixture / 'caller'
        caller.mkdir()
        reference = subprocess.run([node, '--version'], text=True, capture_output=True,
                                   env=self.environment, timeout=10, check=False)
        self.assertEqual(reference.returncode, 0, reference.stderr)
        result = self.call_function('projects_template_devops_version', 'node', self.home,
                                    script_binary, '--version', cwd=caller, preserve_cwd=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [reference.stdout.strip().removeprefix('v'),
                                                     f'CALLER_CWD:{caller}'])
        import json
        self.assertEqual(json.loads(log.read_text()), {
            'executable': str(Path(node).resolve()), 'directory': str(self.home), 'user': os.getuid(),
        })

    def test_real_python_virtual_environment_and_metadata_ignore_host_pythonpath(self):
        python = os.environ.get('DIU_TEST_PYTHON', sys.executable)
        python_home = self.home / 'python/current'
        created = subprocess.run([python, '-I', '-B', '-m', 'venv', '--without-pip', str(python_home)],
                                 cwd=self.home, env=self.environment, text=True,
                                 capture_output=True, timeout=20, check=False)
        self.assertEqual(created.returncode, 0, created.stderr)
        binary = python_home / 'bin/python3'
        site_packages = subprocess.run(
            [str(binary), '-I', '-B', '-c', 'import sysconfig; print(sysconfig.get_path("purelib"))'],
            env=self.environment, text=True, capture_output=True, timeout=10, check=False,
        )
        self.assertEqual(site_packages.returncode, 0, site_packages.stderr)
        distribution = Path(site_packages.stdout.strip()) / 'runtime_only-7.6.5.dist-info'
        distribution.mkdir()
        (distribution / 'METADATA').write_text('Name: runtime-only\nVersion: 7.6.5\n', encoding='utf-8')
        decoy = self.fixture / 'host-packages/runtime_only-99.99.99.dist-info'
        decoy.mkdir(parents=True)
        (decoy / 'METADATA').write_text('Name: runtime-only\nVersion: 99.99.99\n', encoding='utf-8')
        self.environment['PYTHONPATH'] = str(decoy.parent)
        template = self.home / 'datas/template'
        template.mkdir(parents=True)
        (template / 'pyproject.toml').write_text(
            '[project]\ndependencies = ["runtime-only>=7", "uninstalled-runtime-package"]\n',
            encoding='utf-8',
        )
        observed = self.call_function('projects_template_devops_dependencies', self.home, template, binary)
        self.assertEqual(observed.returncode, 0, observed.stderr)
        self.assertIn(f'runtime-only >=7 : 7.6.5 --> {binary}', observed.stdout)
        self.assertIn('uninstalled-runtime-package : non installé', observed.stdout)
        self.assertNotIn('99.99.99', observed.stdout)
        reference = subprocess.run([str(binary), '--version'], env=self.environment, text=True,
                                   capture_output=True, timeout=10, check=False)
        version = self.call_function('projects_template_devops_version', 'user', self.home, binary, '--version')
        self.assertEqual(version.returncode, 0, version.stderr)
        self.assertEqual(version.stdout.strip(), reference.stdout.split()[1])

    def test_real_timeout_bounds_a_blocking_probe(self):
        blocking_binary = self.fixture / 'blocking-tool'
        blocking_binary.write_text('#!/bin/sh\nexec /bin/sleep 20\n', encoding='utf-8')
        blocking_binary.chmod(0o755)
        started = time.monotonic()
        result = self.call_function('projects_template_devops_version', 'user', self.home, blocking_binary)
        elapsed = time.monotonic() - started
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'indisponible (sonde échouée)')
        self.assertGreaterEqual(elapsed, 14)
        self.assertLess(elapsed, 24)


if __name__ == '__main__':
    unittest.main()
