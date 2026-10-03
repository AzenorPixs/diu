#!/usr/bin/env python3
"""Tous les modèles par projet, avec données et opérations externes isolées."""
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest

import test_projects_template_devops as devops_fixture


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / 'modules/projects/template.sh'


class ProjectsTemplateAllTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-all-')
        self.addCleanup(self.temporary.cleanup)
        self.fixture = Path(self.temporary.name)
        self.projects = self.fixture / 'home/datas'
        self.projects.mkdir(parents=True)
        self.events = self.fixture / 'events'
        self.environment = dict(os.environ, ENV_DEVOPS_USER='devops-test', OPENCODE='1',
                                DEVOPS_PROJECTS_ROOT=str(self.projects),
                                TEST_EVENTS=str(self.events), TEST_ID_FAILURE='0',
                                TEST_DEVOPS_HOME=str(self.projects.parent))

    def configured_project(self, name):
        project = self.projects / name
        project.mkdir(exist_ok=True)
        (project / 'project.env').write_text(
            f'PROJECT_ID={shlex.quote(name)}\nPROJECT_NAME=Example\nPROJECT_TYPE=NODE\n'
            'PROJECT_DOCKERED=0\nPROJECT_DEBIAN_PACKAGE=No\n', encoding='utf-8')
        return project

    def run_models(self, *arguments, extra='', real_openspec=False):
        source = MODULE.read_text(encoding='utf-8')
        assignment = 'local devops_home="/home/${ENV_DEVOPS_USER:-}"'
        self.assertEqual(source.count(assignment), 4)
        source = source.replace(assignment, 'local devops_home="$TEST_DEVOPS_HOME"')
        script = source + r'''
print_error() { printf '%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
print_success() { printf '%s\n' "$*"; }
id() {
    if [[ "$1" == -un ]]; then
        printf '%s\n' "${TEST_CURRENT_USER:-$ENV_DEVOPS_USER}"
    else
        [[ "$TEST_ID_FAILURE" == 0 ]]
    fi
}
projects_template_openspec_all() { return 90; }
projects_template_devops_all() { return 90; }
projects_template_devops() {
    printf 'devops:%s\n' "$1" >> "$TEST_EVENTS"
    [[ "$1" != "${TEST_DEVOPS_FAILED_PROJECT:-}" ]] || return 7
    printf 'prepared\n' > "${DEVOPS_PROJECTS_ROOT:-$TEST_DEVOPS_HOME/datas}/$1/DEVOPS.md"
}
'''
        if not real_openspec:
            script += r'''
projects_template_openspec() {
    printf 'openspec:%s\n' "$1" >> "$TEST_EVENTS"
    [[ "$1" != "${TEST_OPENSPEC_FAILED_PROJECT:-}" ]] || return 7
}
'''
        result = subprocess.run(['bash', '-Eeuo', 'pipefail', '-c',
                                 script + extra + '\nprojects_template_all_all "$@"',
                                 'bash', *arguments], env=self.environment,
                                text=True, capture_output=True, timeout=30, check=False)
        return result

    def calls(self):
        return self.events.read_text().splitlines() if self.events.exists() else []

    def test_order_is_per_project_including_all_hidden_and_special_names(self):
        names = ('all', 'template', '.hidden', '..double', "project d'essai $PATH")
        for name in names:
            self.configured_project(name)
        result = self.run_models()
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        self.assertEqual(len(calls), 10)
        observed = set()
        for index in range(0, len(calls), 2):
            name = calls[index].removeprefix('openspec:')
            self.assertEqual(calls[index], f'openspec:{name}')
            self.assertEqual(calls[index + 1], f'devops:{name}')
            observed.add(name)
        self.assertEqual(observed, set(names))
        self.assertIn('5 sélectionné(s), 5 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)

    def test_selection_matches_existing_groups_without_execution_or_inheritance(self):
        complete = self.configured_project('complete')
        nested = complete / 'nested'
        nested.mkdir()
        for name in ('missing', 'blank', 'wrong', 'expression', 'unreadable', 'bad\nname'):
            project = self.configured_project(name)
            config = project / 'project.env'
            if name == 'missing':
                config.write_text('PROJECT_ID=missing\n')
            elif name == 'blank':
                with config.open('a') as stream:
                    stream.write('PROJECT_TYPE=""\n')
            elif name == 'wrong':
                with config.open('a') as stream:
                    stream.write('PROJECT_ID=another\n')
            elif name == 'expression':
                with config.open('a') as stream:
                    stream.write(f'PROJECT_NAME=$(touch {self.fixture}/executed)\n')
            elif name == 'unreadable':
                config.chmod(0)
        with (complete / 'project.env').open('a') as stream:
            stream.write(f'touch {self.fixture}/executed\n')
        (self.projects / 'linked-project').symlink_to(complete, target_is_directory=True)
        linked_env = self.projects / 'linked-env'
        linked_env.mkdir()
        (linked_env / 'project.env').symlink_to(complete / 'project.env')
        self.environment.update(PROJECT_ID='missing', PROJECT_NAME='Inherited',
                                PROJECT_TYPE='NODE', PROJECT_DOCKERED='1', PROJECT_DEBIAN_PACKAGE='Yes')
        result = self.run_models()
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = ['openspec:complete', 'devops:complete']
        # Root peut lire un fichier de mode zéro ; la suite sous devops couvre le refus réel.
        if os.geteuid() == 0:
            expected += ['openspec:unreadable', 'devops:unreadable']
        self.assertEqual(self.calls(), expected)
        self.assertFalse((self.fixture / 'executed').exists())
        self.assertFalse((nested / 'DEVOPS.md').exists())
        self.assertNotIn('Inherited', result.stdout + result.stderr)

    def test_each_failure_is_counted_once_and_next_project_runs(self):
        for name in ('a-openspec-failure', 'b-devops-failure', 'z-success'):
            project = self.configured_project(name)
            (project / 'DEVOPS.md').write_text('kept\n')
        self.environment.update(TEST_OPENSPEC_FAILED_PROJECT='a-openspec-failure',
                                TEST_DEVOPS_FAILED_PROJECT='b-devops-failure')
        result = self.run_models()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls(), ['openspec:a-openspec-failure',
                                       'openspec:b-devops-failure', 'devops:b-devops-failure',
                                       'openspec:z-success', 'devops:z-success'])
        self.assertIn('3 sélectionné(s), 1 réussi(s), 0 ignoré(s), 2 échoué(s)', result.stdout)
        self.assertIn('DevOps non exécuté', result.stderr)
        for name in ('a-openspec-failure', 'b-devops-failure'):
            self.assertEqual((self.projects / name / 'DEVOPS.md').read_text(), 'kept\n')

    def test_empty_or_ineligible_projects_return_success_without_models(self):
        for count in (0, 1):
            if count:
                (self.projects / 'incomplete').mkdir()
            result = self.run_models()
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.calls(), [])
            self.assertIn('Aucun projet éligible', result.stdout)
            self.assertIn(f'0 sélectionné(s), 0 réussi(s), {count} ignoré(s), 0 échoué(s)', result.stdout)

    def test_prerequisites_fail_before_any_model(self):
        self.configured_project('application')
        self.assertNotEqual(self.run_models('extra').returncode, 0)
        for name in ('', '-bad', 'bad user'):
            self.environment['ENV_DEVOPS_USER'] = name
            self.assertNotEqual(self.run_models().returncode, 0)
        self.environment['ENV_DEVOPS_USER'] = 'devops-test'
        self.environment['TEST_ID_FAILURE'] = '1'
        self.assertNotEqual(self.run_models().returncode, 0)
        self.environment['TEST_ID_FAILURE'] = '0'
        if os.geteuid() != 0:
            self.environment['TEST_CURRENT_USER'] = 'another-user'
            self.assertNotEqual(self.run_models().returncode, 0)
            self.environment.pop('TEST_CURRENT_USER')
        self.environment['DEVOPS_PROJECTS_ROOT'] = str(self.fixture / 'missing')
        self.assertNotEqual(self.run_models().returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_default_root_uses_the_same_selection(self):
        self.configured_project('application')
        self.environment.pop('DEVOPS_PROJECTS_ROOT')
        result = self.run_models()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), ['openspec:application', 'devops:application'])

    def test_real_openspec_branches_and_su_user_before_devops(self):
        for opencode, expected in (('0', 'init --profile custom'),
                                  ('1', 'init --tools opencode --profile custom')):
            project = self.configured_project(f'app-{opencode}')
            self.environment['OPENCODE'] = opencode
            extra = r'''
su() {
    [[ "$#" == 4 && "$1" == - && "$2" == "$ENV_DEVOPS_USER" && "$3" == -c ]] || return 90
    bash -c 'openspec() {
        printf "openspec:%s:%s\n" "${PWD##*/}" "$*" >> "$TEST_EVENTS"
        if [[ "$1" == init ]]; then mkdir openspec; fi
    }; eval "$1"' bash "$4"
}
projects_template_devops() {
    [[ -d "$DEVOPS_PROJECTS_ROOT/$1/openspec" ]] || return 91
    printf 'devops:%s\n' "$1" >> "$TEST_EVENTS"
}
'''
            result = self.run_models(real_openspec=True, extra=extra)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((project / 'openspec').is_dir())
            self.assertEqual(self.calls()[-2:], [f'openspec:app-{opencode}:{expected}', f'devops:app-{opencode}'])
            result = self.run_models(real_openspec=True, extra=extra)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.calls()[-2:], [f'openspec:app-{opencode}:update', f'devops:app-{opencode}'])

    def test_real_devops_documents_are_generated_after_openspec(self):
        fixture = devops_fixture.ProjectsTemplateDevopsTests()
        fixture.setUp()
        self.addCleanup(fixture.doCleanups)
        for name in ('application', 'all'):
            fixture.configured_project(fixture.home / 'datas', name)
        result = fixture.run_generation(extra=r'''
projects_template_devops_all() { projects_template_all_all; }
projects_template_openspec() {
    mkdir -p "$TEST_DEVOPS_HOME/datas/$1/openspec"
}
''', batch=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for name in ('application', 'all'):
            project = fixture.home / 'datas' / name
            self.assertTrue((project / 'openspec').is_dir())
            content = (project / 'DEVOPS.md').read_text()
            self.assertIn(f'DEVOPS.md — {name}', content)
            self.assertIn('# OpenSpec\n\n  * 1.3.9', content)
        self.assertIn('2 sélectionné(s), 2 réussi(s), 1 ignoré(s), 0 échoué(s)', result.stdout)


if __name__ == '__main__':
    unittest.main()
