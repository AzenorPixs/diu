#!/usr/bin/env python3
"""Génération du modèle DevOps avec binaires et serveur isolés."""
import getpass
import json
import os
from pathlib import Path
import re
import shutil
import string
import subprocess
import sys
import tempfile
import time
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / 'modules/projects/template.sh'
CONTAINER_TEST_AUTHORIZATION = (
    'Les agents de codage et les agents orchestrateurs sont autorisés à préparer, '
    'exécuter, répéter et nettoyer les tests du projet dans ce conteneur, '
    'y compris avec les droits root, sans demander d’approbation supplémentaire. '
    'Cette autorisation couvre le conteneur et les ressources dédiées aux tests.'
)


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
        self.clock_log = self.fixture / 'clock.txt'
        self.probe_order_log = self.fixture / 'probe-order.txt'
        self.hostname_log = self.fixture / 'hostname-queries.txt'
        self.tpm_devices = self.fixture / 'tpm-devices'
        self.tpm_sysfs = self.fixture / 'tpm-sysfs'
        self.tpm_devices.mkdir()
        self.tpm_sysfs.mkdir()
        self.tpm_log = self.fixture / 'tpm-queries.txt'
        self.environment = dict(os.environ, TEST_DEVOPS_HOME=str(self.home),
                                TEST_HOST_BIN=str(self.host_bin),
                                TEST_METADATA=str(self.metadata),
                                TEST_QUERY_LOG=str(self.query_log),
                                TEST_CLOCK_LOG=str(self.clock_log),
                                TEST_PROBE_ORDER_LOG=str(self.probe_order_log),
                                TEST_HOSTNAME_LOG=str(self.hostname_log),
                                TEST_HOSTNAME_OUTPUT='hvp1.pixs.fr',
                                TEST_CLOCK_OUTPUT='2026-10-09T06:30:00Z',
                                TEST_VENV_STATUS='0', TEST_PG_FAILURE='0',
                                ENV_DEVOPS_TESTS_DOCKER='1', ENV_DEVOPS_TESTS_LXC='0')
        self.environment.update(TEST_TPM_DEVICES=str(self.tpm_devices),
                                TEST_TPM_SYSFS=str(self.tpm_sysfs),
                                TEST_TPM_LOG=str(self.tpm_log),
                                TEST_TPM_PROPERTIES=str(self.fixture / 'tpm-properties'),
                                TEST_TPM_PCRS=str(self.fixture / 'tpm-pcrs'))
        self.environment.pop('DEVOPS_PROJECTS_ROOT', None)
        self.environment.pop('SYSTEM_DEBIAN_ENVIRONNEMENT', None)
        self.executable(self.host_bin / 'date', r'''
[ "$#" -eq 2 ] && [ "$1" = -u ] && [ "$2" = +%Y-%m-%dT%H:%M:%SZ ] || exit 9
printf '%s\n' "$*" >> "$TEST_CLOCK_LOG"
printf 'clock\n' >> "$TEST_PROBE_ORDER_LOG"
printf '%s\n' "$TEST_CLOCK_OUTPUT"
''')
        self.executable(self.host_bin / 'hostname', r'''
[ "$#" -eq 1 ] && [ "$1" = -f ] || exit 9
printf '%s\n' "$*" >> "$TEST_HOSTNAME_LOG"
printf '%s\n' "$TEST_HOSTNAME_OUTPUT"
''')
        self.executable(self.host_bin / 'docker',
                        '[ "$#" -eq 1 ] && [ "$1" = --version ] || exit 9\n'
                        'printf "docker\\n" >> "$TEST_PROBE_ORDER_LOG"\n'
                        "printf 'Docker version 29.1.2, build fixture\\n'")
        self.executable(self.host_bin / 'docker-compose', "printf 'Docker Compose version v5.2.3\\n'")
        self.executable(self.host_bin / 'git', "printf 'git version 2.47.9\\n'")
        self.executable(self.host_bin / 'openssl', "printf 'OpenSSL 3.5.3 1 Jan 2026\\n'")
        self.executable(self.host_bin / 'chromium',
                        '[ "$#" -eq 1 ] && [ "$1" = --version ] || exit 9\n'
                        "printf 'Chromium 134.0.6998.88\\n'")
        self.executable(self.host_bin / 'firefox',
                        '[ "$#" -eq 1 ] && [ "$1" = --version ] || exit 9\n'
                        "printf 'Mozilla Firefox 140.0.4esr\\n'")
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
elif [ "$3" = -S ]; then
    shift 4
    exec /usr/bin/python3 -I -B -S - "$@"
