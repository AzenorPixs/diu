"""Résolution d'URL GitLab avec autorité littérale."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class GitlabRemoteResolutionTests(unittest.TestCase):
    def test_ipv6_authority_is_not_a_shell_pattern(self):
        with tempfile.TemporaryDirectory(dir=ROOT, prefix='.gitlab-remote-test-') as tmp:
            project = Path(tmp)
            (project / '.git').mkdir()
            script = r'''source "$1/lib/gitlab-auth.sh"
ENV_DEVOPS_USER=test
runuser() { printf '%s\n' 'https://[::1]/team/repository.git'; }
print_error() { printf '%s\n' "$*" >&2; }
_gitlab_resolve_remote "$2" origin
printf '%s\n' "$gitlab_host" "$gitlab_owner" "$gitlab_repository" "$gitlab_base_url"
'''
            result = subprocess.run(['bash', '-c', script, 'test', str(ROOT), str(project)],
                                    capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(),
                             ['[::1]', 'team', 'repository', 'https://[::1]'])


if __name__ == '__main__':
    unittest.main()
