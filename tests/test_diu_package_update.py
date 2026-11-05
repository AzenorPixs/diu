import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DiuPackageUpdateTests(unittest.TestCase):
    def test_stable_version_precedes_timestamp_and_can_replace_it(self):
        config = ('REMOTE_GITHUB_BASE_URL=https://github.com\n'
                  'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        releases = {
            'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1': [
                {'tag_name': 'v2026.11.03.08.38', 'assets': [
                    {'name': 'diu_2026.11.03.08.38_all.deb',
                     'browser_download_url': 'https://github.com/old.deb'}]},
                {'tag_name': 'v2.0.0', 'assets': [
                    {'name': 'diu_2.0.0_all.deb',
                     'browser_download_url': 'https://github.com/stable.deb'}]},
            ]}
        result, calls = self.run_update(config, releases, installed='2026.11.03.08.38')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://github.com/stable.deb', 'install'])

    def run_update(self, configs, releases, installed='1.0.0', failure='', metadata=None, no_project=False, arguments=()):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            project = base / 'diu'
            if not no_project:
                project.mkdir()
                (project / 'project.env').write_text(configs, encoding='utf-8')
            data = base / 'releases.json'
            data.write_text(json.dumps(releases), encoding='utf-8')
            calls = base / 'calls'
            requests = base / 'requests'
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
    printf '%s\n' "$last" >> "$REQUESTS"
    [[ "$last" == https://api.github.com/* || "$last" == https://forge.example/* ]] || return 22
    [[ "$last" != *"$FAILURE"* || -z "$FAILURE" ]] || return 22
    jq -c --arg url "$last" '.[$url] // []' "$RELEASES"
  else
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == --output ]]; then output="$2"; shift; fi
      shift
    done
    printf '%s\n' "$last" >> "$CALLS"
    [[ "$last" != *"$FAILURE"* || -z "$FAILURE" ]] || return 22
    printf 'fixture' > "$output"
  fi
}
diu_update "$@"
'''
            env = {**os.environ, 'ROOT': str(ROOT), 'ENV_DEVOPS_PROJECTS_ROOT': tmp,
                   'RELEASES': str(data), 'CALLS': str(calls), 'REQUESTS': str(requests), 'INSTALLED': installed,
                   'FAILURE': failure, **(metadata or {})}
            if no_project:
                env.pop('ENV_DEVOPS_PROJECTS_ROOT', None)
            result = subprocess.run(['bash', '-c', script, 'bash', *arguments], env=env, text=True,
                                    capture_output=True, check=False)
            self.requests = requests.read_text().splitlines() if requests.exists() else []
            return result, calls.read_text().splitlines() if calls.exists() else []

    def test_public_github_without_checkout_or_project_root(self):
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1'
        asset = 'https://github.com/AzenorPixs/diu/releases/download/v2.0.0/diu_2.0.0_all.deb'
        releases = {api: [{'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb', 'browser_download_url': asset}]}]}
        result, calls = self.run_update('', releases, no_project=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [asset, 'install'])

    def test_requested_exact_version_installs_for_older_equal_and_newer(self):
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page='
        asset = 'https://github.com/AzenorPixs/diu/1.1.7.deb'
        releases = {api + '1': [{'tag_name': 'v9.0.0', 'assets': [{'name': 'diu_9.0.0_all.deb', 'browser_download_url': 'https://github.com/9.deb'}]}],
                    api + '2': [{'tag_name': 'v1.1.7', 'assets': [{'name': 'diu_1.1.7_all.deb', 'browser_download_url': asset}]}]}
        for installed in ('1.0.0', '1.1.7', '2.0.0'):
            with self.subTest(installed=installed):
                result, calls = self.run_update('', releases, installed=installed, arguments=('1.1.7',), metadata={'PKG_VERSION': '1.1.7'})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [asset, 'install'])
                self.assertTrue(all('api.github.com' in u for u in self.requests))

    def test_requested_missing_invalid_and_inaccessible_do_not_fallback(self):
        forge = 'REMOTE_FORGEJO_BASE_URL=https://forge.example\nREMOTE_FORGEJO_OWNER=team\nREMOTE_FORGEJO_REPOSITORY=diu\n'
        for args, failure in ((('1.1.7',), ''), (('1.1.7',), 'api.github.com'), (('bad',), ''), (('',), ''), (('1.1.7', 'extra'), '')):
            with self.subTest(args=args, failure=failure):
                result, calls = self.run_update(forge, {}, arguments=args, failure=failure)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])
                self.assertFalse(any('forge.example' in u for u in self.requests))
                if args != ('1.1.7',):
                    self.assertEqual(self.requests, [])

    def test_requested_version_rejects_drafts_and_prereleases(self):
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1'
        asset = 'https://github.com/AzenorPixs/diu/1.1.7.deb'
        for flag in ('draft', 'prerelease'):
            releases = {api: [{'tag_name': 'v1.1.7', flag: True, 'assets': [{'name': 'diu_1.1.7_all.deb', 'browser_download_url': asset}]}]}
            result, calls = self.run_update('', releases, arguments=('1.1.7',))
            with self.subTest(flag=flag):
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])
                self.assertTrue(all('api.github.com' in u for u in self.requests))

    def test_requested_version_checks_metadata(self):
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1'
        asset = 'https://github.com/AzenorPixs/diu/1.1.7.deb'
        releases = {api: [{'tag_name': 'v1.1.7', 'assets': [{'name': 'diu_1.1.7_all.deb', 'browser_download_url': asset}]}]}
        result, calls = self.run_update('', releases, arguments=('1.1.7',), metadata={'PKG_VERSION': '1.1.8'})
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [asset])

    def test_only_github_is_queried(self):
        config = ('REMOTE_FORGEJO_BASE_URL=https://forge.example\nREMOTE_FORGEJO_OWNER=team\n'
                  'REMOTE_FORGEJO_REPOSITORY=diu\nREMOTE_GITLAB_BASE_URL=invalid value\nREMOTE_GITHUB_BASE_URL=https://github.com\n'
                  'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        releases = {
            'https://forge.example/api/v1/repos/team/diu/releases?per_page=100&page=1': [
                {'tag_name': 'v9.9.0', 'assets': [{'name': 'diu_9.9.0_all.deb',
                  'browser_download_url': 'https://forge.example/team/diu/releases/diu_9.9.0_all.deb'}]}],
            'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1': [
                {'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb',
                  'browser_download_url': 'https://github.com/team/diu/releases/diu_2.0.0_all.deb'}]}],
        }
        result, calls = self.run_update(config, releases)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://github.com/team/diu/releases/diu_2.0.0_all.deb', 'install'])
        self.assertTrue(all('api.github.com' in url for url in self.requests))
        result, calls = self.run_update(config, releases, installed='2.1.0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [])
        self.assertTrue(all('api.github.com' in url for url in self.requests))
        result, calls = self.run_update(config, releases, metadata={'PKG_ARCH': 'amd64'})
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('install', calls)
        self.assertTrue(all('api.github.com' in url for url in self.requests))
        result, calls = self.run_update(config, releases, failure='api.github.com', metadata={'PKG_VERSION': '9.9.0'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://forge.example/team/diu/releases/diu_9.9.0_all.deb', 'install'])
        self.assertIn('api.github.com', self.requests[0])
        self.assertIn('forge.example', self.requests[1])

    def test_fallback_when_github_missing_empty_or_invalid(self):
        forge = ('REMOTE_FORGEJO_BASE_URL=https://forge.example\n'
                 'REMOTE_FORGEJO_OWNER=team\nREMOTE_FORGEJO_REPOSITORY=diu\n')
        github = ('REMOTE_GITHUB_BASE_URL=https://github.com\n'
                  'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        forge_api = 'https://forge.example/api/v1/repos/team/diu/releases?per_page=100&page=1'
        gh_api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1'
        asset = 'https://forge.example/team/diu/2.deb'
        release = [{'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb', 'browser_download_url': asset}]}]
        for config, value in ((forge, []), (forge + github, []), (forge + github, {'error': 'invalid'}),
                              (forge + 'REMOTE_GITHUB_BASE_URL=https://github.com\n', [])):
            with self.subTest(config=config, value=value):
                result, calls = self.run_update(config, {forge_api: release, gh_api: value})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [asset, 'install'])
                self.assertTrue(any('forge.example' in u for u in self.requests))

    def test_forgejo_pagination_and_unavailable_fallback(self):
        config = ('REMOTE_GITHUB_BASE_URL=https://github.com\nREMOTE_GITHUB_OWNER=team\n'
                  'REMOTE_GITHUB_REPOSITORY=diu\nREMOTE_FORGEJO_BASE_URL=https://forge.example\n'
                  'REMOTE_FORGEJO_OWNER=team\nREMOTE_FORGEJO_REPOSITORY=diu\n')
        api = 'https://forge.example/api/v1/repos/team/diu/releases?per_page=100&page='
        asset = 'https://forge.example/2.deb'
        releases = {api + '1': [{'tag_name': 'v1.0.0', 'assets': []}],
                    api + '2': [{'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb', 'browser_download_url': asset}]}]}
        result, calls = self.run_update(config, releases, failure='api.github.com')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [asset, 'install'])
        self.assertTrue(any('page=2' in u and 'forge.example' in u for u in self.requests))
        result, calls = self.run_update(config, {}, failure='forge.example')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('install', calls)

    def test_invalid_forgejo_ignored_if_github_works_and_download_failure_stops(self):
        config = ('REMOTE_FORGEJO_BASE_URL=invalid value\nREMOTE_FORGEJO_BASE_URL=duplicate\n'
                  'REMOTE_GITHUB_BASE_URL=https://github.com\nREMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page=1'
        asset = 'https://github.com/team/diu/2.deb'
        releases = {api: [{'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb', 'browser_download_url': asset}]}]}
        result, calls = self.run_update(config, releases)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [asset, 'install'])
        result, calls = self.run_update(config, releases, failure='/2.deb')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('install', calls)
        self.assertTrue(all('api.github.com' in u for u in self.requests))

    def test_github_pagination(self):
        config = ('REMOTE_GITHUB_BASE_URL=https://github.com\n'
                  'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n')
        api = 'https://api.github.com/repos/AzenorPixs/diu/releases?per_page=100&page='
        releases = {api + '1': [{'tag_name': 'v1.0.0', 'assets': []}],
                    api + '2': [{'tag_name': 'v3.0.0', 'assets': [{
                        'name': 'diu_3.0.0_all.deb',
                        'browser_download_url': 'https://github.com/team/diu/3.deb'}]}]}
        result, calls = self.run_update(config, releases, metadata={'PKG_VERSION': '3.0.0'})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['https://github.com/team/diu/3.deb', 'install'])

    def test_missing_or_partial_github_configuration_is_rejected(self):
        for config in ('REMOTE_FORGEJO_BASE_URL=https://forge.example\n',
                       'REMOTE_GITHUB_BASE_URL=https://github.com\n'):
            with self.subTest(config=config):
                result, calls = self.run_update(config, {})
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])


if __name__ == '__main__':
    unittest.main()