else
    shift 3
    exec /usr/bin/python3 -I -B -c 'import sys; sys.path.insert(0, sys.argv.pop(1)); exec(sys.stdin.read())' "$TEST_METADATA" "$@"
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

    def run_generation(self, extra='', user=None, project='template', projects_root=None,
                       arguments=None, batch=False, source_replacements=()):
        # Remplacer uniquement le domicile fixé par le contrat public, dans le
        # code exécuté en mémoire : aucun accès à un véritable modèle utilisateur.
        source = MODULE.read_text(encoding='utf-8')
        home_assignment = 'local devops_home="/home/${ENV_DEVOPS_USER:-}"'
        self.assertEqual(source.count(home_assignment), 4,
                         'Le test doit isoler les quatre domiciles, sans toucher aux projets réels')
        source = source.replace(home_assignment, 'local devops_home="$TEST_DEVOPS_HOME"')
        tpm_roots = 'local device_root="${1:-/dev}" sysfs_root="${2:-/sys/class/tpm}"'
        self.assertEqual(source.count(tpm_roots), 1)
        source = source.replace(tpm_roots,
                                'local device_root="$TEST_TPM_DEVICES" sysfs_root="$TEST_TPM_SYSFS"')
        for before, after in source_replacements:
            self.assertEqual(source.count(before), 1)
            source = source.replace(before, after)
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
        function = 'projects_template_devops_all' if batch else 'projects_template_devops'
        script += extra + '\nshift\n' + function + ' "$@"\n'
        environment = dict(self.environment)
        if projects_root is not None:
            environment['DEVOPS_PROJECTS_ROOT'] = str(projects_root)
        return subprocess.run(['bash', '-Eeuo', 'pipefail', '-c', script, 'bash',
                               getpass.getuser() if user is None else user,
                               *(arguments if arguments is not None else (() if batch else (project,)))],
                              text=True, capture_output=True, env=environment,
                              timeout=30, check=False)

    def successful_document(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return self.document.read_text(encoding='utf-8')

    def assert_prompts_section(self, content):
        prompts = self.home / 'datas/prompts'
        self.assertEqual(content.count('# Prompts\n'), 1)
        self.assertIn(f'# Prompts\n\n  * Dossier des prompts : {prompts}\n'
                      f'  * Index des prompts : {prompts / "INDEX.md"}\n', content)
        self.assertLess(content.index('# Python - Gestionnaire de paquets\n'),
                        content.index('# Prompts\n'))
        self.assertLess(content.index('# Prompts\n'),
                        content.index('# Tests navigateurs extérieurs en mode headless\n'))
        self.assertFalse(prompts.exists())

    def test_hostname_follows_os_with_exact_arguments_and_one_call(self):
        content = self.successful_document(self.run_generation())
        self.assertRegex(content, r"# Système d'exploitation\n\n  \* [^\n]+\n"
                                  r"  \* hvp1\.pixs\.fr\n\n\n# Matériel\n")
        self.assertEqual(self.hostname_log.read_text().splitlines(), ['-f'])
        self.assertIn('Version : 0.7\n', content)

    def test_hostname_is_refreshed_without_a_hardcoded_value(self):
        first = self.successful_document(self.run_generation())
        self.environment['TEST_HOSTNAME_OUTPUT'] = 'dev-build.example.test'
        second = self.successful_document(self.run_generation())
        self.assertIn('  * hvp1.pixs.fr\n', first)
        self.assertIn('  * dev-build.example.test\n', second)
        self.assertNotIn('hvp1.pixs.fr', second)
        self.assertEqual(self.hostname_log.read_text().splitlines(), ['-f', '-f'])

    def test_hostname_short_name_and_maximum_length_are_preserved(self):
        maximum = '.'.join(['a' * 63, 'b' * 63, 'c' * 63, 'd' * 61])
        self.assertEqual(len(maximum), 253)
        for output in ('localhost', maximum):
            with self.subTest(length=len(output)):
                self.environment['TEST_HOSTNAME_OUTPUT'] = output
                content = self.successful_document(self.run_generation())
                self.assertIn(f'  * {output}\n', content)

    def test_hostname_missing_or_failed_does_not_block_generation(self):
        hostname = self.host_bin / 'hostname'
        hostname.unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn('  * indisponible (commande hostname absente)\n', content)
        self.assertIn('# Matériel\n', content)
        self.assertFalse(self.hostname_log.exists())
        self.executable(hostname, "printf 'sortie-rejetee-test\\n'; "
                        "printf 'diagnostic-brut-test\\n' >&2; exit 7")
        result = self.run_generation()
        content = self.successful_document(result)
        self.assertIn("  * indisponible (nom d'hôte non vérifiable)\n", content)
        self.assertNotIn('sortie-rejetee-test', content + result.stderr)
        self.assertNotIn('diagnostic-brut-test', content + result.stderr)

    def test_hostname_invalid_output_is_not_published(self):
        for output in ('', 'first.example.test\nsecond.example.test',
                       'name with spaces', '<rejected>', 'hôte.example.test',
                       'a' * 254, '-invalid', 'host\x1b[0m'):
            with self.subTest(output=repr(output)):
                self.environment['TEST_HOSTNAME_OUTPUT'] = output
                content = self.successful_document(self.run_generation())
                self.assertIn("  * indisponible (nom d'hôte invalide)\n", content)
                section = content.split("# Système d'exploitation\n", 1)[1].split('# Matériel', 1)[0]
                self.assertEqual(len(re.findall(r'^  \* ', section, re.M)), 2)
                self.assertNotIn('first.example.test', section)
                self.assertNotIn('<rejected>', section)

    def test_hostname_timeout_uses_bounded_probe_and_continues(self):
        self.executable(self.host_bin / 'hostname', 'exec /bin/sleep 5')
        started = time.monotonic()
        content = self.successful_document(self.run_generation(source_replacements=((
            '/usr/bin/timeout 15s "${binary}" -f 2>/dev/null',
            '/usr/bin/timeout 0.05s "${binary}" -f 2>/dev/null'),)))
        self.assertLess(time.monotonic() - started, 3)
        self.assertIn("  * indisponible (nom d'hôte non vérifiable)\n", content)
        self.assertIn('# Matériel\n', content)

    def assert_test_container_sections(self, content, docker, lxc):
        docker_title = '# Conteneur Docker, pour tests nécessitant des droits root\n'
        lxc_title = '# Conteneur LXC, pour tests nécessitant des droits root accessible en SSH\n'
        retention = 'Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests.'
        self.assertEqual(content.count(docker_title), int(docker))
        self.assertEqual(content.count(lxc_title), int(lxc))
        self.assertNotIn('# Docker, pour tests nécessitant des droits root\n', content)
        self.assertEqual(content.count('/var/run/docker.sock'), int(docker))
        self.assertEqual(content.count('debian:stable-slim'), int(docker))
        self.assertEqual(content.count('  * Accès TPM OK\n'), int(lxc))
        self.assertEqual(content.count('  * ' + retention + '\n'), int(lxc))
        self.assertEqual(content.count('# Docker-Compose\n'), 1)
        self.assertEqual(content.count(CONTAINER_TEST_AUTHORIZATION), int(docker) + int(lxc))
        for title, enabled, count in ((docker_title, docker, 5), (lxc_title, lxc, 5)):
            if enabled:
                section = content.split(title, 1)[1].split('\n# ', 1)[0]
                bullets = [line for line in section.splitlines() if line.startswith('  * ')]
                self.assertEqual(len(bullets), count)
                self.assertEqual(bullets[3 if title == lxc_title else 4],
                                 '  * ' + CONTAINER_TEST_AUTHORIZATION)
                if title == lxc_title:
                    self.assertEqual(bullets[-1], '  * ' + retention)
        ordered = ['# Matériel\n']
        if docker:
            ordered.append(docker_title)
        if lxc:
            ordered.append(lxc_title)
            self.assertIn(lxc_title + "\n  * Variables d'accès disponible dans project.env pour l'accès SSH\n"
                          '  * Debian 13\n  * Accès TPM OK\n'
                          f'  * {CONTAINER_TEST_AUTHORIZATION}\n'
                          f'  * {retention}\n\n\n# Docker-Compose\n', content)
        ordered.append('# Docker-Compose\n')
        for before, after in zip(ordered, ordered[1:]):
            self.assertLess(content.index(before), content.index(after))
        self.assertIn('Version : 0.7\n', content)

    def test_container_flags_independent_and_document_refresh(self):
        extra = """
container_forbidden() { printf 'interdit' > "$TEST_DEVOPS_HOME/forbidden"; return 99; }
eval "$(declare -f projects_template_devops_host_binary | sed '1s/projects_template_devops_host_binary/original_host_binary/')"
projects_template_devops_host_binary() {
    if [[ "$1" == docker && "${ENV_DEVOPS_TESTS_DOCKER:-0}" != 1 ]]; then
        container_forbidden
        return 99
    fi
    original_host_binary "$@"
}
lxc() { container_forbidden; }
lxc-info() { container_forbidden; }
lxc-attach() { container_forbidden; }
lxc-start() { container_forbidden; }
ssh() { container_forbidden; }
"""
        for docker, lxc in (('0', '0'), ('1', '0'), ('0', '1'), ('1', '1'), ('0', '0')):
            with self.subTest(docker=docker, lxc=lxc):
                self.environment.update(ENV_DEVOPS_TESTS_DOCKER=docker, ENV_DEVOPS_TESTS_LXC=lxc)
                if self.probe_order_log.exists():
                    self.probe_order_log.unlink()
                content = self.successful_document(self.run_generation(extra))
                self.assert_test_container_sections(content, docker == '1', lxc == '1')
                self.assertEqual(self.probe_order_log.read_text().splitlines(),
                                 ['clock', 'docker'] if docker == '1' else ['clock'])
                self.assertFalse((self.home / 'forbidden').exists())
                repeated = self.successful_document(self.run_generation(extra))
                self.assertEqual(content, repeated)

    def test_container_flags_absent_empty_and_nonliteral_one_are_disabled(self):
        marker = self.fixture / 'flag-executed'
        for name, other in (('ENV_DEVOPS_TESTS_DOCKER', 'ENV_DEVOPS_TESTS_LXC'),
                            ('ENV_DEVOPS_TESTS_LXC', 'ENV_DEVOPS_TESTS_DOCKER')):
            self.environment[other] = '1'
            for value in (None, '', '0', '01', 'true', '1 ', f'$(touch "{marker}")'):
                with self.subTest(name=name, value=value):
                    if value is None:
                        self.environment.pop(name, None)
                    else:
                        self.environment[name] = value
                    content = self.successful_document(self.run_generation())
                    self.assert_test_container_sections(content,
                                                        name != 'ENV_DEVOPS_TESTS_DOCKER',
                                                        name != 'ENV_DEVOPS_TESTS_LXC')
                    if value and value != '0':
                        self.assertNotIn(f'\n  * {value}\n', content)
                    self.assertFalse(marker.exists())
            self.environment[name] = '0'

    def test_generation_structure_versions_and_executable_paths(self):
        content = self.successful_document(self.run_generation())
        self.assertEqual(re.findall(r'^# (.+)$', content, re.M), [
            'DEVOPS.md — Template', "Système d'exploitation", 'Matériel',
            'Conteneur Docker, pour tests nécessitant des droits root',
            'Docker-Compose', 'Git', 'Go', 'Node', 'NPM', 'OpenCode',
            'OpenSpec', 'OpenSSL', 'PostgreSQL Client', 'PostgreSQL Serveur',
            'Python', 'Python - Dépendances du projet - Source de vérité `pyproject.toml`',
            'Python - Gestionnaire de paquets', 'Prompts',
            'Tests navigateurs extérieurs en mode headless',
        ])
        self.assertEqual(re.findall(r'^## (.+)$', content, re.M), ['TPM', 'Chromium', 'Firefox'])
        for title, version, binary in (('Chromium', '134.0.6998.88', 'chromium'),
                                       ('Firefox', '140.0.4esr', 'firefox')):
            self.assertIn(f'## {title}\n\n  * {version}\n  * {self.host_bin / binary}\n'
                          '  * Mode headless : --headless\n', content)
        self.assertIn('La détection ne vérifie pas le fonctionnement du mode headless.', content)
        self.assertTrue(content.endswith('  * Mode headless : --headless\n'))
        self.assertIn('Version : 0.7', content)
        self.assert_prompts_section(content)
        for title, version, path in (
            ('Conteneur Docker, pour tests nécessitant des droits root', '29.1.2', self.host_bin / 'docker'),
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
        self.assertIn('# Conteneur Docker, pour tests nécessitant des droits root\n\n'
                      f'  * 29.1.2\n  * {self.host_bin / "docker"}\n'
                      '  * /var/run/docker.sock\n  * debian:stable-slim\n'
                      f'  * {CONTAINER_TEST_AUTHORIZATION}\n\n\n'
                      '# Docker-Compose\n', content)
        self.assert_test_container_sections(content, True, False)
        self.assertEqual(content.count('/var/run/docker.sock'), 1)
        self.assertEqual(content.count('debian:stable-slim'), 1)
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

    def configure_tpm(self, name='tpmrm0', major='2'):
        device = self.tpm_devices / name
        device.symlink_to('/dev/null')
        index = name.removeprefix('tpm').removeprefix('rm')
        sysfs = self.tpm_sysfs / f'tpm{index}'
        sysfs.mkdir(exist_ok=True)
        (sysfs / 'tpm_version_major').write_text(major + '\n')
        Path(self.environment['TEST_TPM_PROPERTIES']).write_text(
            'TPM2_PT_FAMILY_INDICATOR:\n  raw: 0x322E3000\n  value: "2.0"\n'
            'TPM2_PT_MANUFACTURER:\n  raw: 0x49465800\n  value: "IFX"\n'
            'TPM2_PT_REVISION:\n  raw: 0xA4\n  value: 1.64\n'
            'TPM2_PT_FIRMWARE_VERSION_1:\n  raw: 0x70000\n')
        Path(self.environment['TEST_TPM_PCRS']).write_text(
            'selected-pcrs:\n  - sha1: [ 0, 7, 23 ]\n  - sha256: [ 0, 7, 23 ]\n')
        self.executable(self.host_bin / 'tpm2_getcap', r'''
[ "$#" -eq 3 ] && [ "$1" = -T ] || exit 9
case "$2" in "device:$TEST_TPM_DEVICES/"*) ;; *) exit 9 ;; esac
printf '%s|%s\n' "$2" "$3" >> "$TEST_TPM_LOG"
if [ "${TEST_TPM_FAILURE:-}" = "$3" ]; then
    printf 'sortie-non-publiable\n'
    printf 'erreur-non-publiable\n' >&2
    exit 1
fi
if [ "${TEST_TPM_TIMEOUT:-}" = "$3" ]; then exec sleep 30; fi
case "$3" in
    properties-fixed) cat "$TEST_TPM_PROPERTIES" ;;
    pcrs) cat "$TEST_TPM_PCRS" ;;
    *) exit 9 ;;
esac
''')
        return device

    def test_tpm_properties_and_allocated_pcr_banks_use_explicit_local_transport(self):
        device = self.configure_tpm()
        self.environment['TPM2TOOLS_TCTI'] = 'mssim:host=invalid.example.test'
        content = self.successful_document(self.run_generation())
        self.assertIn('# Matériel\n\n## TPM\n\n'
                      f'  * Chemin : {device}\n'
                      '  * Version : 2.0\n  * Fabricant : IFX\n'
                      '  * Identifiant fournisseur : 0x49465800\n'
                      '  * Révision de spécification : 1.64\n'
                      '  * Registres PCR : sha1: [0, 7, 23] ; sha256: [0, 7, 23]\n', content)
        self.assertEqual(self.tpm_log.read_text().splitlines(),
                         [f'device:{device}|properties-fixed', f'device:{device}|pcrs'])
        self.assertNotIn('0x70000', content)
        self.assertEqual(content.count('# Matériel\n'), 1)

    def test_tpm_resource_manager_priority_and_matching_sysfs_index(self):
        raw = self.configure_tpm('tpm0', '1')
        manager = self.configure_tpm('tpmrm3', '2')
        (self.tpm_devices / 'tpmrm0-extra').symlink_to('/dev/null')
        (self.tpm_devices / 'tpmrm0').write_text('fichier ordinaire, pas un TPM')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {manager}\n  * Version : 2.0\n', content)
        self.assertNotIn(f'Chemin : {raw}', content)
        (self.tpm_devices / 'tpmrm0').unlink()
        preferred = self.configure_tpm('tpmrm0', '2')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {preferred}\n', content)

    def test_tpm_raw_device_fallback_and_version_from_capability_without_sysfs(self):
        device = self.configure_tpm('tpm4')
        shutil.rmtree(self.tpm_sysfs / 'tpm4')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {device}\n  * Version : 2.0\n', content)

    def test_tpm_absence_reports_all_fields_without_probing(self):
        content = self.successful_document(self.run_generation())
        section = content.split('## TPM\n', 1)[1].split('\n# Conteneur Docker', 1)[0]
        self.assertEqual(section.count('aucun périphérique TPM visible'), 6)
        self.assertFalse(self.tpm_log.exists())

    def test_tpm_missing_tool_preserves_path_and_sysfs_version(self):
        device = self.configure_tpm()
        (self.host_bin / 'tpm2_getcap').unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {device}\n  * Version : 2.0\n', content)
        self.assertEqual(content.count('tpm2_getcap absent'), 4)
        self.assertFalse(self.tpm_log.exists())

    def test_tpm_access_denied_preserves_path_and_does_not_probe(self):
        device = self.configure_tpm()
        content = self.successful_document(self.run_generation(source_replacements=(
            ('[[ ! -r "${device}" || ! -w "${device}" ]]', '[[ 1 == 1 ]]'),)))
        self.assertIn(f'Chemin : {device}\n  * Version : 2.0\n', content)
        self.assertEqual(content.count('accès au périphérique refusé'), 4)
        self.assertFalse(self.tpm_log.exists())

    def test_tpm_12_is_explicit_without_tpm2_queries(self):
        device = self.configure_tpm('tpm0', '1')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {device}\n  * Version : 1.2\n', content)
        self.assertEqual(content.count('sonde réservée au TPM 2'), 4)
        self.assertFalse(self.tpm_log.exists())

    def test_tpm_partial_and_duplicate_properties_preserve_other_fields(self):
        self.configure_tpm()
        Path(self.environment['TEST_TPM_PROPERTIES']).write_text(
            'TPM2_PT_MANUFACTURER:\n  raw: 0x49465800\n  value: "IFX"\n'
            'TPM2_PT_REVISION:\n  value: 1.64\n'
            'TPM2_PT_REVISION:\n  value: 1.65\n')
        content = self.successful_document(self.run_generation())
        self.assertIn('Fabricant : IFX\n', content)
        self.assertIn('Révision de spécification : non vérifiable\n', content)
        self.assertIn('Registres PCR : sha1:', content)
        Path(self.environment['TEST_TPM_PROPERTIES']).write_text(
            'TPM2_PT_MANUFACTURER:\n  value: "IFX"\n  value: "AMD"\n')
        content = self.successful_document(self.run_generation())
        self.assertIn('Fabricant : non vérifiable\n', content)
        self.assertIn('Identifiant fournisseur : non vérifiable\n', content)

    def test_tpm_malformed_properties_are_neither_published_nor_executed(self):
        self.configure_tpm(major='non-reconnu')
        marker = self.fixture / 'tpm-marker'
        Path(self.environment['TEST_TPM_PROPERTIES']).write_text(
            'TPM2_PT_FAMILY_INDICATOR:\n  value: "mauvaise-famille"\n'
            f'TPM2_PT_MANUFACTURER:\n  raw: $(touch {marker})\n  value: "[injection](https://invalid.test)"\n'
            'TPM2_PT_REVISION:\n  value: version-invalide\n')
        content = self.successful_document(self.run_generation())
        self.assertIn('Version : non vérifiable\n', content)
        self.assertIn('Fabricant : non vérifiable\n', content)
        self.assertIn('Révision de spécification : non vérifiable\n', content)
        self.assertNotIn('injection', content)
        self.assertNotIn('touch', content)
        self.assertFalse(marker.exists())

    def test_tpm_failed_capability_keeps_other_capability_and_hides_raw_errors(self):
        self.configure_tpm()
        for capability in ('properties-fixed', 'pcrs'):
            with self.subTest(capability=capability):
                self.environment['TEST_TPM_FAILURE'] = capability
                content = self.successful_document(self.run_generation())
                field = 'Fabricant' if capability == 'properties-fixed' else 'Registres PCR'
                self.assertIn(f'{field} : non vérifiable (sonde échouée)', content)
                self.assertIn('Registres PCR : sha1:' if capability == 'properties-fixed'
                              else 'Fabricant : IFX', content)
                self.assertNotIn('non-publiable', content)

    def test_tpm_timeout_is_bounded_and_generation_continues(self):
        self.configure_tpm()
        self.environment['TEST_TPM_TIMEOUT'] = 'properties-fixed'
        started = time.monotonic()
        content = self.successful_document(self.run_generation())
        self.assertLess(time.monotonic() - started, 12)
        self.assertIn('Fabricant : non vérifiable (sonde expirée)', content)
        self.assertIn('Registres PCR : sha1:', content)

    def test_tpm_malformed_pcr_banks_remain_unknown(self):
        self.configure_tpm()
        for output in ('', 'selected-pcrs:\n', 'selected-pcrs:\n  - sha256: [ 0, 999 ]\n',
                       'selected-pcrs:\n  - sha256: [ 0, 0 ]\n',
                       'selected-pcrs:\n  - sha256: [ 0 ]\n  - sha256: [ 7 ]\n',
                       'selected-pcrs:\n  - sha256: [ 0,,7 ]\n',
                       'selected-pcrs:\n  - sha256: [ $(false) ]\n'):
            with self.subTest(output=output):
                Path(self.environment['TEST_TPM_PCRS']).write_text(output)
                content = self.successful_document(self.run_generation())
                self.assertIn('Registres PCR : non vérifiable\n', content)
                self.assertIn('Fabricant : IFX\n', content)

    def test_tpm_large_responses_are_not_published(self):
        self.configure_tpm()
        for key in ('TEST_TPM_PROPERTIES', 'TEST_TPM_PCRS'):
            Path(self.environment[key]).write_text('sortie-trop-grande' * 5000)
        content = self.successful_document(self.run_generation())
        self.assertIn('Fabricant : non vérifiable\n', content)
        self.assertIn('Registres PCR : non vérifiable\n', content)
        self.assertNotIn('sortie-trop-grande', content)

    def test_tpm_paths_with_spaces_and_second_probe_timeout(self):
        self.tpm_devices = self.fixture / 'périphériques avec espaces'
        self.tpm_devices.mkdir()
        self.environment['TEST_TPM_DEVICES'] = str(self.tpm_devices)
        device = self.configure_tpm()
        self.environment['TEST_TPM_TIMEOUT'] = 'pcrs'
        content = self.successful_document(self.run_generation())
        self.assertIn(f'Chemin : {device}\n', content)
        self.assertIn('Fabricant : IFX\n', content)
        self.assertIn('Registres PCR : non vérifiable (sonde expirée)', content)
        self.assertEqual(self.tpm_log.read_text().splitlines(),
                         [f'device:{device}|properties-fixed', f'device:{device}|pcrs'])

    def test_report_provenance_utc_and_capture_before_probes(self):
        self.environment.update(TZ='Pacific/Kiritimati', SYSTEM_DEBIAN_ENVIRONNEMENT='DOCKER')
        content = self.successful_document(self.run_generation())
        self.assertIn('# DEVOPS.md — Template\n\nVersion : 0.7\n', content)
        expected = (
            'Généré automatiquement par Debian Installeur Unifié (DIU).',
            'Début du relevé (UTC) : 2026-10-09T06:30:00Z',
            "Environnement d'exécution DIU : DOCKER",
            "Les sondes système concernent le contexte d'exécution DIU.",
            'Les outils DevOps sont interrogés avec les binaires indiqués dans leurs rubriques.',
            'Les dépendances Python sont recherchées en priorité dans les venv du projet, puis dans le Python DevOps en repli explicite.',
            'Dans l’inventaire Python, la flèche indique le Python sondé ; Installation indique le chemin observé dans les métadonnées.',
            'Les dépendances Python attendues proviennent de [project].dependencies dans pyproject.toml.',
            'Un inventaire multi-environnements ne valide pas un environnement Python unique.',
            'Cet inventaire ne constitue pas une qualification fonctionnelle ni une preuve de réussite des tests du projet.',
        )
        for line in expected:
            self.assertEqual(content.count(line), 1)
            self.assertLess(content.index(line), content.index("# Système d'exploitation"))
        self.assertEqual(self.clock_log.read_text().splitlines(), ['-u +%Y-%m-%dT%H:%M:%SZ'])
        self.assertEqual(self.probe_order_log.read_text().splitlines(), ['clock', 'docker'])

    def test_timestamp_refresh_changes_only_report_start_at_identical_observations(self):
        first = self.successful_document(self.run_generation())
        self.environment['TEST_CLOCK_OUTPUT'] = '2026-10-09T06:31:00Z'
        second = self.successful_document(self.run_generation())
        self.assertNotEqual(first, second)
        self.assertEqual(first.replace('2026-10-09T06:30:00Z', '<report-start>'),
                         second.replace('2026-10-09T06:31:00Z', '<report-start>'))
        self.assertEqual(len(self.clock_log.read_text().splitlines()), 2)

    def test_report_context_whitelist_and_unknown_values_are_not_echoed_or_executed(self):
        marker = self.fixture / 'context-executed'
        for value in ('DOCKER', 'LXC', 'PHYSICAL', 'PROXMOX', 'VM', 'UNSET',
                      None, '', 'No', f'$(touch "{marker}")', 'context-marker\n# injected'):
            with self.subTest(value=value):
                if value is None:
                    self.environment.pop('SYSTEM_DEBIAN_ENVIRONNEMENT', None)
                else:
                    self.environment['SYSTEM_DEBIAN_ENVIRONNEMENT'] = value
                result = self.run_generation()
                content = self.successful_document(result)
                expected = value if value in ('DOCKER', 'LXC', 'PHYSICAL', 'PROXMOX', 'VM', 'UNSET') else 'UNSET'
                self.assertIn(f"Environnement d'exécution DIU : {expected}\n", content)
                self.assertNotIn('context-marker', content + result.stdout + result.stderr)
                self.assertNotIn(str(marker), content + result.stdout + result.stderr)
                self.assertFalse(marker.exists())

    def test_timestamp_absent_failed_or_malformed_preserves_document_without_probes(self):
        date_binary = self.host_bin / 'date'
        cases = (
            ('absent', None), ('failed', None), ('malformed', 'clock-error-marker'),
            ('malformed', ''), ('malformed', '2026-13-09T06:30:00Z'),
            ('malformed', '2026-02-29T06:30:00Z'), ('malformed', '2026-04-31T06:30:00Z'),
            ('malformed', '2026-10-09T24:00:00Z'), ('malformed', '2026-10-09T06:30:60Z'),
            ('malformed', '2026-10-09T06:30:00+02:00'), ('malformed', '0000-10-09T06:30:00Z'),
        )
        for kind, value in cases:
            with self.subTest(kind=kind, value=value):
                self.document.write_bytes(b'existing report\n')
                self.document.chmod(0o640)
                before = self.document.stat()
                if date_binary.exists():
                    date_binary.unlink()
                if kind == 'failed':
                    self.executable(date_binary, "printf 'clock-error-marker\\n' >&2\nexit 7")
                elif kind == 'malformed':
                    self.environment['TEST_CLOCK_OUTPUT'] = value
                    self.executable(date_binary, 'printf "%s\\n" "$TEST_CLOCK_OUTPUT"')
                result = self.run_generation()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Horodatage UTC du relevé indisponible.', result.stderr)
                self.assertNotIn('clock-error-marker', result.stdout + result.stderr)
                self.assertEqual(self.document.read_bytes(), b'existing report\n')
                after = self.document.stat()
                self.assertEqual((before.st_mode, before.st_uid, before.st_gid),
                                 (after.st_mode, after.st_uid, after.st_gid))
                self.assertFalse(self.query_log.exists())
                self.assertFalse(self.probe_order_log.exists())
                self.assertEqual(list(self.template.glob('.DEVOPS.md.*')), [])

    def test_timestamp_valid_leap_day_is_accepted(self):
        self.environment['TEST_CLOCK_OUTPUT'] = '2024-02-29T23:59:59Z'
        content = self.successful_document(self.run_generation())
        self.assertIn('Début du relevé (UTC) : 2024-02-29T23:59:59Z\n', content)

    def test_timestamp_timeout_preserves_document_without_probes(self):
        self.document.write_bytes(b'existing report\n')
        self.document.chmod(0o640)
        before = self.document.stat()
        self.executable(self.host_bin / 'date', '/usr/bin/sleep 30')
        started = time.monotonic()
        result = self.run_generation()
        elapsed = time.monotonic() - started
        self.assertNotEqual(result.returncode, 0)
        self.assertLess(elapsed, 20)
        self.assertIn('Horodatage UTC du relevé indisponible.', result.stderr)
        self.assertEqual(self.document.read_bytes(), b'existing report\n')
        after = self.document.stat()
        self.assertEqual((before.st_mode, before.st_uid, before.st_gid),
                         (after.st_mode, after.st_uid, after.st_gid))
        self.assertFalse(self.query_log.exists())
        self.assertFalse(self.probe_order_log.exists())
        self.assertEqual(list(self.template.glob('.DEVOPS.md.*')), [])

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

    def test_headless_browser_name_variants_are_detected(self):
        for canonical, variant, output in (
                ('chromium', 'chromium-browser', 'Chromium 133.0.6943.16'),
                ('firefox', 'firefox-esr', 'Mozilla Firefox 128.7.0esr')):
            (self.host_bin / canonical).unlink()
            self.executable(self.host_bin / variant, f"printf '{output}\\n'")
        content = self.successful_document(self.run_generation())
        self.assertIn(f'## Chromium\n\n  * 133.0.6943.16\n  * {self.host_bin / "chromium-browser"}', content)
        self.assertIn(f'## Firefox\n\n  * 128.7.0esr\n  * {self.host_bin / "firefox-esr"}', content)

    def test_headless_browser_canonical_names_take_priority(self):
        for variant in ('chromium-browser', 'firefox-esr'):
            self.executable(self.host_bin / variant, "printf '99.99.99\\n'")
        content = self.successful_document(self.run_generation())
        self.assertIn(f'## Chromium\n\n  * 134.0.6998.88\n  * {self.host_bin / "chromium"}', content)
        self.assertIn(f'## Firefox\n\n  * 140.0.4esr\n  * {self.host_bin / "firefox"}', content)
        self.assertNotIn('99.99.99', content)
        self.assertNotIn(str(self.host_bin / 'chromium-browser'), content)
        self.assertNotIn(str(self.host_bin / 'firefox-esr'), content)

    def test_missing_headless_browsers_are_explicit_and_ignore_user_path(self):
        for binary in ('chromium', 'firefox'):
            (self.host_bin / binary).unlink()
            self.executable(self.home / 'bin' / binary, "printf '99.99.99\\n'")
        self.environment['PATH'] = str(self.home / 'bin') + ':' + os.environ['PATH']
        content = self.successful_document(self.run_generation())
        for title in ('Chromium', 'Firefox'):
            self.assertIn(f'## {title}\n\n  * indisponible (binaire absent)\n'
                          '  * binaire introuvable\n  * Mode headless : --headless\n', content)
        self.assertNotIn('99.99.99', content)

    def test_failed_browser_probes_keep_detected_paths_without_fallback_or_raw_errors(self):
        self.executable(self.host_bin / 'chromium', "printf 'browser-error-marker\\n' >&2\nexit 7")
        self.executable(self.host_bin / 'firefox', "printf 'unrecognized-browser-version\\n'")
        for variant in ('chromium-browser', 'firefox-esr'):
            self.executable(self.host_bin / variant, "printf '99.99.99\\n'")
        result = self.run_generation()
        content = self.successful_document(result)
        self.assertIn(f'## Chromium\n\n  * indisponible (sonde échouée)\n  * {self.host_bin / "chromium"}', content)
        self.assertIn(f'## Firefox\n\n  * indisponible (version non reconnue)\n  * {self.host_bin / "firefox"}', content)
        self.assertNotIn('99.99.99', content)
        self.assertNotIn('browser-error-marker', content + result.stdout + result.stderr)
        self.assertNotIn('unrecognized-browser-version', content)

    def test_headless_browser_paths_with_spaces_are_preserved(self):
        host_bin = self.fixture / 'host bin with spaces'
        self.environment['TEST_HOST_BIN'] = str(host_bin)
        self.executable(host_bin / 'chromium',
                        '[ "$#" -eq 1 ] && [ "$1" = --version ] || exit 9\n'
                        "printf 'Chromium 134.0.6998.88\\n'")
        self.executable(host_bin / 'firefox',
                        '[ "$#" -eq 1 ] && [ "$1" = --version ] || exit 9\n'
                        "printf 'Mozilla Firefox 140.0.4esr\\n'")
        shutil.copy2(self.host_bin / 'date', host_bin / 'date')
        content = self.successful_document(self.run_generation())
        self.assertIn(f'## Chromium\n\n  * 134.0.6998.88\n  * {host_bin / "chromium"}', content)
        self.assertIn(f'## Firefox\n\n  * 140.0.4esr\n  * {host_bin / "firefox"}', content)

    def test_headless_browser_update_refreshes_versions_without_duplicates(self):
        previous = self.successful_document(self.run_generation())
        self.executable(self.host_bin / 'chromium', "printf 'Chromium 135.0.7049.41\\n'")
        (self.host_bin / 'firefox').unlink()
        content = self.successful_document(self.run_generation())
        self.assertNotEqual(content, previous)
        self.assertNotIn('134.0.6998.88', content)
        self.assertNotIn('140.0.4esr', content)
        self.assertIn(f'## Chromium\n\n  * 135.0.7049.41\n  * {self.host_bin / "chromium"}', content)
        self.assertIn('## Firefox\n\n  * indisponible (binaire absent)', content)
        self.assertEqual(content.count('# Tests navigateurs extérieurs en mode headless\n'), 1)
        self.assertEqual(content.count('## Chromium\n'), 1)
        self.assertEqual(content.count('## Firefox\n'), 1)
        self.assertEqual(content, self.successful_document(self.run_generation()))

    def test_missing_directory_returns_without_probing_or_creating_it(self):
        self.template.rename(self.home / 'existing-fixture')
        result = self.run_generation('projects_template_devops_render() { return 99; }')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dossier du projet absent', result.stdout)
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

    def test_prepare_all_devops_tools_before_inventory_and_versions(self):
        tools = ('go/current/bin/go', 'node/current/bin/node', 'node/current/bin/npm',
                 '.opencode/bin/opencode', '.local/npm/bin/openspec',
                 'python/current/bin/python3', 'python/current/bin/pip3')
        owners = {}
        for relative in tools:
            path = self.home / relative
            path.chmod(0o640)
            owners[relative] = (path.stat().st_uid, path.stat().st_gid)
        # Le collecteur JavaScript doit déjà disposer de son Python DevOps.
        extra = r'''
projects_template_devops_javascript() {
    for relative in go/current/bin/go node/current/bin/node node/current/bin/npm \
        .opencode/bin/opencode .local/npm/bin/openspec \
        python/current/bin/python3 python/current/bin/pip3; do
        [[ -x "${TEST_DEVOPS_HOME}/${relative}" ]] || return 1
    done
    printf '## Dépendances JavaScript du projet\n\n  * préparation vérifiée\n\034'
}
'''
        content = self.successful_document(self.run_generation(extra))
        self.assertIn('préparation vérifiée', content)
        self.assertIn('# OpenCode\n\n  * 1.2.8', content)
        self.assertIn('# Node\n\n  * 24.3.1', content)
        self.assertIn('# NPM\n\n  * 11.5.2', content)
        self.assertIn('# OpenSpec\n\n  * 1.3.9', content)
        self.assertIn('# Go\n\n  * 1.25.3', content)
        self.assertIn('# Python\n\n  * 3.13.9', content)
        self.assertIn('# Python - Gestionnaire de paquets\n\n  * 25.3.7', content)
        for relative in tools:
            with self.subTest(tool=relative):
                observed = (self.home / relative).stat()
                self.assertEqual(observed.st_mode & 0o777, 0o751)
                self.assertEqual((observed.st_uid, observed.st_gid), owners[relative])

    def test_preparation_does_not_touch_host_or_unlisted_files(self):
        unrelated = self.home / 'other-tool'
        self.executable(unrelated, "printf 'other\\n'")
        unrelated.chmod(0o640)
        paths = [unrelated, *self.host_bin.iterdir()]
        before = {path: (path.read_bytes(), path.stat()) for path in paths}
        self.successful_document(self.run_generation())
        for path, (data, observed) in before.items():
            with self.subTest(path=path.name):
                self.assertEqual(path.read_bytes(), data)
                self.assertEqual(path.stat().st_mode, observed.st_mode)
                self.assertEqual(path.stat().st_ctime_ns, observed.st_ctime_ns)

    def test_preparation_is_idempotent_without_reapplying_chmod(self):
        tool = self.home / '.opencode/bin/opencode'
        tool.chmod(0o664)
        first = self.successful_document(self.run_generation())
        prepared = tool.stat()
        second = self.successful_document(self.run_generation())
        self.assertEqual(first, second)
        self.assertEqual(tool.stat().st_ctime_ns, prepared.st_ctime_ns)
        self.assertEqual(tool.stat().st_mode & 0o777, 0o775)

    def test_internal_binary_and_current_directory_symlinks_are_preserved(self):
        tool = self.home / '.opencode/bin/opencode'
        target = self.home / '.opencode/releases/opencode'
        target.parent.mkdir()
        tool.rename(target)
        target.chmod(0o644)
        tool.symlink_to('../releases/opencode')
        current = self.home / 'node/current'
        installed = self.home / 'node/version-fixture'
        current.rename(installed)
        current.symlink_to('version-fixture')
        (installed / 'bin/node').chmod(0o644)
        content = self.successful_document(self.run_generation())
        self.assertIn('# OpenCode\n\n  * 1.2.8', content)
        self.assertIn('# Node\n\n  * 24.3.1', content)
        self.assertTrue(tool.is_symlink())
        self.assertTrue(current.is_symlink())
        self.assertEqual(target.stat().st_mode & 0o777, 0o755)
        self.assertEqual((installed / 'bin/node').stat().st_mode & 0o777, 0o755)

    def test_external_symlink_fails_without_changing_target_or_document(self):
        target = self.host_bin / 'git'
        target.chmod(0o640)
        tool = self.home / '.opencode/bin/opencode'
        tool.unlink()
        tool.symlink_to(target)
        self.document.write_text('document précédent\n', encoding='utf-8')
        before = target.stat()
        result = self.run_generation()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('hors du domicile : .opencode/bin/opencode', result.stderr)
        self.assertEqual(target.stat().st_mode, before.st_mode)
        self.assertEqual(target.stat().st_ctime_ns, before.st_ctime_ns)
        self.assertEqual(self.document.read_text(), 'document précédent\n')
        self.assertFalse(self.query_log.exists())
        self.assertFalse(self.tpm_log.exists())

    def test_nonregular_tool_fails_without_changing_its_mode(self):
        tool = self.home / '.opencode/bin/opencode'
        tool.unlink()
        tool.mkdir(mode=0o700)
        before = tool.stat().st_mode
        result = self.run_generation()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('fichier ordinaire : .opencode/bin/opencode', result.stderr)
        self.assertEqual(tool.stat().st_mode, before)
        self.assertFalse(self.document.exists())

    def test_missing_and_dangling_internal_tools_are_not_created(self):
        tool = self.home / '.opencode/bin/opencode'
        tool.unlink()
        tool.symlink_to('missing-opencode')
        content = self.successful_document(self.run_generation())
        self.assertIn('# OpenCode\n\n  * indisponible (binaire absent)', content)
        self.assertTrue(tool.is_symlink())
        self.assertFalse(tool.exists())

    def test_chmod_failure_preserves_document_and_previously_prepared_modes(self):
        go = self.home / 'go/current/bin/go'
        opencode = self.home / '.opencode/bin/opencode'
        go.chmod(0o640)
        opencode.chmod(0o640)
        self.document.write_text('document précédent\n', encoding='utf-8')
        result = self.run_generation(r'''
chmod() {
    if [[ "$*" == *'/.opencode/bin/opencode' ]]; then
        return 1
    fi
    command chmod "$@"
}
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de rendre le binaire DevOps exécutable', result.stderr)
        self.assertEqual(self.document.read_text(), 'document précédent\n')
        self.assertEqual(go.stat().st_mode & 0o777, 0o751)
        self.assertEqual(opencode.stat().st_mode & 0o777, 0o640)
        self.assertFalse(self.query_log.exists())
        self.assertFalse(self.tpm_log.exists())

    def test_resolution_and_mode_failures_stop_before_inventory(self):
        for extra in ('readlink() { return 1; }',
                      'stat() { return 1; }',
                      "stat() { printf 'invalide\\n'; }"):
            with self.subTest(extra=extra):
                self.document.write_text('document précédent\n', encoding='utf-8')
                result = self.run_generation(extra)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.document.read_text(), 'document précédent\n')
                self.assertFalse(self.query_log.exists())
                self.assertFalse(self.tpm_log.exists())

    def test_direct_version_distinguishes_nonexecutable_from_missing(self):
        tool = self.home / '.opencode/bin/opencode'
        tool.chmod(0o640)
        before = tool.stat()
        result = self.run_generation(r'''
projects_template_devops_version user "$TEST_DEVOPS_HOME" \
    "$TEST_DEVOPS_HOME/.opencode/bin/opencode" --version
projects_template_devops_version user "$TEST_DEVOPS_HOME" \
    "$TEST_DEVOPS_HOME/missing" --version
exit
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [
            'indisponible (binaire non exécutable)', 'indisponible (binaire absent)'])
        self.assertEqual(tool.stat().st_mode, before.st_mode)
        self.assertEqual(tool.stat().st_ctime_ns, before.st_ctime_ns)

    def test_failed_probe_and_venv_are_explicit(self):
        self.executable(self.home / '.opencode/bin/opencode', 'exit 7')
        self.executable(self.host_bin / 'docker', 'exit 7')
        self.environment['TEST_VENV_STATUS'] = '1'
        content = self.successful_document(self.run_generation())
        self.assertIn('# OpenCode\n\n  * indisponible (sonde échouée)', content)
        self.assertIn('venv: indisponible', content)
        self.assertIn('# Conteneur Docker, pour tests nécessitant des droits root\n\n'
                      f'  * indisponible (sonde échouée)\n  * {self.host_bin / "docker"}\n'
                      '  * /var/run/docker.sock\n  * debian:stable-slim\n', content)
        self.assert_test_container_sections(content, True, False)
        (self.host_bin / 'docker').unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn('# Conteneur Docker, pour tests nécessitant des droits root\n\n'
                      '  * indisponible (binaire absent)\n  * binaire introuvable\n'
                      '  * /var/run/docker.sock\n  * debian:stable-slim\n', content)
        self.assert_test_container_sections(content, True, False)

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

    @staticmethod
    def add_distribution(directory, name, version, folder=None):
        directory.mkdir(parents=True, exist_ok=True)
        normalized = re.sub(r"[-_.]+", "_", name)
        distribution = directory / (folder or f"{normalized}-{version}.dist-info")
        distribution.mkdir()
        (distribution / "METADATA").write_text(
            f"Metadata-Version: 2.1\nName: {name}\nVersion: {version}\n", encoding="utf-8")
        return distribution

    def project_venv(self, relative, packages):
        environment = self.template / relative
        result = subprocess.run(
            [sys.executable, "-I", "-B", "-m", "venv", "--without-pip", str(environment)],
            text=True, capture_output=True, timeout=15, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        interpreter = environment / "bin/python3"
        paths = subprocess.run(
            [str(interpreter), "-I", "-B", "-S", "-c",
             "import json,site,sys; print(json.dumps(site.getsitepackages([sys.argv[1]])))",
             str(environment)], text=True, capture_output=True, timeout=5, check=False)
        self.assertEqual(paths.returncode, 0, paths.stderr)
        site_packages = next(Path(p) for p in json.loads(paths.stdout) if Path(p).is_dir())
        for name, version in packages.items():
            self.add_distribution(site_packages, name, version)
        return environment, interpreter, site_packages

    def dependency_manifest(self, dependencies):
        (self.template / "pyproject.toml").write_text(
            "[project]\ndependencies = " + json.dumps(dependencies) + "\n", encoding="utf-8")

    def test_project_venv_matches_pixs_dependencies_and_effective_paths(self):
        packages = {"Django": "6.1.1", "psycopg": "3.3.6",
                    "asgiref": "3.12.1", "sqlparse": "0.6.0"}
        self.dependency_manifest(["Django==6.1.1", "psycopg[binary]==3.3.6",
                                  "asgiref==3.12.1", "sqlparse==0.6.0"])
        environment, interpreter, site_packages = self.project_venv(".venv", packages)
        for name in packages:
            self.add_distribution(self.metadata, name, "0.1")
        content = self.successful_document(self.run_generation())
        self.assertTrue(interpreter.is_symlink())
        for name, version in packages.items():
            constraint = "[binary]==3.3.6" if name == "psycopg" else f"=={version}"
            self.assertIn(f"{name} {constraint} : {version} --> {interpreter}", content)
        self.assertEqual(content.count(f"    * Environnement : {environment}\n"), 4)
        self.assertEqual(content.count(f"    * Installation : {site_packages.resolve()}\n"), 4)
        self.assertNotIn("Python DevOps (repli)", content)
        self.assertNotIn("non installé", content)

    def test_project_venv_priority_is_deterministic_and_nested_supported(self):
        self.dependency_manifest(["priority-fixture>=1"])
        paths = ("z-other", "backend/runtime", ".venv-backend-foundation",
                 "env", "venv", ".venv")
        fixtures = {name: self.project_venv(name, {"priority-fixture": str(index + 1) + ".0"})
                    for index, name in enumerate(paths)}
        for name in (".venv", "venv", "env", ".venv-backend-foundation",
                     "backend/runtime", "z-other"):
            with self.subTest(environment=name):
                environment, interpreter, site_packages = fixtures[name]
                content = self.successful_document(self.run_generation())
                self.assertIn(f"--> {interpreter}\n", content)
                self.assertIn(f"    * Environnement : {environment}\n", content)
                for distribution in site_packages.glob("*.dist-info"):
                    shutil.rmtree(distribution)

    def test_dependency_provenance_can_mix_venvs_and_explicit_global_fallback(self):
        self.dependency_manifest(["local-alpha", "local-beta", "global-gamma"])
        first, python_first, site_first = self.project_venv(".venv", {"local-alpha": "1.1"})
        second, python_second, site_second = self.project_venv("venv", {"local-beta": "2.2"})
        self.add_distribution(self.metadata, "global-gamma", "3.3")
        content = self.successful_document(self.run_generation())
        for name, version, interpreter, environment, location in (
                ("local-alpha", "1.1", python_first, first, site_first),
                ("local-beta", "2.2", python_second, second, site_second),
                ("global-gamma", "3.3", self.home / "python/current/bin/python3",
                 "Python DevOps (repli)", self.metadata)):
            self.assertIn(f"  * {name} : {version} --> {interpreter}\n"
                          f"    * Environnement : {environment}\n"
                          f"    * Installation : {location.resolve() if isinstance(location, Path) else location}\n",
                          content)
        self.assertIn("Un inventaire multi-environnements ne valide pas un environnement Python unique.", content)

    def test_project_venv_works_without_devops_python_or_system_package_fallback(self):
        self.dependency_manifest(["local-fixture", "unavailable-fallback"])
        environment, interpreter, site_packages = self.project_venv(".venv", {"local-fixture": "1.2"})
        self.add_distribution(self.metadata, "unavailable-fallback", "9.9")
        (self.home / "python/current/bin/python3").unlink()
        content = self.successful_document(self.run_generation())
        self.assertIn(f"local-fixture : 1.2 --> {interpreter}", content)
        self.assertIn(f"    * Environnement : {environment}\n", content)
        self.assertIn(f"    * Installation : {site_packages.resolve()}\n", content)
        self.assertIn("unavailable-fallback : non vérifiable (Python DevOps absent)", content)
        self.assertNotIn("unavailable-fallback : 9.9", content)

    def test_project_venv_probe_does_not_import_packages_or_pth(self):
        self.dependency_manifest(["side-effect-fixture"])
        _environment, interpreter, site_packages = self.project_venv(
            ".venv", {"side-effect-fixture": "1.0"})
        pth_marker = self.fixture / "pth-executed"
        import_marker = self.fixture / "package-imported"
        (site_packages / "side_effect_fixture.py").write_text(
            f"from pathlib import Path\nPath({str(import_marker)!r}).touch()\n", encoding="utf-8")
        (site_packages / "side_effect_fixture.pth").write_text(
            f"import pathlib; pathlib.Path({str(pth_marker)!r}).touch()\n", encoding="utf-8")
        content = self.successful_document(self.run_generation())
        self.assertIn(f"side-effect-fixture : 1.0 --> {interpreter}", content)
        self.assertFalse(pth_marker.exists())
        self.assertFalse(import_marker.exists())

    def test_project_venv_caches_and_directory_links_are_not_followed(self):
        self.dependency_manifest(["ignored-fixture"])
        marker = self.fixture / "ignored-interpreter-executed"
        for relative in ("node_modules/hidden", ".cache/hidden", "output/hidden", ".git/hidden"):
            path = self.template / relative
            (path / "bin").mkdir(parents=True)
            (path / "pyvenv.cfg").write_text("home = ignored\n")
            self.executable(path / "bin/python3", f"touch '{marker}'\nexit 9")
        external = self.fixture / "external-environment"
        (external / "bin").mkdir(parents=True)
        (external / "pyvenv.cfg").write_text("home = ignored\n")
        self.executable(external / "bin/python3", f"touch '{marker}'\nexit 9")
        (self.template / ".venv").symlink_to(external, target_is_directory=True)
        content = self.successful_document(self.run_generation())
        self.assertIn("ignored-fixture : non installé", content)
        self.assertFalse(marker.exists())

    def test_project_venv_ambiguous_metadata_does_not_become_absence(self):
        self.dependency_manifest(["duplicate-fixture"])
        _environment, _interpreter, site_packages = self.project_venv(
            ".venv", {"duplicate-fixture": "1.0"})
        self.add_distribution(site_packages, "duplicate-fixture", "2.0")
        content = self.successful_document(self.run_generation())
        self.assertIn("duplicate-fixture : non vérifiable", content)
        self.assertNotIn("duplicate-fixture : non installé", content)
        self.assertIn("inventaire partiel", content)

    def test_project_venv_failed_or_malformed_probe_preserves_unknown_absence(self):
        self.dependency_manifest(["missing-fixture", "global-fixture"])
        self.add_distribution(self.metadata, "global-fixture", "3.0")
        environment = self.template / ".venv"
        (environment / "bin").mkdir(parents=True)
        (environment / "pyvenv.cfg").write_text("home = fixture\n")
        for body in (None, "printf 'private-probe-marker\\n' >&2\nexit 7",
                     "printf 'malformed-probe-marker\\n'"):
            with self.subTest(body=body):
                if body is not None:
                    self.executable(environment / "bin/python3", body)
                result = self.run_generation()
                content = self.successful_document(result)
                self.assertIn("missing-fixture : non vérifiable", content)
                self.assertNotIn("missing-fixture : non installé", content)
                self.assertIn(f"global-fixture : 3.0 --> {self.home}/python/current/bin/python3", content)
                self.assertNotIn("private-probe-marker", content + result.stdout + result.stderr)
                self.assertNotIn("malformed-probe-marker", content + result.stdout + result.stderr)

    def test_project_venv_search_budget_exhaustion_is_not_absence(self):
        self.dependency_manifest(["budget-fixture"])
        interpreter = self.home / "python/current/bin/python3"
        source = interpreter.read_text(encoding="utf-8")
        old = "import sys; sys.path.insert(0, sys.argv.pop(1)); exec(sys.stdin.read())"
        new = ("import sys,time; sys.path.insert(0, sys.argv.pop(1)); "
               "moments=iter((0.0,13.0)); time.monotonic=lambda:next(moments); exec(sys.stdin.read())")
        self.assertEqual(source.count(old), 1)
        interpreter.write_text(source.replace(old, new, 1), encoding="utf-8")
        content = self.successful_document(self.run_generation())
        self.assertIn("budget-fixture : non vérifiable", content)
        self.assertNotIn("budget-fixture : non installé", content)
        self.assertIn("inventaire partiel", content)

    def test_project_venv_probe_timeout_terminates_descendants(self):
        self.dependency_manifest(["timed-out-fixture"])
        environment = self.template / ".venv"
        (environment / "bin").mkdir(parents=True)
        (environment / "pyvenv.cfg").write_text("home = fixture\n")
        pid_file = self.fixture / "child.pid"
        self.executable(environment / "bin/python3",
                        f"/usr/bin/sleep 10 &\nprintf '%s\\n' \"$!\" > '{pid_file}'\nwait")
        started = time.monotonic()
        content = self.successful_document(self.run_generation())
        self.assertLess(time.monotonic() - started, 8)
        self.assertIn("timed-out-fixture : non vérifiable", content)
        pid = int(pid_file.read_text())
        status = Path(f"/proc/{pid}/stat")
        self.assertTrue(not status.exists() or status.read_text().split()[2] == "Z")

    def test_project_venv_python_alias_and_spaces_preserve_context(self):
        self.dependency_manifest(["space-fixture"])
        environment, interpreter, site_packages = self.project_venv(
            "backend/venv with spaces", {"space-fixture": "1.0"})
        base_interpreter = interpreter.resolve()
        interpreter.unlink()
        (environment / "bin/python").unlink()
        (environment / "bin/python").symlink_to(base_interpreter)
        content = self.successful_document(self.run_generation())
        self.assertIn(f"space-fixture : 1.0 --> {environment}/bin/python\n", content)
        self.assertIn(f"    * Installation : {site_packages.resolve()}\n", content)

    def test_project_venv_empty_metadata_proves_absence_in_inspected_environments(self):
        self.dependency_manifest(["absent-fixture"])
        self.project_venv(".venv", {})
        content = self.successful_document(self.run_generation())
        self.assertIn("absent-fixture : non installé", content)
        self.assertIn("Python DevOps (repli)", content)
        self.assertIn("Installation : non observée", content)
        self.assertNotIn("inventaire partiel", content)

    def test_project_venv_missing_site_packages_is_not_verified_absence(self):
        self.dependency_manifest(["broken-site-fixture"])
        _environment, _interpreter, site_packages = self.project_venv(".venv", {})
        shutil.rmtree(site_packages)
        content = self.successful_document(self.run_generation())
        self.assertIn("broken-site-fixture : non vérifiable", content)
        self.assertNotIn("broken-site-fixture : non installé", content)

    def test_project_venv_unreadable_subtree_does_not_prove_absence(self):
        if os.geteuid() == 0:
            self.skipTest("La vérification des droits nécessite un utilisateur non root")
        self.dependency_manifest(["unreadable-fixture"])
        denied = self.template / "denied"
        denied.mkdir()
        denied.chmod(0)
        try:
            content = self.successful_document(self.run_generation())
        finally:
            denied.chmod(0o700)
        self.assertIn("unreadable-fixture : non vérifiable", content)
        self.assertNotIn("unreadable-fixture : non installé", content)

    def javascript_manifest(self, relative, **data):
        path = self.template / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data), encoding="utf-8")
        return path

    def javascript_document(self, result):
        # Comparer les valeurs littérales après décodage des échappements CommonMark.
        content = self.successful_document(result)
        return re.sub(r"\\([" + re.escape(string.punctuation) + r"])", r"\1", content)

    def javascript_package(self, folder, name, version, actual_name=None):
        directory = self.template / folder / "node_modules" / name
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "package.json").write_text(
            json.dumps({"name": actual_name or name, "version": version,
                        "main": "index.js"}), encoding="utf-8")
        return directory

    def javascript_lock(self, folder, declarations, versions, filename="package-lock.json",
                        lock_version=3, extra_packages=None):
        packages = {"": declarations}
        packages.update({"node_modules/" + name: {"version": version}
                         for name, version in versions.items()})
        packages.update(extra_packages or {})
        path = self.template / folder / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"lockfileVersion": lock_version, "packages": packages}),
                        encoding="utf-8")
        return path

    def test_javascript_pixs_frontend_and_opencode_are_separate_with_effective_paths(self):
        frontend = {"dependencies": {"@tanstack/react-router": "1.170.41",
                                     "react": "19.3.0", "react-dom": "19.3.0"},
                    "devDependencies": {"vite": "8.3.1"}}
        tooling = {"dependencies": {"@opencode-ai/plugin": "1.18.34"}}
        manifests = []
        for folder, data in (("frontend", frontend), (".opencode", tooling)):
            manifests.append(self.javascript_manifest(folder + "/package.json", **data))
            versions = {name: version for group in data.values() for name, version in group.items()}
            manifests.append(self.javascript_lock(folder, data, versions))
            for name, version in versions.items():
                package = self.javascript_package(folder, name, version)
                manifests.append(package / "package.json")
        before = {p: p.read_bytes() for p in manifests}
        content = self.javascript_document(self.run_generation())
        self.assertFalse((self.template / "package.json").exists())
        self.assertEqual(content.count("## Dépendances JavaScript du projet\n"), 1)
        self.assertEqual(content.count("## Dépendances OpenCode du projet\n"), 1)
        self.assertLess(content.index("# NPM\n"), content.index("### frontend/package.json\n"))
        self.assertLess(content.index("### frontend/package.json\n"), content.index("# OpenCode\n"))
        self.assertLess(content.index("# OpenCode\n"), content.index("### .opencode/package.json\n"))
        self.assertLess(content.index("### .opencode/package.json\n"), content.index("# OpenSpec\n"))
        for name, version in {**frontend["dependencies"], **frontend["devDependencies"],
                              **tooling["dependencies"]}.items():
            self.assertIn(f"{name} : déclarée {version} ; verrouillée (npm) {version} ; observée {version}", content)
        self.assertIn("#### dependencies\n", content)
        self.assertIn("#### devDependencies\n", content)
        self.assertIn(f"Installation : {self.template / 'frontend/node_modules/react'}\n", content)
        self.assertEqual(before, {p: p.read_bytes() for p in manifests})
        self.assertNotIn("Gestionnaire déclaré", content)

    def test_javascript_categories_and_declared_engines_are_preserved(self):
        self.javascript_manifest("package.json", dependencies={"shared": "^1.0.0"},
                                 devDependencies={"shared": "~1.1.0"},
                                 peerDependencies={"peer": ">=2"},
                                 optionalDependencies={"optional": "3.0.0"},
                                 engines={"node": ">=24", "npm": "^11"},
                                 packageManager="pnpm@10.0.0")
        content = self.javascript_document(self.run_generation())
        for group in ("dependencies", "devDependencies", "peerDependencies", "optionalDependencies"):
            self.assertIn("#### " + group + "\n", content)
        self.assertIn("shared : déclarée ^1.0.0", content)
        self.assertIn("shared : déclarée ~1.1.0", content)
        self.assertIn("Gestionnaire déclaré : pnpm@10.0.0", content)
        self.assertIn("engines.node : &gt;=24", content)
        self.assertIn("observée non observée localement", content)
        self.assertNotIn("incompatible", content)

    def test_javascript_empty_root_workspace_and_unrelated_manifest_selection(self):
        self.javascript_manifest("package.json", workspaces=["packages/*", "nested/**/member"])
        self.javascript_manifest("packages/empty/package.json", name="empty", version="1.0.0")
        self.javascript_manifest("nested/a/b/member/package.json", name="member", version="1.0.0")
        self.javascript_manifest("unrelated/package.json", name="unused")
        content = self.javascript_document(self.run_generation())
        for path in ("package.json", "packages/empty/package.json", "nested/a/b/member/package.json"):
            self.assertIn("### " + path + "\n", content)
        self.assertNotIn("### unrelated/package.json", content)
        self.assertIn("Manifestes sans dépendance non retenus : 1", content)
        self.assertIn("Aucune dépendance directement déclarée", content)

    def test_javascript_shared_workspace_lock_and_root_installation(self):
        self.javascript_manifest("package.json", workspaces=["packages/*"])
        declarations = {"dependencies": {"shared": "^2.0.0"}}
        self.javascript_manifest("packages/ui/package.json", **declarations)
        lock = self.javascript_lock(".", {}, {"shared": "2.1.0"},
                                    extra_packages={"packages/ui": declarations})
        package = self.javascript_package(".", "shared", "2.1.0")
        content = self.javascript_document(self.run_generation())
        self.assertIn("shared : déclarée ^2.0.0 ; verrouillée (npm) 2.1.0 ; observée 2.1.0", content)
        self.assertIn(f"Verrou npm retenu : {lock}\n", content)
        self.assertIn(f"Installation : {package.resolve()}\n", content)
        self.assertNotIn("déclarations différentes ou absentes", content)

    def test_javascript_local_lock_and_nearest_installation_take_priority(self):
        self.javascript_manifest("package.json", workspaces=["packages/*"])
        data = {"dependencies": {"shared": "*"}}
        self.javascript_manifest("packages/ui/package.json", **data)
        self.javascript_lock(".", {}, {"shared": "9.0.0"},
                             extra_packages={"packages/ui": data})
        local = self.javascript_lock("packages/ui", data, {"shared": "2.0.0"})
        self.javascript_package(".", "shared", "9.0.0")
        package = self.javascript_package("packages/ui", "shared", "2.0.0")
        content = self.javascript_document(self.run_generation())
        self.assertIn("shared : déclarée * ; verrouillée (npm) 2.0.0 ; observée 2.0.0", content)
        self.assertIn(f"Verrou npm retenu : {local}\n", content)
        self.assertIn(f"Installation : {package}\n", content)
        self.assertNotIn("observée 9.0.0", content)

    def test_javascript_invalid_nearest_metadata_does_not_use_parent(self):
        self.javascript_manifest("frontend/package.json", dependencies={"shared": "*"})
        self.javascript_package(".", "shared", "9.0.0")
        nearest = self.javascript_package("frontend", "shared", "1.0.0")
        (nearest / "package.json").write_text("{invalid", encoding="utf-8")
        content = self.javascript_document(self.run_generation())
        self.assertIn("observée non vérifiable", content)
        self.assertNotIn("observée 9.0.0", content)
        (nearest / "package.json").write_text(json.dumps({"name": "other", "version": "1.0.0"}),
                                             encoding="utf-8")
        content = self.javascript_document(self.run_generation())
        self.assertIn("métadonnées incohérentes", content)

    def test_javascript_workspace_and_pnpm_links_keep_real_installation_paths(self):
        data = {"dependencies": {"local": "workspace:*", "nested": "1.0.0"}}
        self.javascript_manifest("package.json", workspaces=["packages/*"], **data)
        target = self.javascript_manifest("packages/local/package.json", name="local", version="3.0.0")
        self.javascript_lock(".", data, {}, extra_packages={
            "node_modules/local": {"link": True, "resolved": "packages/local"},
            "packages/local": {"name": "local", "version": "3.0.0"},
            "node_modules/nested": {"version": "1.0.0"},
        })
        modules = self.template / "node_modules"
        modules.mkdir()
        (modules / "local").symlink_to(target.parent, target_is_directory=True)
        pnpm = modules / ".pnpm/nested@1.0.0/node_modules/nested"
        pnpm.mkdir(parents=True)
        (pnpm / "package.json").write_text(json.dumps({"name": "nested", "version": "1.0.0"}),
                                           encoding="utf-8")
        (modules / "nested").symlink_to(pnpm, target_is_directory=True)
        content = self.javascript_document(self.run_generation())
        self.assertIn("local : déclarée workspace:* ; verrouillée (npm) 3.0.0 ; observée 3.0.0", content)
        self.assertIn(f"Installation : {target.parent.resolve()}\n", content)
        self.assertIn(f"Installation : {pnpm.resolve()}\n", content)
        self.assertNotIn("### node\\_modules", content)

    def test_javascript_external_and_protected_installation_links_are_not_read(self):
        self.javascript_manifest("frontend/package.json", dependencies={"outside": "*", "protected": "*"})
        outside = self.fixture / "outside-package"
        outside.mkdir()
        (outside / "package.json").write_text(json.dumps({"name": "outside", "version": "9.9.9"}),
                                               encoding="utf-8")
        protected = self.template / ".opencode/config/protected"
        protected.mkdir(parents=True)
        (protected / "package.json").write_text(json.dumps({"name": "protected", "version": "8.8.8"}),
                                                 encoding="utf-8")
        modules = self.template / "frontend/node_modules"
        modules.mkdir()
        (modules / "outside").symlink_to(outside, target_is_directory=True)
        (modules / "protected").symlink_to(protected, target_is_directory=True)
        content = self.javascript_document(self.run_generation())
        self.assertEqual(content.count("observée non vérifiable (cible hors périmètre)"), 2)
        self.assertNotIn("9.9.9", content)
        self.assertNotIn("8.8.8", content)

    def test_javascript_symbolic_manifests_metadata_and_locks_are_nonverifiable(self):
        target = self.fixture / "metadata.json"
        target.write_text(json.dumps({"name": "fixture", "version": "9.9.9",
                                     "dependencies": {"should-not-appear": "1.0.0"}}), encoding="utf-8")
        (self.template / "package.json").symlink_to(target)
        self.javascript_manifest("frontend/package.json", dependencies={"fixture": "*"})
        package = self.javascript_package("frontend", "fixture", "1.0.0")
        (package / "package.json").unlink()
        (package / "package.json").symlink_to(target)
        (self.template / "frontend/package-lock.json").symlink_to(target)
        content = self.javascript_document(self.run_generation())
        self.assertIn("manifeste non vérifiable", content)
        self.assertIn("verrou non vérifiable", content)
        self.assertIn("observée non vérifiable", content)
        self.assertNotIn("should-not-appear", content)
        self.assertNotIn("9.9.9", content)

    def test_javascript_npm_lock_formats_and_shrinkwrap_precedence(self):
        data = {"dependencies": {"fixture": "*"}}
        self.javascript_manifest("frontend/package.json", **data)
        for version in (2, 3):
            with self.subTest(version=version):
                self.javascript_lock("frontend", data, {"fixture": "1.0.0"}, lock_version=version)
                content = self.javascript_document(self.run_generation())
                self.assertIn("verrouillée (npm) 1.0.0 ; observée non observée localement", content)
        shrinkwrap = self.javascript_lock("frontend", data, {"fixture": "2.0.0"},
                                          filename="npm-shrinkwrap.json")
        (self.template / "frontend/pnpm-lock.yaml").write_text("unsupported-test-only\n", encoding="utf-8")
        content = self.javascript_document(self.run_generation())
        self.assertIn(f"Verrou npm retenu : {shrinkwrap}\n", content)
        self.assertIn("verrouillée (npm) 2.0.0", content)
        self.assertNotIn("verrouillée (npm) 1.0.0", content)
        self.assertIn("Autres verrous non analysés", content)

    def test_javascript_unsupported_or_invalid_locks_do_not_become_installations(self):
        data = {"dependencies": {"fixture": "1.0.0"}}
        self.javascript_manifest("frontend/package.json", **data)
        self.javascript_package("frontend", "fixture", "1.0.0")
        for filename, contents in (
                ("package-lock.json", '{"lockfileVersion":1,"dependencies":{"fixture":{"version":"9.9.9"}}}'),
                ("package-lock.json", "{broken-private-canary"),
                ("yarn.lock", "private-canary 9.9.9"),
                ("pnpm-lock.yaml", "private-canary: 9.9.9"),
                ("bun.lock", '{"private-canary":"9.9.9"}'),
                ("bun.lockb", "private-canary")):
            with self.subTest(filename=filename, contents=contents[:12]):
                path = self.template / "frontend" / filename
                path.write_text(contents, encoding="utf-8")
                content = self.javascript_document(self.run_generation())
                self.assertIn("verrouillée (npm) non vérifiable", content)
                self.assertIn("observée 1.0.0", content)
                self.assertNotIn("9.9.9", content)
                self.assertNotIn("private-canary", content)
                path.unlink()

    def test_javascript_lock_desynchronization_missing_entry_and_observed_difference(self):
        data = {"dependencies": {"fixture": "1.0.0", "missing": "1.0.0"}}
        self.javascript_manifest("frontend/package.json", **data)
        self.javascript_lock("frontend", {"dependencies": {"fixture": "0.1.0"}}, {"fixture": "1.0.0"})
        self.javascript_package("frontend", "fixture", "2.0.0")
        content = self.javascript_document(self.run_generation())
        self.assertIn("déclarations différentes ou absentes dans le verrou", content)
        self.assertIn("Écart entre version verrouillée et version observée", content)
        self.assertIn("missing : déclarée 1.0.0 ; verrouillée (npm) non renseignée dans le verrou", content)
        self.assertNotIn("compatible", content)

    def test_javascript_aliases_validate_the_real_package_identity(self):
        self.javascript_manifest("package.json", dependencies={"alias": "npm:@scope/real@^2.0.0",
                                                                "unversioned": "npm:@scope/real"})
        self.javascript_package(".", "alias", "2.1.0", actual_name="@scope/real")
        self.javascript_package(".", "unversioned", "2.1.0", actual_name="@scope/real")
        content = self.javascript_document(self.run_generation())
        self.assertIn("alias : déclarée alias npm @scope/real ^2.0.0", content)
        self.assertIn("unversioned : déclarée alias npm @scope/real *", content)
        self.assertEqual(content.count("observée 2.1.0"), 2)

    def test_javascript_private_references_invalid_fields_and_code_are_not_published_or_executed(self):
        marker = self.fixture / "javascript-executed"
        data = {"dependencies": {"url": "https://test-user:private-canary@example.invalid/archive.tgz",
                                  "local": "file:../private-canary",
                                  "git": "git+https://private-canary@example.invalid/repo",
                                  "invalid\n# injected-private-canary": "1.0.0",
                                  "bad-type": ["private-canary"]},
                "devDependencies": "private-canary",
                "engines": {"node": "https://private-canary"},
                "packageManager": "private-canary",
                "scripts": {"install": f"touch {marker}"}}
        self.javascript_manifest("package.json", **data)
        for name in ("url", "local", "git"):
            package = self.javascript_package(".", name, "1.0.0")
            (package / "index.js").write_text(
                f"require('fs').writeFileSync({json.dumps(str(marker))}, 'executed');\n", encoding="utf-8")
        self.javascript_package(".", "bad-type", "3.0.0", actual_name="other")
        content = self.javascript_document(self.run_generation())
        self.assertIn("référence externe ou locale masquée", content)
        self.assertIn("devDependencies non vérifiables", content)
        self.assertIn("packageManager non vérifiable", content)
        self.assertNotIn("private-canary", content)
        self.assertNotIn("# injected", content)
        self.assertIn("métadonnées incohérentes", content)
        self.assertFalse(marker.exists())

    def test_javascript_discovery_excludes_generated_venvs_and_directory_links(self):
        self.javascript_manifest("frontend/package.json", dependencies={"retained": "1.0.0"})
        self.javascript_manifest(".opencode/package.json", dependencies={"tooling": "1.0.0"})
        for folder in ("node_modules/third-party", ".git/fixture", ".cache", "dist", "build",
                       "output", "reports", "logs", "tmp", "PROMPTS", "openspec", ".agents",
                       ".opencode/config", ".opencode/state", ".opencode/commands"):
            self.javascript_manifest(folder + "/package.json", dependencies={"ignored-canary": "9.9.9"})
        self.javascript_manifest("custom-runtime/package.json", dependencies={"ignored-canary": "9.9.9"})
        (self.template / "custom-runtime/pyvenv.cfg").write_text("synthetic = yes\n", encoding="utf-8")
        outside = self.fixture / "outside-source"
        outside.mkdir()
        (outside / "package.json").write_text(json.dumps({"dependencies": {"ignored-canary": "9.9.9"}}),
                                               encoding="utf-8")
        (self.template / "linked-source").symlink_to(outside, target_is_directory=True)
        content = self.javascript_document(self.run_generation())
        self.assertIn("retained : déclarée 1.0.0", content)
        self.assertIn("tooling : déclarée 1.0.0", content)
        self.assertNotIn("ignored-canary", content)
        self.assertNotIn("9.9.9", content)

    def test_javascript_fallback_analyzer_works_without_node_or_devops_python(self):
        self.javascript_manifest("frontend/package.json", dependencies={"fixture": "1.0.0"})
        self.javascript_package("frontend", "fixture", "1.0.0")
        (self.home / "node/current/bin/node").unlink()
        (self.home / "python/current/bin/python3").unlink()
        content = self.javascript_document(self.run_generation())
        self.assertIn("observée 1.0.0", content)
        self.assertIn("Node DevOps absent", content)

    def test_javascript_global_cache_is_not_a_project_installation(self):
        self.javascript_manifest(".opencode/package.json", dependencies={"fixture": "*"})
        global_package = self.home / ".cache/opencode/node_modules/fixture"
        global_package.mkdir(parents=True)
        (global_package / "package.json").write_text(json.dumps({"name": "fixture", "version": "9.9.9"}),
                                                      encoding="utf-8")
        content = self.javascript_document(self.run_generation())
        self.assertIn("observée non observée localement", content)
        self.assertNotIn("9.9.9", content)

    def test_javascript_invalid_and_duplicate_json_and_group_types_are_explicit(self):
        path = self.template / "package.json"
        for text in ('{"dependencies":{"fixture":"1.0.0"},"dependencies":{}}',
                     '["private-canary"]', '{"dependencies":false}', '{"workspaces":["../private-canary"]}'):
            with self.subTest(text=text):
                path.write_text(text, encoding="utf-8")
                content = self.javascript_document(self.run_generation())
                self.assertIn("non vérifiable", content)
                self.assertNotIn("private-canary", content)

    def test_javascript_limits_are_explicit_instead_of_verified_absence(self):
        self.javascript_manifest("package.json", dependencies={"first": "1.0.0", "second": "1.0.0"})
        for number in range(4):
            self.javascript_manifest(f"components/{number}/package.json",
                                     dependencies={"nested": "1.0.0"})
        for before, after in (
                ("JS_SEARCH_BUDGET = 12.0", "JS_SEARCH_BUDGET = 0.0"),
                ("MAX_ENTRIES = 10000", "MAX_ENTRIES = 2"),
                ("MAX_MANIFESTS = 128", "MAX_MANIFESTS = 2"),
                ("MAX_DEPENDENCIES = 1024", "MAX_DEPENDENCIES = 1"),
                ("TOTAL_LIMIT = 32 * 1024 * 1024", "TOTAL_LIMIT = 40")):
            with self.subTest(limit=before):
                content = self.javascript_document(self.run_generation(source_replacements=((before, after),)))
                self.assertIn("Inventaire incomplet", content)

    def test_javascript_oversized_manifest_lock_and_metadata_are_nonverifiable(self):
        self.javascript_manifest("frontend/package.json", dependencies={"fixture": "1.0.0"})
        package = self.javascript_package("frontend", "fixture", "1.0.0")
        (package / "package.json").write_text(" " * (1024 * 1024 + 1), encoding="utf-8")
        self.javascript_manifest("oversized/package.json", padding="x" * (1024 * 1024))
        lock = self.template / "frontend/package-lock.json"
        lock.write_text(" " * (8 * 1024 * 1024 + 1), encoding="utf-8")
        content = self.javascript_document(self.run_generation())
        self.assertIn("fichier JSON trop volumineux", content)
        self.assertIn("observée non vérifiable", content)
        self.assertIn("Inventaire incomplet", content)

    def test_javascript_spaces_markdown_and_control_paths_preserve_document_structure(self):
        path = self.javascript_manifest("client [test]/package.json", dependencies={"fixture": "1.0.0"})
        self.javascript_package("client [test]", "fixture", "1.0.0")
        self.javascript_manifest("bad\n# injected/package.json", dependencies={"hidden-canary": "1.0.0"})
        content = self.successful_document(self.run_generation())
        self.assertIn("### client \\[test\\]/package.json\n", content)
        self.assertIn("observée 1.0.0", content)
        self.assertIn("chemin de découverte non restituable", content)
        self.assertNotIn("\n# injected", content)
        self.assertNotIn("hidden-canary", content)
        self.assertNotIn(chr(28), content)
        self.assertTrue(path.is_file())
        self.assertTrue(content.endswith("  * Mode headless : --headless\n"))

    def test_javascript_collector_failure_discards_raw_output_and_preserves_other_sections(self):
        for body in ("printf 'private-canary'; return 7",
                     "printf 'private-canary'; return 0"):
            with self.subTest(body=body):
                content = self.javascript_document(self.run_generation(
                    "projects_template_devops_javascript() { " + body + "; }\n"))
                self.assertIn("Inventaire non vérifiable : analyse échouée", content)
                self.assertNotIn("private-canary", content)
                self.assertIn("# OpenCode\n", content)
                self.assertIn("# PostgreSQL Serveur\n", content)

    def test_javascript_collector_runs_once_and_repeated_inventory_is_stable(self):
        self.javascript_manifest("frontend/package.json", dependencies={"fixture": "1.0.0"})
        self.javascript_manifest(".opencode/package.json", dependencies={"tooling": "1.0.0"})
        log = self.fixture / "javascript-collects"
        self.environment["TEST_JAVASCRIPT_COLLECTS"] = str(log)
        wrapper = r'''
eval "$(declare -f projects_template_devops_javascript | sed '1s/projects_template_devops_javascript/saved_javascript_collector/')"
projects_template_devops_javascript() {
    printf 'collect\n' >> "$TEST_JAVASCRIPT_COLLECTS"
    saved_javascript_collector "$@"
}
'''
        first = self.successful_document(self.run_generation(wrapper))
        second = self.successful_document(self.run_generation(wrapper))
        self.assertEqual(first, second)
        self.assertEqual(log.read_text().splitlines(), ["collect", "collect"])
        self.assertEqual(first.count("## Dépendances JavaScript du projet\n"), 1)
        self.assertEqual(first.count("## Dépendances OpenCode du projet\n"), 1)

    def test_javascript_unreadable_sources_and_subtrees_remain_unknown(self):
        if os.geteuid() == 0:
            return
        manifest = self.javascript_manifest("frontend/package.json", dependencies={"fixture": "1.0.0"})
        manifest.chmod(0)
        self.addCleanup(manifest.chmod, 0o600)
        content = self.javascript_document(self.run_generation())
        self.assertIn("manifeste non vérifiable", content)
        manifest.chmod(0o600)
        package = self.javascript_package("frontend", "fixture", "1.0.0")
        metadata = package / "package.json"
        metadata.chmod(0)
        self.addCleanup(metadata.chmod, 0o600)
        content = self.javascript_document(self.run_generation())
        self.assertIn("observée non vérifiable", content)
        hidden = self.template / "inaccessible"
        hidden.mkdir()
        hidden.chmod(0)
        self.addCleanup(hidden.chmod, 0o700)
        content = self.javascript_document(self.run_generation())
        self.assertIn("Inventaire incomplet", content)

    def test_javascript_non_regular_sources_do_not_block_json_reads(self):
        self.javascript_manifest("frontend/package.json", dependencies={"fixture": "1.0.0"})
        package = self.javascript_package("frontend", "fixture", "1.0.0")
        metadata = package / "package.json"
        metadata.unlink()
        os.mkfifo(metadata)
        os.mkfifo(self.template / "package.json")
        started = time.monotonic()
        content = self.javascript_document(self.run_generation())
        self.assertLess(time.monotonic() - started, 5)
        self.assertIn("fichier non ordinaire", content)
        self.assertIn("observée non vérifiable", content)

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
        self.assertFalse((self.template / 'pyproject.toml').exists())

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
                      'projects_template_devops_test_authorization() { printf partial; return 1; }',
                      'ENV_DEVOPS_TESTS_DOCKER=0\nENV_DEVOPS_TESTS_LXC=1\n'
                      'projects_template_devops_test_authorization() { printf partial; return 1; }',
                      'ENV_DEVOPS_TESTS_DOCKER=0\nENV_DEVOPS_TESTS_LXC=1\n'
                      'printf() { if [[ "$1" == *"Binaires et bibliothèques installés"* ]]; '
                      'then return 1; fi; builtin printf "$@"; }',
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

    def test_two_projects_use_their_own_configuration_and_manifest(self):
        projects_root = self.fixture / 'projects with spaces'
        initial_configuration = (self.template / 'project.env').read_text()
        previous_document = None
        for project, port in (('alpha', 5501), ('beta', 5502)):
            path = projects_root / project
            path.mkdir(parents=True)
            (path / 'project.env').write_text(initial_configuration.replace(
                'PG_PORT=5544', f'PG_PORT={port}'), encoding='utf-8')
            (path / 'pyproject.toml').write_text(
                f'[project]\ndependencies = ["{project}>=1"]\n', encoding='utf-8')
            result = self.run_generation(project=project, projects_root=projects_root)
            self.assertEqual(result.returncode, 0, result.stderr)
            content = (path / 'DEVOPS.md').read_text()
            self.assertIn(f'# DEVOPS.md — {project}\n', content)
            self.assertIn(f'database.example.test:{port}', content)
            self.assertIn(f'{project} >=1 : non installé', content)
            self.assertNotIn('beta >=1' if project == 'alpha' else 'alpha >=1', content)
            self.assertIn('  * PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD\n', content)
            if previous_document is not None:
                self.assertEqual((projects_root / 'alpha/DEVOPS.md').read_bytes(), previous_document)
            previous_document = (path / 'DEVOPS.md').read_bytes()
        self.assertFalse(self.document.exists())
        self.assertIn('database.example.test|5501|', self.query_log.read_text())
        self.assertIn('database.example.test|5502|', self.query_log.read_text())

    def test_python_manifest_created_only_for_exact_python_type(self):
        project_env = self.template / 'project.env'
        initial_configuration = project_env.read_text()
        manifest = self.template / 'pyproject.toml'
        for project_type in ('', 'NODE', 'python', 'PYTHON'):
            with self.subTest(project_type=project_type):
                project_env.write_text(initial_configuration + f'PROJECT_TYPE="{project_type}"\n')
                content = self.successful_document(self.run_generation())
                self.assertEqual(manifest.exists(), project_type == 'PYTHON')
                if project_type == 'PYTHON':
                    self.assertEqual(tomllib.loads(manifest.read_text()), {
                        'project': {'name': 'template', 'version': '0.0.0', 'dependencies': []}})
                    self.assertEqual(manifest.stat().st_uid, os.getuid())
                    self.assertIn('Aucune dépendance déclarée dans [project].dependencies', content)
                else:
                    self.assertIn('pyproject.toml absent', content)

    def test_existing_manifest_is_preserved_for_any_project_type(self):
        manifest = self.template / 'pyproject.toml'
        manifest.write_text('[project]\nname="existing"\nversion="9.8.7"\ndependencies=[]\n')
        manifest.chmod(0o640)
        before = manifest.stat()
        content = manifest.read_bytes()
        for project_type in ('PYTHON', 'NODE'):
            with self.subTest(project_type=project_type):
                with (self.template / 'project.env').open('a') as stream:
                    stream.write(f'PROJECT_TYPE={project_type}\n')
                self.successful_document(self.run_generation())
                after = manifest.stat()
                self.assertEqual(manifest.read_bytes(), content)
                self.assertEqual((after.st_ino, after.st_mode, after.st_uid, after.st_gid),
                                 (before.st_ino, before.st_mode, before.st_uid, before.st_gid))

    def test_project_type_is_never_executed(self):
        marker = self.fixture / 'type-command-must-not-run'
        with (self.template / 'project.env').open('a') as stream:
            stream.write(f'PROJECT_TYPE=$(touch {marker})\n')
        result = self.run_generation()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(marker.exists())
        self.assertFalse((self.template / 'pyproject.toml').exists())
        self.assertNotIn(str(marker), result.stdout + result.stderr)

    def test_project_identifiers_arity_and_symlink_directory_are_rejected(self):
        for project in ('', '.', '..', '../elsewhere', '/absolute', 'part/path', 'line\nbreak'):
            with self.subTest(project=project):
                result = self.run_generation(project=project)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Usage : rid projects template devops <ID PROJECT>', result.stderr)
        for arguments in ((), ('template', 'extra')):
            self.assertNotEqual(self.run_generation(arguments=arguments).returncode, 0)
        link = self.home / 'datas/link'
        link.symlink_to(self.template, target_is_directory=True)
        self.assertNotEqual(self.run_generation(project='link').returncode, 0)
        self.assertFalse(self.document.exists())

    def test_python_project_with_spaces_gets_a_valid_minimal_name(self):
        path = self.home / 'datas/Projet & essai'
        path.mkdir()
        (path / 'project.env').write_text('PROJECT_TYPE=PYTHON\n')
        result = self.run_generation(project=path.name)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(tomllib.loads((path / 'pyproject.toml').read_text())['project']['name'],
                         'Projet---essai')
        self.assertIn('# DEVOPS.md — Projet & essai', (path / 'DEVOPS.md').read_text())

    def test_create_project_runs_real_generation_after_copy_and_rights(self):
        self.environment['ENV_DEVOPS_TESTS_LXC'] = '1'
        self.configure_tpm()
        projects_source = (ROOT / 'modules/projects/projects.sh').read_text()
        projects_source = projects_source.replace(
            'local template_path="/home/${DEVOPS_USER}/datas/template"',
            'local template_path="$TEST_DEVOPS_HOME/datas/template"')
        (self.template / 'README.md').write_text('# Template\n')
        self.javascript_manifest('frontend/package.json', dependencies={'creation-fixture': '1.0.0'})
        # Un modèle Python ne doit pas transmettre son manifeste à un projet Node.
        (self.template / 'pyproject.toml').write_text('[project]\nname="existing"\ndependencies=[]\n')
        extra = projects_source + r'''
check_devops_user() { return 0; }
install() { mkdir -p "${!#}"; }
chown() { printf 'rights\n' >> "$TEST_DEVOPS_HOME/order"; }
update_projects() {
    printf 'PROJECT_ID=%s\nPROJECT_NAME="Application"\nPROJECT_TYPE=%s\n' "$1" "$TEST_PROJECT_TYPE" > "${DEVOPS_PROJECTS_ROOT}/$1/project.env"
}
projects_template_openspec() {
    printf 'openspec:%s\n' "$1" >> "$TEST_DEVOPS_HOME/order"
    if [[ "${TEST_CREATE_OPENSPEC_FAILURE:-0}" == 1 ]]; then return 8; fi
}
eval "$(declare -f projects_template_devops | sed '1s/projects_template_devops/original_template_devops/')"
projects_template_devops() {
    printf 'generation:%s\n' "$1" >> "$TEST_DEVOPS_HOME/order"
    if [[ "$TEST_CREATE_FAILURE" == 1 ]]; then return 9; fi
    original_template_devops "$@"
}
DEVOPS_USER="$ENV_DEVOPS_USER"
DEVOPS_GROUP="$(id -gn)"
DEVOPS_PROJECTS_ROOT="$TEST_DEVOPS_HOME/datas"
create_project "$TEST_CREATED_PROJECT"
exit $?
'''
        for project, project_type, failure in (
                ('node-app', 'NODE', '0'), ('python-app', 'PYTHON', '0'),
                ('python-minimal', 'PYTHON', '0'),
                ('failed-app', 'PYTHON', '1'), ('failed-openspec', 'PYTHON', '0')):
            with self.subTest(project=project):
                if project == 'python-minimal':
                    (self.template / 'pyproject.toml').unlink()
                self.environment.update(TEST_CREATED_PROJECT=project, TEST_PROJECT_TYPE=project_type,
                                        TEST_CREATE_FAILURE=failure,
                                        TEST_CREATE_OPENSPEC_FAILURE=str(int(project == 'failed-openspec')))
                order = self.home / 'order'
                if order.exists():
                    order.unlink()
                result = self.run_generation(extra)
                target = self.home / 'datas' / project
                self.assertTrue(target.is_dir())
                expected_order = ['rights', f'openspec:{project}']
                if project != 'failed-openspec':
                    expected_order += [f'generation:{project}'] + ([] if failure == '1' else ['rights'])
                self.assertEqual(order.read_text().splitlines(), expected_order)
                if project == 'failed-openspec':
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn('OpenSpec échouée', result.stderr)
                    self.assertNotIn('créé avec succès', result.stdout)
                    self.assertFalse((target / 'DEVOPS.md').exists())
                elif failure == '1':
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn('génération de DEVOPS.md échouée', result.stderr)
                    self.assertNotIn('créé avec succès', result.stdout)
                else:
                    self.assertEqual(result.returncode, 0, result.stderr)
                    content = (target / 'DEVOPS.md').read_text()
                    self.assertIn(f'# DEVOPS.md — {project}', content)
                    self.assert_test_container_sections(content, True, True)
                    self.assertEqual(content.count('## Dépendances JavaScript du projet\n'), 1)
                    self.assertIn('creation-fixture : déclarée 1.0.0', content)
                    self.assertIn('Version : 0.7\n', content)
                    self.assertIn('  * hvp1.pixs.fr\n', content)
                    self.assert_prompts_section(content)
                    self.assertIn('Début du relevé (UTC) : 2026-10-09T06:30:00Z\n', content)
                    self.assertEqual(content.count('Généré automatiquement par Debian Installeur Unifié (DIU).'), 1)
                    self.assertIn('# Tests navigateurs extérieurs en mode headless\n', content)
                    self.assertIn('## Chromium\n\n  * 134.0.6998.88', content)
                    self.assertIn('## Firefox\n\n  * 140.0.4esr', content)
                    self.assertEqual(content.count('# Matériel\n'), 1)
                    self.assertIn('Fabricant : IFX\n', content)
                    self.assertEqual((target / 'pyproject.toml').exists(), project_type == 'PYTHON')
                    if project == 'python-minimal':
                        self.assertEqual(tomllib.loads((target / 'pyproject.toml').read_text())['project'],
                                         {'name': project, 'version': '0.0.0', 'dependencies': []})
                    self.assertEqual((target / 'README.md').read_text(), '# Application\n')

    def test_dispatch_invokes_only_the_requested_leaf_without_configuration(self):
        source = (ROOT / 'root-install-debian.sh').read_text(encoding='utf-8')
        function = re.search(r'^manage_project_action\(\) \{\n.*?^\}', source, re.M | re.S)[0]
        script = function + r'''
projects_template_devops() { printf 'generation:%s\n' "$1"; }
projects_template_devops_all() { printf 'batch\n'; }
projects_template_openspec() { printf 'openspec:%s\n' "$1"; }
projects_template_openspec_all() { printf 'openspec-batch\n'; }
projects_template_all_all() { printf 'all-models-batch\n'; }
rid_display_command_error() { printf 'help:%s\n' "$*"; }
manage_project_action "$@"
'''
        for arguments, status, expected in (
            (('template', 'devops', 'application'), 0, 'generation:application\n'),
            (('template', 'all', 'all'), 0, 'all-models-batch\n'),
            (('template', 'all', 'all', 'extra'), 2, 'help:projects template'),
            (('template', 'all', 'application'), 2, 'help:projects template'),
            (('template', 'all'), 2, 'help:projects template'),
            (('template', 'devops', 'template'), 0, 'generation:template\n'),
            (('template', 'devops', 'all'), 0, 'batch\n'),
            (('template', 'devops', 'devops'), 0, 'generation:devops\n'),
            (('template', 'devops', 'openspec'), 0, 'generation:openspec\n'),
            (('template', 'application', 'devops'), 2, 'help:projects template'),
            (('template', 'all', 'devops'), 2, 'help:projects template'),
            (('template', 'devops', ''), 2, 'help:projects template'),
            (('template', 'devops', 'application', 'extra'), 2, 'help:projects template'),
            (('template', 'devops', 'all', 'extra'), 2, 'help:projects template'),
            (('template', 'devops', '../elsewhere'), 2, 'help:projects template'),
            (('template', 'devops', '.'), 2, 'help:projects template'),
            (('template', 'devops', 'line\nbreak'), 2, 'help:projects template'),
            (('template', 'openspec', 'application'), 0, 'openspec:application\n'),
            (('template', 'openspec', 'all'), 0, 'openspec-batch\n'),
            (('template', 'openspec', 'all', 'extra'), 2, 'help:projects template'),
            (('template', 'openspec', 'devops'), 0, 'openspec:devops\n'),
            (('template', 'openspec', 'openspec'), 0, 'openspec:openspec\n'),
            (('template', 'openspec'), 2, 'help:projects template'),
            (('template', 'openspec', ''), 2, 'help:projects template'),
            (('template', 'openspec', 'application', 'extra'), 2, 'help:projects template'),
            (('template', 'openspec', '../elsewhere'), 2, 'help:projects template'),
            (('template', 'openspec', '.'), 2, 'help:projects template'),
            (('template', 'openspec', 'line\nbreak'), 2, 'help:projects template'),
            (('template', 'application', 'openspec'), 2, 'help:projects template'),
            (('template', 'all', 'openspec'), 2, 'help:projects template'),
            (('template', 'application', 'openspec', 'extra'), 2, 'help:projects template'),
            (('template', 'unknown'), 2, 'help:projects template'),
            (('template',), 2, 'help:projects template'),
            (('template', 'devops'), 2, 'help:projects template'),
            (('template', 'template', 'devops', 'extra'), 2, 'help:projects template'),
            (('template', '../elsewhere', 'devops'), 2, 'help:projects template'),
            (('template', 'all', 'devops', 'extra'), 2, 'help:projects template'),
            (('template', 'all', 'unknown'), 2, 'help:projects template'),
        ):
            with self.subTest(arguments=arguments):
                result = subprocess.run(['bash', '-Eeuo', 'pipefail', '-c', script, 'bash', *arguments],
                                        text=True, capture_output=True, check=False)
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertIn(expected, result.stdout)
                if status:
                    self.assertNotIn('generation', result.stdout)
                    self.assertNotIn('batch', result.stdout)
                    self.assertNotIn('openspec:', result.stdout)

    def configured_project(self, root, project, updates=None):
        path = root / project
        path.mkdir(parents=True)
        values = dict(PROJECT_ID=project, PROJECT_NAME='Test project', PROJECT_TYPE='NODE',
                      PROJECT_DOCKERED='No', PROJECT_DEBIAN_PACKAGE='0')
        values.update(updates or {})
        text = ''.join(f"export {key}='{value}' # test-only\n" for key, value in values.items()
                       if value is not None)
        (path / 'project.env').write_text(text, encoding='utf-8')
        return path

    def test_batch_selects_only_five_nonempty_variables_and_matching_id(self):
        root = self.fixture / 'configured projects'
        for project in ('template', 'all', '.hidden', 'with spaces'):
            self.configured_project(root, project)
        keys = ('PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE', 'PROJECT_DOCKERED',
                'PROJECT_DEBIAN_PACKAGE')
        for index, key in enumerate(keys):
            self.configured_project(root, f'missing-{index}', {key: None})
            self.configured_project(root, f'empty-{index}', {key: ''})
        self.configured_project(root, 'mismatch', {'PROJECT_ID': 'another-project'})
        self.configured_project(root / 'container', 'nested')
        result = self.run_generation(
            'projects_template_devops() { printf "called:%s\\n" "$1"; }',
            projects_root=root, batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(set(re.findall(r'^called:(.*)$', result.stdout, re.M)),
                         {'template', 'all', '.hidden', 'with spaces'})
        self.assertEqual(len(re.findall(r'^called:', result.stdout, re.M)), 4)
        self.assertIn('4 sélectionné(s), 4 réussi(s), 12 ignoré(s), 0 échoué(s)', result.stdout)
        self.assertFalse(self.document.exists())

    def test_batch_does_not_inherit_or_execute_configuration_or_follow_links(self):
        root = self.fixture / 'projects'
        self.configured_project(root, 'complete')
        incomplete = self.configured_project(root, 'inherited', {'PROJECT_TYPE': None})
        for key in ('PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE', 'PROJECT_DOCKERED',
                    'PROJECT_DEBIAN_PACKAGE'):
            self.environment[key] = 'PYTHON'
        marker = self.fixture / 'configuration-must-not-execute'
        injection = self.configured_project(root, 'injection')
        with (injection / 'project.env').open('a') as stream:
            stream.write(f'PROJECT_TYPE=$(touch {marker})\n')
        with (incomplete / 'project.env').open('a') as stream:
            stream.write('# PROJECT_TYPE=PYTHON\nPG_PASSWORD=test-only-not-to-display\n')
        (root / 'linked-folder').symlink_to(root / 'complete', target_is_directory=True)
        linked = root / 'linked-config'
        linked.mkdir()
        (linked / 'project.env').symlink_to(root / 'complete/project.env')
        result = self.run_generation(
            'projects_template_devops() { printf "called:%s\\n" "$1"; }',
            projects_root=root, batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(re.findall(r'^called:(.*)$', result.stdout, re.M), ['complete'])
        self.assertIn('1 sélectionné(s), 1 réussi(s), 4 ignoré(s), 0 échoué(s)', result.stdout)
        self.assertFalse(marker.exists())
        self.assertNotIn('test-only-not-to-display', result.stdout + result.stderr)
        self.assertNotIn(str(marker), result.stdout + result.stderr)

    def test_batch_continues_after_failure_and_returns_failed_summary(self):
        root = self.fixture / 'projects'
        self.configured_project(root, 'a-failure')
        self.configured_project(root, 'b-success')
        extra = r'''
projects_template_devops() {
    printf 'called:%s\n' "$1"
    [[ "$1" != a-failure ]]
}
'''
        result = self.run_generation(extra, projects_root=root, batch=True)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(re.findall(r'^called:(.*)$', result.stdout, re.M),
                         ['a-failure', 'b-success'])
        self.assertIn('2 sélectionné(s), 1 réussi(s), 0 ignoré(s), 1 échoué(s)', result.stdout)
        self.assertIn('Génération DevOps échouée pour le projet : a-failure', result.stderr)

    def test_batch_empty_missing_and_unreadable_configurations_are_explicit(self):
        root = self.fixture / 'projects'
        result = self.run_generation(projects_root=root, batch=True)
        self.assertEqual(result.returncode, 1)
        self.assertFalse(root.exists())
        root.mkdir()
        result = self.run_generation(projects_root=root, batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Aucun projet éligible', result.stdout)
        self.assertIn('0 sélectionné(s), 0 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)
        (root / 'absent').mkdir()
        malformed = self.configured_project(root, 'malformed')
        (malformed / 'project.env').write_text('PROJECT_ID="unterminated\n')
        invalid = self.configured_project(root, 'invalid-encoding')
        (invalid / 'project.env').write_bytes(b'PROJECT_ID=\xff\n')
        ignored = 3
        # Root peut lire un fichier de mode 000 : le cas de permissions est
        # vérifié uniquement lorsque ces permissions peuvent être effectives.
        if os.geteuid() != 0:
            unreadable = self.configured_project(root, 'unreadable')
            (unreadable / 'project.env').chmod(0)
            self.addCleanup((unreadable / 'project.env').chmod, 0o600)
            ignored += 1
        result = self.run_generation(projects_root=root, batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'0 sélectionné(s), 0 réussi(s), {ignored} ignoré(s), 0 échoué(s)', result.stdout)

    def test_batch_generates_real_documents_and_preserves_them_on_repeat(self):
        self.environment['ENV_DEVOPS_TESTS_LXC'] = '1'
        self.configure_tpm()
        root = self.fixture / 'projects'
        before = {}
        for project, project_type in (('template', 'NODE'), ('all', 'NODE'), ('python-app', 'PYTHON')):
            path = self.configured_project(root, project, {'PROJECT_TYPE': project_type})
            (path / 'frontend').mkdir()
            (path / 'frontend/package.json').write_text(
                json.dumps({'dependencies': {'batch-fixture': '1.0.0'}}), encoding='utf-8')
            with (path / 'project.env').open('a') as stream:
                stream.write((self.template / 'project.env').read_text())
        for iteration in range(2):
            result = self.run_generation(projects_root=root, batch=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('3 sélectionné(s), 3 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)
            for project in ('template', 'all', 'python-app'):
                path = root / project
                content = (path / 'DEVOPS.md').read_bytes()
                self.assertIn(b'Version : 0.7\n', content)
                self.assert_test_container_sections(content.decode('utf-8'), True, True)
                self.assertIn(b'  * hvp1.pixs.fr\n', content)
                self.assert_prompts_section(content.decode('utf-8'))
                self.assertEqual(content.count('## Dépendances JavaScript du projet\n'.encode()), 1)
                self.assertIn(b'batch-fixture : d\xc3\xa9clar\xc3\xa9e 1.0.0', content)
                self.assertIn('Début du relevé (UTC) : 2026-10-09T06:30:00Z\n'.encode(), content)
                self.assertEqual(content.count('Généré automatiquement par Debian Installeur Unifié (DIU).'.encode()), 1)
                self.assertIn(b'16.4', content)
                self.assertIn(b'PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD', content)
                self.assertIn('# Tests navigateurs extérieurs en mode headless\n'.encode(), content)
                self.assertIn(b'## Chromium\n\n  * 134.0.6998.88', content)
                self.assertIn(b'## Firefox\n\n  * 140.0.4esr', content)
                self.assertEqual(content.count('# Matériel\n'.encode()), 1)
                self.assertIn(b'Fabricant : IFX\n', content)
                if iteration:
                    self.assertEqual(content, before[project])
                before[project] = content
                self.assertEqual((path / 'pyproject.toml').exists(), project == 'python-app')
        self.assertEqual(tomllib.loads((root / 'python-app/pyproject.toml').read_text())['project'],
                         {'name': 'python-app', 'version': '0.0.0', 'dependencies': []})
        self.assertFalse(self.document.exists())

    def test_batch_default_root_arguments_and_user_validation(self):
        with (self.template / 'project.env').open('a') as stream:
            stream.write('PROJECT_ID=template\nPROJECT_NAME=Template\nPROJECT_TYPE=NODE\n'
                         'PROJECT_DOCKERED=No\nPROJECT_DEBIAN_PACKAGE=No\n')
        extra = 'projects_template_devops() { printf "called:%s\\n" "$1"; }'
        result = self.run_generation(extra, batch=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(re.findall(r'^called:(.*)$', result.stdout, re.M), ['template'])
        result = self.run_generation(extra, batch=True, arguments=('extra',))
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('called:', result.stdout)
        for user in ('', '../other'):
            result = self.run_generation(extra, user=user, batch=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('called:', result.stdout)


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

    def test_prompts_paths_follow_configured_user_with_separate_projects_root(self):
        # Conserver le calcul réel du domicile et le rendu. Isoler seulement
        # les identités, la préparation des outils et les sondes : le domicile
        # calculé sert ici aux assertions de chemins, jamais à une mutation réelle.
        script = r'''
source "$1"
ENV_DEVOPS_USER="$2"
DEVOPS_PROJECTS_ROOT="$3"
id() {
    case "$1" in
        -u) printf '1234\n' ;;
        -un) printf '%s\n' "$ENV_DEVOPS_USER" ;;
        *) return 99 ;;
    esac
}
print_error() { printf '%s\n' "$*" >&2; }
print_success() { :; }
projects_template_devops_python_manifest() { :; }
projects_template_devops_timestamp() { printf '2026-10-19T06:30:00Z\n'; }
projects_template_devops_prepare_executables() { :; }
projects_template_devops_host_binary() { return 1; }
projects_template_devops_version() { printf 'indisponible\n'; }
projects_template_devops_user_run() { return 1; }
projects_template_devops_javascript() { printf '\034'; }
projects_template_devops_dependencies() { printf '  * manifeste absent\n'; }
projects_template_devops_postgresql() { printf '  * indisponible\n'; }
projects_template_devops application
'''
        projects_root = self.fixture / 'separate projects'
        target = projects_root / 'application'
        target.mkdir(parents=True)
        document = target / 'DEVOPS.md'
        document.write_text('Ancien relevé\n', encoding='utf-8')
        for user in ('devops', 'ci-builder'):
            with self.subTest(user=user):
                result = subprocess.run(
                    ['bash', '-Eeuo', 'pipefail', '-c', script, 'bash', str(MODULE),
                     user, str(projects_root)], env=self.environment, text=True,
                    capture_output=True, timeout=10, check=False,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                content = document.read_text(encoding='utf-8')
                self.assertEqual(content.count('# Prompts\n'), 1)
                self.assertIn(f'# Prompts\n\n  * Dossier des prompts : /home/{user}/datas/prompts\n'
                              f'  * Index des prompts : /home/{user}/datas/prompts/INDEX.md\n', content)
                self.assertNotIn(str(projects_root / 'prompts'), content)
                self.assertIn('Version : 0.7\n', content)

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
