#!/usr/bin/env python3
"""Exceptions système Git testées sans modifier la configuration de la machine."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ProjectsGitSafeDirectoryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=ROOT, prefix='.diu-test-safe-git-')
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.projects = self.directory / 'projects'
        self.project = self.projects / 'projet avec espaces'
        self.project.mkdir(parents=True)
        self.system_config = self.directory / 'system.gitconfig'
        self.environment = {
            **{key: value for key, value in os.environ.items() if not key.startswith('GIT_')},
            'HOME': str(self.directory),
            'XDG_CONFIG_HOME': str(self.directory / 'xdg'),
            'GIT_CONFIG_GLOBAL': str(self.directory / 'global.gitconfig'),
            'GIT_CONFIG_SYSTEM': str(self.system_config),
        }
        self.write_project_configuration()

    def write_project_configuration(self, complete=True):
        (self.project / 'project.env').write_text(
            f'PROJECT_ID="{self.project.name}"\n'
            + ('PROJECT_NAME="Projet de test"\n' if complete else '')
            + 'LOCAL_DEFAULT_BRANCH=main\n'
            'GIT_USER_NAME="Compte de test"\n'
            'GIT_USER_EMAIL=git@example.test\n'
            'PROJECT_TYPE=test\n'
            'GITHUB_ENABLED=No\n',
            encoding='utf-8',
        )

    def git(self, *arguments, check=True):
        return subprocess.run(
            ['git', *arguments], cwd=self.directory, env=self.environment,
            text=True, capture_output=True, check=check,
        )

    def entries(self):
        result = self.git('config', '--system', '--null', '--get-all', 'safe.directory', check=False)
        self.assertIn(result.returncode, (0, 1), result.stderr)
        return result.stdout[:-1].split('\0') if result.stdout else []

    def add_entry(self, value):
        self.git('config', '--system', '--add', 'safe.directory', value)

    def shell(self, body, *, input_text=None, setup=''):
        script = '''
set -Eeuo pipefail
source "$1/modules/projects/projects.sh"
source "$1/modules/projects/git.sh"
ENV_DEVOPS_PROJECTS_ROOT="$2"
ENV_DEVOPS_USER=testdevops
DEVOPS_GROUP=testdevops
project_id="$3"
project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
print_title() { printf '%s\\n' "$*"; }
print_info() { printf '%s\\n' "$*"; }
print_success() { printf '%s\\n' "$*"; }
print_error() { printf '%s\\n' "$*" >&2; }
check_devops_user() { return 0; }
chown() { :; }
runuser() { shift 3; "$@"; }
update_projects() {
    printf 'PROJECT_ID="%s"\\nPROJECT_NAME="Projet de test"\\n' "$project_id" >> "$project_path/project.env"
}
'''
        return subprocess.run(
            ['bash', '-c', script + setup + '\n' + body, 'bash', str(ROOT),
             str(self.projects), self.project.name],
            cwd=self.directory, env=self.environment, input=input_text,
            text=True, capture_output=True, check=False,
        )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_ensure_adds_one_canonical_entry_and_preserves_other_rules(self):
        self.add_entry('/another/project')
        for _ in range(2):
            self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.entries(), ['/another/project', str(self.project)])

    def test_missing_system_file_is_created(self):
        self.assertFalse(self.system_config.exists())
        self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.entries(), [str(self.project)])

    def test_empty_value_resets_previous_exact_entry(self):
        self.add_entry(str(self.project))
        self.add_entry('')
        result = self.shell('git_safe_directory_system_status "$project_path"')
        self.assert_success(result)
        self.assertIn('absente (système', result.stdout)
        for _ in range(2):
            self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.entries(), [str(self.project), '', str(self.project)])

    def test_wildcard_does_not_replace_the_exact_entry(self):
        for value in ('*', str(self.projects) + '/*'):
            self.add_entry(value)
        result = self.shell('git_safe_directory_system_status "$project_path"')
        self.assert_success(result)
        self.assertIn('absente (système', result.stdout)
        self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.entries(), ['*', str(self.projects) + '/*', str(self.project)])

    def test_multiline_value_is_not_an_exact_entry(self):
        self.add_entry('/another/path\n' + str(self.project))
        result = self.shell('git_safe_directory_system_status "$project_path"')
        self.assert_success(result)
        self.assertIn('absente (système', result.stdout)

    def test_include_and_reset_order_are_respected(self):
        included = self.directory / 'included.gitconfig'
        included.write_text('[safe]\n\tdirectory =\n', encoding='utf-8')
        self.add_entry(str(self.project))
        self.git('config', '--system', '--add', 'include.path', str(included))
        before = self.system_config.read_bytes()
        for _ in range(2):
            result = self.shell('git_safe_directory_system_ensure "$project_path"')
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('réinitialise safe.directory', result.stderr)
            self.assertEqual(self.system_config.read_bytes(), before)
        result = self.shell('git_safe_directory_system_status "$project_path"')
        self.assert_success(result)
        self.assertIn('absente (système', result.stdout)

    def test_active_exact_entry_in_system_include_is_reused(self):
        included = self.directory / 'included.gitconfig'
        self.git('config', '--file', str(included), '--add', 'safe.directory', str(self.project))
        self.git('config', '--system', '--add', 'include.path', str(included))
        before = self.system_config.read_bytes()
        self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.system_config.read_bytes(), before)

    def test_new_entry_neutralized_by_include_is_reported_without_repeated_adds(self):
        included = self.directory / 'included.gitconfig'
        included.write_text('[safe]\n\tdirectory =\n', encoding='utf-8')
        self.add_entry('/another/project')
        self.git('config', '--system', '--add', 'include.path', str(included))
        result = self.shell('git_safe_directory_system_ensure "$project_path"')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reste inactive', result.stderr)
        before = self.system_config.read_bytes()
        result = self.shell('git_safe_directory_system_ensure "$project_path"')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.system_config.read_bytes(), before)

    def test_symbolic_link_uses_the_real_project_path(self):
        alias = self.projects / 'alias'
        alias.symlink_to(self.project, target_is_directory=True)
        self.assert_success(self.shell('git_safe_directory_system_ensure "$ENV_DEVOPS_PROJECTS_ROOT/alias"'))
        self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        self.assertEqual(self.entries(), [str(self.project)])

    def test_unsafe_path_representations_are_rejected(self):
        for name in ('*', 'line\nbreak', 'trailing\n'):
            with self.subTest(name=name):
                path = self.projects / name
                path.mkdir()
                result = self.shell('git_safe_directory_system_ensure "$ENV_DEVOPS_PROJECTS_ROOT/$NAME"',
                                    setup='NAME=' + "'" + name + "'")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('safe.directory', result.stderr)
        self.assertFalse(self.system_config.exists())

    def test_invalid_system_configuration_is_an_error(self):
        self.system_config.write_text('[invalid\n', encoding='utf-8')
        before = self.system_config.read_bytes()
        for command in ('git_safe_directory_system_ensure', 'git_safe_directory_system_status'):
            with self.subTest(command=command):
                result = self.shell(command + ' "$project_path"')
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('safe.directory', result.stderr)
                self.assertNotIn('absente', result.stdout)
                self.assertEqual(self.system_config.read_bytes(), before)

    def test_write_failure_is_reported(self):
        self.environment['GIT_CONFIG_SYSTEM'] = str(self.directory / 'missing' / 'config')
        result = self.shell('git_safe_directory_system_ensure "$project_path"')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Impossible d'enregistrer safe.directory", result.stderr)

    def test_init_existing_repository_registers_silently(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        for _ in range(2):
            result = self.shell('git_init "$project_id"')
            self.assert_success(result)
            self.assertEqual(result.stdout, '')
            self.assertEqual(result.stderr, '')
        self.assertEqual(self.entries(), [str(self.project)])

    def test_system_exception_allows_git_with_a_different_owner(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        self.environment['GIT_TEST_ASSUME_DIFFERENT_OWNER'] = '1'
        before = self.git('-C', str(self.project), 'rev-parse', '--is-inside-work-tree', check=False)
        self.assertNotEqual(before.returncode, 0)
        self.assertIn('dubious ownership', before.stderr)
        self.assert_success(self.shell('git_safe_directory_system_ensure "$project_path"'))
        after = self.git('-C', str(self.project), 'rev-parse', '--is-inside-work-tree')
        self.assertEqual(after.stdout.strip(), 'true')

    def test_status_system_entry_does_not_promise_to_override_global_reset(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        self.add_entry(str(self.project))
        self.git('config', '--global', '--add', 'safe.directory', '')
        self.environment['GIT_TEST_ASSUME_DIFFERENT_OWNER'] = '1'
        before = self.system_config.read_bytes()
        result = self.shell('git_status "$project_id"')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('présente (système, entrée exacte)', result.stdout)
        self.assertEqual(self.system_config.read_bytes(), before)

    def test_init_new_repository_registers_before_initialization(self):
        setup = '''
runuser() {
    shift 3
    case "$*" in
        *rev-parse*) return 1 ;;
        *'init --quiet'*)
            git config --system --fixed-value --get-all safe.directory "$project_path" >/dev/null
            printf 'initialization\\n' > "$ENV_DEVOPS_PROJECTS_ROOT/initialization.marker"
            ;;
        *'diff --cached --quiet'*) return 1 ;;
    esac
    return 0
}
'''
        result = self.shell('git_init "$project_id"', setup=setup)
        self.assert_success(result)
        self.assertEqual(result.stdout, '')
        self.assertEqual((self.projects / 'initialization.marker').read_text(), 'initialization\n')
        self.assertEqual(self.entries(), [str(self.project)])

    def test_init_stops_before_repository_creation_if_system_write_fails(self):
        self.environment['GIT_CONFIG_SYSTEM'] = str(self.directory / 'missing' / 'config')
        result = self.shell('git_init "$project_id"')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.project / '.git').exists())

    def test_update_preserves_variables_and_registers_once(self):
        for _ in range(2):
            result = self.shell('git_update "$project_id"', input_text='\n\n\n')
            self.assert_success(result)
        configuration = (self.project / 'project.env').read_text(encoding='utf-8')
        self.assertIn('PROJECT_TYPE=test\n', configuration)
        self.assertIn('GITHUB_ENABLED=No\n', configuration)
        self.assertEqual(self.entries(), [str(self.project)])

    def test_failed_local_update_does_not_register(self):
        result = self.shell('git_update "$project_id"', setup='git_update_local() { return 7; }')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.system_config.exists())

    def test_failed_system_update_preserves_saved_local_variables(self):
        self.environment['GIT_CONFIG_SYSTEM'] = str(self.directory / 'missing' / 'config')
        result = self.shell('git_update "$project_id"', input_text='topic\n\n\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('LOCAL_DEFAULT_BRANCH=topic\n',
                      (self.project / 'project.env').read_text(encoding='utf-8'))

    def test_status_reports_absent_without_creating_system_configuration(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        result = self.shell('git_status "$project_id"')
        self.assert_success(result)
        self.assertIn('absente (système, entrée exacte)', result.stdout)
        self.assertIn(str(self.project), result.stdout)
        self.assertIn('Branche courante', result.stdout)
        self.assertIn('Fichiers suivis', result.stdout)
        self.assertFalse(self.system_config.exists())

    def test_status_reports_present_and_preserves_configuration(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        self.add_entry(str(self.project))
        before = self.system_config.read_bytes()
        result = self.shell('git_status "$project_id"')
        self.assert_success(result)
        self.assertIn('présente (système, entrée exacte)', result.stdout)
        self.assertEqual(self.system_config.read_bytes(), before)

    def test_status_incomplete_configuration_does_not_register_indirectly(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        self.write_project_configuration(complete=False)
        result = self.shell('git_status "$project_id"', input_text='\n\n\n')
        self.assert_success(result)
        self.assertFalse(self.system_config.exists())

    def test_status_missing_configuration_does_not_register_indirectly(self):
        self.git('init', '--quiet', '-b', 'main', str(self.project))
        (self.project / 'project.env').unlink()
        result = self.shell('git_status "$project_id"', input_text='main\nTest\ngit@example.test\n')
        self.assert_success(result)
        self.assertFalse(self.system_config.exists())

    def test_status_read_error_stops_before_configuration_fallback(self):
        self.system_config.write_text('[invalid\n', encoding='utf-8')
        before = (self.project / 'project.env').read_bytes()
        result = self.shell('git_status "$project_id"')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('safe.directory', result.stderr)
        self.assertNotIn('absente', result.stdout)
        self.assertEqual((self.project / 'project.env').read_bytes(), before)

    def test_help_mentions_safe_directory_without_changing_signatures(self):
        for arguments in (('projects', 'help'), ('projects', 'git', 'help'),
                          ('projects', 'git', 'status', 'help')):
            with self.subTest(arguments=arguments):
                result = subprocess.run(
                    ['bash', str(ROOT / 'root-install-debian.sh'), *arguments],
                    cwd=self.directory, env=self.environment,
                    text=True, capture_output=True, check=False,
                )
                self.assert_success(result)
                self.assertIn('rid projects git status <ID PROJECTS>', result.stdout)
                self.assertIn('safe.directory système', result.stdout)


if __name__ == '__main__':
    unittest.main()
