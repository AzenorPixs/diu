import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DiuPackageUpdateTests(unittest.TestCase):
    def run_update(self, configs, releases, installed='1.0.0', failure='', metadata=None):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            project = base / 'diu'
            project.mkdir()
            (project / 'project.env').write_text(configs, encoding='utf-8')
            data = base / 'releases.json'
            data.write_text(json.dumps(releases), encoding='utf-8')
            calls = base / 'calls'
            script = r'''
set -Eeuo pipefail
source "$ROOT/modules/diu/update.sh"
print_error() { printf 'ERROR: %s\n' "$*" >&2; }
print_info() { printf '%s\n' "$*"; }
dpkg-query() { printf 'installed %s' "$INSTALLED"; }
dpkg() {
  case "$1" in
    --install) printf '%s\n' install >> "$CALLS"; return 0 ;;
    *) command dpkg "$@" ;;
  esac
}
dpkg-deb() {
  case "$2" in
    *Package*) printf '%s' "${PKG_NAME:-diu}" ;;
    *Version*) printf '%s' "${PKG_VERSION:-2.0.0}" ;;
    *Architecture*) printf '%s' "${PKG_ARCH:-all}" ;;
  esac
}
curl() {
  local last="${!#}" output=''
  if [[ "$last" == *releases*'?'* ]]; then
    [[ "$last" != *"$FAILURE"* || -z "$FAILURE" ]] || return 22
    jq -c --arg url "$last" '.[$url] // []' "$RELEASES"
  else
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == --output ]]; then output="$2"; shift; fi
      shift
    done
    printf '%s\n' "$last" >> "$CALLS"
    printf 'fixture' > "$output"
  fi
}
diu_update
'''
            env = {**os.environ, 'ROOT': str(ROOT), 'DEVOPS_PROJECTS_ROOT': tmp,
                   'RELEASES': str(data), 'CALLS': str(calls), 'INSTALLED': installed,
                   'FAILURE': failure, **(metadata or {})}
            result = subprocess.run(['bash', '-c', script], env=env, text=True,
                                    capture_output=True, check=False)
            return result, calls.read_text().splitlines() if calls.exists() else []

    def test_selects_highest_version_across_providers(self):
        config = ('REMOTE_FORGEJO_BASE_URL=https://forge.example\nREMOTE_FORGEJO_OWNER=team\n'
                  'REMOTE_FORGEJO_REPOSITORY=diu\nREMOTE_GITHUB_BASE_URL=https://github.com\n'
                  'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        releases = {
            'https://forge.example/api/v1/repos/team/diu/releases?per_page=100&page=1': [
                {'tag_name': 'v1.9.0', 'assets': [{'name': 'diu_1.9.0_all.deb',
                  'browser_download_url': 'https://forge.example/team/diu/releases/diu_1.9.0_all.deb'}]}],
            'https://api.github.com/repos/team/diu/releases?per_page=100&page=1': [
                {'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb',
                  'browser_download_url': 'https://github.com/team/diu/releases/diu_2.0.0_all.deb'}]}],
        }
        result, calls = self.run_update(config, releases)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://github.com/team/diu/releases/diu_2.0.0_all.deb', 'install'])
        result, calls = self.run_update(config, releases, installed='2.1.0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [])
        result, calls = self.run_update(config, releases, metadata={'PKG_ARCH': 'amd64'})
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('install', calls)
        result, calls = self.run_update(config, releases, failure='api.github.com')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])

    def test_gitlab_and_pagination(self):
        config = ('REMOTE_GITLAB_BASE_URL=https://gitlab.example\n'
                  'REMOTE_GITLAB_OWNER=team/group\nREMOTE_GITLAB_REPOSITORY=diu\n')
        api = 'https://gitlab.example/api/v4/projects/team%2Fgroup%2Fdiu/releases?per_page=100&page='
        releases = {api + '1': [{'tag_name': 'v1.0.0', 'assets': {'links': []}}],
                    api + '2': [{'tag_name': 'v3.0.0', 'assets': {'links': [{
                        'name': 'diu_3.0.0_all.deb',
                        'url': 'https://gitlab.example/uploads/diu_3.0.0_all.deb'}]}}]}
        result, calls = self.run_update(config, releases, metadata={'PKG_VERSION': '3.0.0'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://gitlab.example/uploads/diu_3.0.0_all.deb', 'install'])

    def test_partial_configuration_is_rejected(self):
        result, calls = self.run_update('REMOTE_FORGEJO_BASE_URL=https://forge.example\n', {})
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])


if __name__ == '__main__':
    unittest.main()
