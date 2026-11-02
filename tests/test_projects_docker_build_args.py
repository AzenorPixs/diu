#!/usr/bin/env python3
"""Construction sur fixtures : aucun compte, Docker ou fichier réel utilisé."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DockerBuildArgs(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='docker-args-', dir=ROOT / 'tests')
        self.addCleanup(self.temporary.cleanup)
        self.lab = Path(self.temporary.name)
        self.project = self.lab / 'projects' / 'fixture'
        self.project.mkdir(parents=True)
        self.build = self.project / 'build'
        self.build.mkdir()
        self.arguments = self.build / 'docker-build.args'
        self.capture = self.lab / 'docker.capture'
        self.module = self.lab / 'docker.sh'
        source = (ROOT / 'modules/projects/docker.sh').read_text()
        # Le module déplacé conserve la même dépendance publique au lecteur de version.
        source = source.replace(
            '. "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/project-version.sh"',
            f'. "{ROOT / "lib/project-version.sh"}"', 1)
        # Rebaser seulement le chemin historique, sans toucher au lecteur testé.
        old = 'project_dir="/home/${DEVOPS_USER}/datas/${project_id}"'
        self.assertEqual(source.count(old), 1)
        self.module.write_text(source.replace(old, 'project_dir="${FIXTURE_ROOT}/${project_id}"'))
        (self.project / 'project.env').write_text('PROJECT_ID=artifact-fixture\nPROJECT_NAME=Fixture\nPROJECT_DOCKERED=1\n')
        (self.project / 'dockerfile').write_text('# fixture\n')
        (self.project / 'entrypoint.sh').write_text('#!/bin/sh\n')

    def run_build(self, content=None, *, status=0, extra='', entrypoint='projects_docker_build fixture'):
        if content is not None:
            self.arguments.write_bytes(content)
        script = r'''
set -euo pipefail
source "$1"
runuser() { printf '%s\0' "$@" > "$USER_CAPTURE"; shift 3; "$@"; }
docker() { printf '%s\0' "$@" > "$CAPTURE"; return "$DOCKER_STATUS"; }
DEVOPS_USER=fixture-user
'''+extra+'\n'+entrypoint+'\n'
        return subprocess.run(['bash', '-c', script, 'fixture', str(self.module)], capture_output=True, timeout=10,
            env={'PATH': os.defpath, 'FIXTURE_ROOT': str(self.project.parent), 'CAPTURE': str(self.capture),
                 'USER_CAPTURE': str(self.lab / 'user.capture'), 'DOCKER_STATUS': str(status),
                 'FIXTURE_GIT_MODULE': str(ROOT / 'modules/projects/git.sh'),
                 'ARGS_PATH': str(self.arguments), 'FICTION_ENV_SECRET': 'fiction-environment-value'})

    def captured(self):
        return self.capture.read_bytes().split(b'\0')[:-1]

    def base(self):
        return [b'build', b'--file', str(self.project / 'dockerfile').encode(), b'--tag', b'artifact-fixture:latest']

    def assert_refused(self, result):
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.capture.exists())
        self.assertNotIn(b'fiction-sensitive-marker', result.stdout + result.stderr)
        self.assertNotIn('✅'.encode(), result.stdout + result.stderr)

    def test_absent_keeps_original_command_and_user(self):
        result = self.run_build()
        self.assertEqual(result.returncode, 0, result.stderr.decode())
        self.assertEqual(self.captured(), self.base() + [str(self.project).encode()])
        user = (self.lab / 'user.capture').read_bytes().split(b'\0')[:-1]
        self.assertEqual(user[:4], [b'-u', b'fixture-user', b'--', b'docker'])

    def test_empty_and_comment_only_files(self):
        for content in (b'', b'\n \t\n  # ignored\n# second\n'):
            with self.subTest(content=content):
                result = self.run_build(content)
                self.assertEqual(result.returncode, 0)
                self.assertEqual(self.captured(), self.base() + [str(self.project).encode()])

    def test_literal_values_and_no_execution(self):
        marker = self.lab / 'must-not-exist'
        lines = ['VERSION=1.2.3', 'EMPTY=', 'SPACES=  before and after  ', 'EQUAL=a=b=c',
                 'DOLLAR=$FICTION_ENV_SECRET', 'QUOTE="literal"', 'HASH=a#b', r'BACKSLASH=a\b\\c',
                 'UNICODE=été', f'COMMAND=$(touch {marker}); `touch {marker}`']
        content = ('\n'.join(lines) + '\n').encode()
        result = self.run_build(content)
        self.assertEqual(result.returncode, 0, result.stderr.decode())
        expected = self.base()
        for line in lines:
            expected += [b'--build-arg', line.encode()]
        self.assertEqual(self.captured(), expected + [str(self.project).encode()])
        self.assertFalse(marker.exists())
        self.assertEqual(self.arguments.read_bytes(), content)
        self.assertNotIn(b'fiction-environment-value', result.stdout + result.stderr)

    def test_last_line_without_newline(self):
        result = self.run_build(b'OPTION=value')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.captured()[-3:], [b'--build-arg', b'OPTION=value', str(self.project).encode()])

    def test_invalid_key_or_missing_equals(self):
        for content in (b'NO_EQUALS', b'=fiction-sensitive-marker', b'1NAME=fiction-sensitive-marker',
                        b' NAME=fiction-sensitive-marker', b'export NAME=fiction-sensitive-marker',
                        'ÉTÉ=fiction-sensitive-marker'.encode(), b'--flag=fiction-sensitive-marker'):
            with self.subTest(case=content.split(b'=')[0]):
                self.assert_refused(self.run_build(content))

    def test_duplicate_is_rejected_before_any_build(self):
        self.assert_refused(self.run_build(b'FIRST=accepted\nFIRST=fiction-sensitive-marker\n'))

    def test_case_distinct_keys(self):
        result = self.run_build(b'KEY=one\nkey=two\n')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.captured()[-5:], [b'--build-arg', b'KEY=one', b'--build-arg', b'key=two', str(self.project).encode()])

    def test_nul_and_cr_even_in_comments(self):
        for content in (b'A=valid\n# fiction-sensitive-marker\x00\n', b'# fiction-sensitive-marker\r\n', b'A=v\r'):
            with self.subTest(octet=content[-2:]):
                self.assert_refused(self.run_build(content))

    def test_size_boundary_and_oversize(self):
        result = self.run_build(b'A=' + b'x' * 65533 + b'\n')
        self.assertEqual(result.returncode, 0)
        self.capture.unlink()
        self.assert_refused(self.run_build(b'A=' + b'x' * 65534 + b'\n'))

    def test_symbolic_file_is_rejected_and_target_preserved(self):
        target = self.lab / 'public-fixture.txt'
        target.write_text('A=fiction-sensitive-marker\n')
        self.arguments.symlink_to(target)
        self.assert_refused(self.run_build())
        self.assertEqual(target.read_text(), 'A=fiction-sensitive-marker\n')

    def test_symbolic_build_directory_is_rejected(self):
        self.build.rmdir()
        target = self.lab / 'alternate'
        target.mkdir()
        (target / 'docker-build.args').write_text('A=fiction-sensitive-marker\n')
        self.build.symlink_to(target, target_is_directory=True)
        self.assert_refused(self.run_build())

    def test_dangling_link_directory_and_fifo_are_rejected(self):
        self.arguments.symlink_to(self.lab / 'missing')
        self.assert_refused(self.run_build())
        self.arguments.unlink()
        self.arguments.mkdir()
        self.assert_refused(self.run_build())
        self.arguments.rmdir()
        os.mkfifo(self.arguments)
        self.assert_refused(self.run_build())

    def test_read_and_metadata_errors_block_build(self):
        self.assert_refused(self.run_build(b'A=public\n', extra='read() { return 2; }'))
        self.assert_refused(self.run_build(b'A=public\n', extra='stat() { return 1; }'))

    def test_existing_controls_remain_prioritary(self):
        (self.project / 'project.env').write_text('PROJECT_DOCKERED=No\n')
        result = self.run_build(b'fiction-sensitive-marker')
        self.assert_refused(result)
        self.assertIn('Dockerisé'.encode(), result.stdout)
        (self.project / 'project.env').write_text('PROJECT_DOCKERED=1\n')
        (self.project / 'entrypoint.sh').unlink()
        result = self.run_build()
        self.assert_refused(result)
        self.assertIn(b'Entrypoint introuvable', result.stdout)

    def test_docker_failure_is_not_success(self):
        result = self.run_build(b'A=public\n', status=7)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(self.capture.exists())
        self.assertNotIn('✅'.encode(), result.stdout)

    def test_cicd_flow_uses_arguments_with_all_external_actions_simulated(self):
        (self.project / 'project.env').write_text('PROJECT_ID=artifact-fixture\nPROJECT_NAME=Fixture\nPROJECT_DOCKERED=Yes\n')
        script = r'''
source "$FIXTURE_GIT_MODULE"
DEVOPS_PROJECTS_ROOT="$FIXTURE_ROOT"
print_error() { printf '%s\n' "$1" >&2; }
print_title() { :; }
git_commit() { return 0; }
runuser() {
    if [[ ${4:-} == git ]]; then return 0; fi
    printf '%s\0' "$@" > "$USER_CAPTURE"
    shift 3
    "$@"
}
forgejo_push() { return 99; }
gitlab_push() { return 99; }
github_push() { return 99; }
projects_forgejo_release() { return 99; }
projects_gitlab_release() { return 99; }
projects_github_release() { return 99; }
cicd_project fixture fixture-version v1.2.3
'''
        # Seule cette entrée de test charge les fonctions, jamais leurs configurations.
        result = self.run_build(b'RELEASE_ID=1.2.3\n', entrypoint=script)
        self.assertEqual(result.returncode, 0, result.stderr.decode())
        self.assertEqual(self.captured()[-3:], [b'--build-arg', b'RELEASE_ID=1.2.3', str(self.project).encode()])

    def test_parser_is_transactional_and_closes_descriptors(self):
        self.arguments.write_text('A=one\nA=two\n')
        script = r'''
set -euo pipefail
source "$1"
args=(initial)
if projects_docker_load_build_args "$2" args; then exit 10; fi
[[ ${#args[@]} == 0 ]]
printf 'A=one\n' > "$2/build/docker-build.args"
before=(/proc/$$/fd/*)
for ((i=0; i<100; i++)); do projects_docker_load_build_args "$2" args; done
after=(/proc/$$/fd/*)
[[ ${#before[@]} == ${#after[@]} && ${#args[@]} == 2 ]]
'''
        result = subprocess.run(['bash', '-c', script, 'fixture', str(self.module), str(self.project)],
                                capture_output=True, timeout=10, env={'PATH': os.defpath})
        self.assertEqual(result.returncode, 0, result.stderr.decode())


if __name__ == '__main__':
    unittest.main(verbosity=2)
