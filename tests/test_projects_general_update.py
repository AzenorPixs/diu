#!/usr/bin/env python3
"""Mise à jour générale des projets sans opération système ou projet réel."""
import getpass
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ENTRYPOINT = ROOT / 'root-install-debian.sh'


class ProjectsGeneralUpdateTests(unittest.TestCase):
    def run_shell(self, script, *arguments, **environment):
        return subprocess.run(
            ['bash', '-Eeuo', 'pipefail', '-c', script, 'bash', *arguments],
            env=dict(os.environ, TEST_ROOT=str(ROOT), **environment),
            text=True, capture_output=True, timeout=30, check=False,
        )

    def project_dispatch(self):
        source = ENTRYPOINT.read_text(encoding='utf-8')
        return re.search(r'^manage_project_action\(\) \{\n.*?^\}', source, re.M | re.S)[0]

    def test_projects_update_delegates_once_and_preserves_return_status(self):
        script = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
projects_template_all_all() { printf 'models:%s\n' "$#"; return "$TEST_STATUS"; }
print_error() { printf '%s\n' "$*" >&2; }
projects_update
'''
        for status in ('0', '7'):
            with self.subTest(status=status):
                result = self.run_shell(script, TEST_STATUS=status)
                self.assertEqual(result.returncode, int(status), result.stderr)
                self.assertEqual(result.stdout, 'models:0\n')

    def test_projects_update_rejects_arguments_before_models(self):
        script = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
projects_template_all_all() { printf 'models\n'; }
print_error() { printf '%s\n' "$*" >&2; }
projects_update "$@"
'''
        for arguments in (('application',), ('',), ('all', 'extra')):
            result = self.run_shell(script, *arguments)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, '')
            self.assertIn('Usage : rid projects update', result.stderr)

    def test_dispatch_distinguishes_general_and_targeted_updates(self):
        script = self.project_dispatch() + r'''
projects_update() { printf 'general:%s\n' "$#"; }
update_projects() { printf 'target:%s:%s\n' "$#" "$1"; }
rid_display_command_error() { printf 'help:%s\n' "$*"; }
manage_project_action "$@"
'''
        cases = ((('update',), 0, 'general:0\n'),
                 (('update', 'application'), 0, 'target:1:application\n'),
                 (('update', 'all'), 0, 'target:1:all\n'),
                 (('update', 'project with spaces'), 0, 'target:1:project with spaces\n'),
                 (('update', ''), 2, 'help:projects update'),
                 (('update', 'application', 'extra'), 2, 'help:projects update'))
        for arguments, status, expected in cases:
            with self.subTest(arguments=arguments):
                result = self.run_shell(script, *arguments)
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertIn(expected, result.stdout)
                if status:
                    self.assertNotIn('general:', result.stdout)
                    self.assertNotIn('target:', result.stdout)

    def test_dispatch_transmits_general_and_targeted_failures(self):
        script = self.project_dispatch() + r'''
projects_update() { return 7; }
update_projects() { return 8; }
manage_project_action "$@"
'''
        self.assertEqual(self.run_shell(script, 'update').returncode, 7)
        self.assertEqual(self.run_shell(script, 'update', 'application').returncode, 8)

    def test_global_order_and_failure_propagation(self):
        script = r'''
source "$TEST_ROOT/modules/projects/projects.sh"
source "$TEST_ROOT/modules/diu/update-all.sh"
system_update() { printf 'system\n'; }
diu_update() { printf 'diu\n'; }
environments_update() { printf 'environments\n'; }
ia_update() { printf 'ia\n'; }
projects_template_all_all() { printf 'models:%s\n' "$#"; return "$TEST_PROJECTS_STATUS"; }
softwares_update() { printf 'softwares\n'; return "$TEST_SOFTWARES_STATUS"; }
manage_update_action
'''
        for projects, softwares, expected in (('0', '0', 0), ('7', '0', 7),
                                              ('0', '5', 5), ('7', '5', 7)):
            with self.subTest(projects=projects, softwares=softwares):
                result = self.run_shell(script, TEST_PROJECTS_STATUS=projects,
                                        TEST_SOFTWARES_STATUS=softwares)
                self.assertEqual(result.returncode, expected, result.stderr)
                self.assertEqual(result.stdout.splitlines(),
                                 ['diu', 'system', 'environments', 'ia', 'models:0', 'softwares'])

    def test_global_update_reports_diu_failure_after_other_modules(self):
        script = r"""
source "$TEST_ROOT/modules/diu/update-all.sh"
diu_update() { printf 'diu\n'; return 7; }
system_update() { printf 'system\n'; }
environments_update() { printf 'environments\n'; }
ia_update() { printf 'ia\n'; }
projects_update() { printf 'projects\n'; }
softwares_update() { printf 'softwares\n'; }
manage_update_action
"""
        result = self.run_shell(script)
        self.assertEqual(result.returncode, 7, result.stderr)
        self.assertEqual(result.stdout.splitlines(),
                         ['diu', 'system', 'environments', 'ia', 'projects', 'softwares'])

    def test_explicit_diu_and_software_updates_do_not_update_projects(self):
        script = r'''
source "$TEST_ROOT/modules/diu/update-all.sh"
projects_update() { printf 'unexpected-projects\n'; return 90; }
diu_update() { printf 'diu-only\n'; }
manage_software_action() { printf 'software:%s\n' "$*"; }
manage_update_action "$@"
'''
        for arguments, expected in ((('diu',), 'diu-only\n'),
                                    (('apt', 'example'), 'software:update apt example\n'),
                                    (('github',), 'software:update github\n')):
            result = self.run_shell(script, *arguments)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, expected)

    def test_diu_update_dispatch(self):
        source = ENTRYPOINT.read_text(encoding='utf-8')
        dispatch = re.search(r'^dispatch_arguments\(\) \{\n.*?^\}', source, re.M | re.S)[0]
        script = dispatch + r"""
diu_update() { printf 'diu-only\n'; return 6; }
dispatch_arguments "$@"
"""
        result = self.run_shell(script, 'diu', 'update')
        self.assertEqual(result.returncode, 6, result.stderr)
        self.assertEqual(result.stdout, 'diu-only\n')
        result = self.run_shell(script, 'diu', 'update', '1.1.7')
        self.assertEqual(result.returncode, 6, result.stderr)
        self.assertEqual(result.stdout, 'diu-only\n')
        result = self.run_shell(script, 'diu', 'update', '1.1.7', 'extra')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertNotIn('diu-only', result.stdout)

    def test_public_dispatch_preserves_failure_codes_and_stops_installation(self):
        source = ENTRYPOINT.read_text(encoding='utf-8')
        dispatch = re.search(r'^dispatch_arguments\(\) \{\n.*?^\}', source, re.M | re.S)[0]
        script = dispatch + '\n' + self.project_dispatch() + r'''
source "$TEST_ROOT/modules/projects/projects.sh"
source "$TEST_ROOT/modules/diu/update-all.sh"
system_update() { :; }
diu_update() { :; }
environments_update() { :; }
ia_update() { :; }
projects_template_all_all() { printf 'models\n'; return "$TEST_STATUS"; }
softwares_update() { printf 'softwares\n'; }
dispatch_arguments "$@"
printf 'UNEXPECTED-INSTALLATION\n'
'''
        for arguments in (('projects', 'update'), ('update',)):
            for status in ('0', '7'):
                with self.subTest(arguments=arguments, status=status):
                    result = self.run_shell(script, *arguments, TEST_STATUS=status)
                    self.assertEqual(result.returncode, int(status), result.stderr)
                    self.assertEqual(result.stdout.count('models\n'), 1)
                    self.assertEqual('softwares\n' in result.stdout, arguments == ('update',))
                    self.assertNotIn('UNEXPECTED-INSTALLATION', result.stdout)

    def test_real_general_path_reuses_selection_order_and_counts(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-update-') as temporary:
            projects = Path(temporary)
            for name in ('application', 'all', '.hidden', 'z-failing'):
                project = projects / name
                project.mkdir()
                (project / 'project.env').write_text(
                    f'PROJECT_ID={shlex.quote(name)}\nPROJECT_NAME=Example\nPROJECT_TYPE=NODE\n'
                    'PROJECT_DOCKERED=0\nPROJECT_DEBIAN_PACKAGE=No\n', encoding='utf-8')
            (projects / 'ignored').mkdir()
            script = self.project_dispatch() + r'''
source "$TEST_ROOT/modules/projects/template.sh"
source "$TEST_ROOT/modules/projects/projects.sh"
print_error() { printf '%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
projects_template_openspec() {
    printf 'openspec:%s\n' "$1"
    [[ "$1" != z-failing ]]
}
projects_template_devops() { printf 'devops:%s\n' "$1"; }
manage_project_action update
'''
            result = self.run_shell(script, ENV_DEVOPS_USER=getpass.getuser(),
                                    ENV_DEVOPS_PROJECTS_ROOT=str(projects))
            self.assertEqual(result.returncode, 1, result.stderr)
            calls = [line for line in result.stdout.splitlines()
                     if line.startswith(('openspec:', 'devops:'))]
            self.assertEqual(calls, ['openspec:all', 'devops:all',
                                     'openspec:application', 'devops:application',
                                     'openspec:z-failing', 'openspec:.hidden', 'devops:.hidden'])
            self.assertIn('4 sélectionné(s), 3 réussi(s), 1 ignoré(s), 1 échoué(s)', result.stdout)
            self.assertIn('DevOps non exécuté', result.stderr)

    def test_empty_selection_succeeds_through_projects_update(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-update-') as temporary:
            script = r'''
source "$TEST_ROOT/modules/projects/template.sh"
source "$TEST_ROOT/modules/projects/projects.sh"
print_error() { printf '%s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
projects_template_openspec() { printf 'unexpected-model\n'; return 90; }
projects_template_devops() { printf 'unexpected-model\n'; return 90; }
projects_update
'''
            result = self.run_shell(script, ENV_DEVOPS_USER=getpass.getuser(),
                                    ENV_DEVOPS_PROJECTS_ROOT=temporary)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('Aucun projet éligible', result.stdout)
            self.assertIn('0 sélectionné(s), 0 réussi(s), 0 ignoré(s), 0 échoué(s)', result.stdout)
            self.assertNotIn('unexpected-model', result.stdout)


if __name__ == '__main__':
    unittest.main()
