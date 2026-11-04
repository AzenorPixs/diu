import json
import os
import shutil
import subprocess
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOKEN = 'fixture-token-for-tests-only'


class GithubPrivateUpdateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for tool in ('curl', 'jq', 'dpkg', 'dpkg-deb'):
            if not shutil.which(tool):
                raise unittest.SkipTest(f'{tool} indisponible')

    def run_update(self, token=True, permissions=0o600, fail_asset=False, invalid_token=False, trace=False):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / '.curlrc').write_text('header = "Authorization: Bearer fixture-curlrc"\n', encoding='utf-8')
            project = root / 'diu'
            (project / 'config').mkdir(parents=True)
            (project / 'project.env').write_text(
                'REMOTE_GITHUB_BASE_URL=https://github.com\n'
                'REMOTE_GITHUB_OWNER=example\nREMOTE_GITHUB_REPOSITORY=diu\n', encoding='utf-8')
            if token:
                token_path = project / 'config' / 'github.token'
                token_path.write_text(TOKEN + ('-invalid' if invalid_token else '') + '\n', encoding='utf-8')
                token_path.chmod(permissions)
            staging = root / 'package'
            (staging / 'DEBIAN').mkdir(parents=True)
            (staging / 'DEBIAN').chmod(0o755)
            (staging / 'DEBIAN' / 'control').write_text(
                'Package: diu\nVersion: 2.0.0\nArchitecture: all\n'
                'Maintainer: Test <test@example.invalid>\nDescription: Fixture\n', encoding='utf-8')
            package = root / 'diu_2.0.0_all.deb'
            build = subprocess.run(['dpkg-deb', '--build', '--root-owner-group', str(staging), str(package)],
                                   capture_output=True, text=True, check=False)
            self.assertEqual(build.returncode, 0, build.stderr)
            observed = []

            class DownloadHandler(BaseHTTPRequestHandler):
                def do_GET(self):
                    observed.append(('download', self.headers.get('Authorization')))
                    data = package.read_bytes()
                    self.send_response(200)
                    self.send_header('Content-Length', str(len(data)))
                    self.end_headers()
                    self.wfile.write(data)

                def log_message(self, *args):
                    pass

            download = ThreadingHTTPServer(('127.0.0.1', 0), DownloadHandler)

            class ApiHandler(BaseHTTPRequestHandler):
                def do_GET(self):
                    authorization = self.headers.get('Authorization')
                    observed.append(('api', authorization))
                    if '/releases/download/' in self.path:
                        if fail_asset:
                            self.send_response(403)
                        else:
                            self.send_response(302)
                            self.send_header('Location', f'http://127.0.0.1:{download.server_port}/file')
                        self.end_headers()
                        return
                    data = [] if 'page=2' in self.path else [{
                        'tag_name': 'v2.0.0', 'assets': [{'name': 'diu_2.0.0_all.deb',
                        'browser_download_url': 'https://github.com/AzenorPixs/diu/releases/download/v2.0.0/diu_2.0.0_all.deb'}]}]
                    body = json.dumps(data).encode()
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json')
                    self.send_header('Content-Length', str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)

                def log_message(self, *args):
                    pass

            api = ThreadingHTTPServer(('127.0.0.1', 0), ApiHandler)
            threads = [threading.Thread(target=server.serve_forever, daemon=True) for server in (api, download)]
            for thread in threads:
                thread.start()
            script = r'''
set -Eeuo pipefail
if [[ "${TRACE:-0}" == 1 ]]; then set -x; fi
source "$ROOT/lib/github-auth.sh"
source "$ROOT/modules/diu/update.sh"
print_error() { printf 'ERROR: %s\n' "$*" >&2; }
print_info() { :; }
dpkg-query() { printf 'installed 1.0.0'; }
dpkg() {
    if [[ "$1" == --install ]]; then printf 'installed\n' >> "$INSTALLS"; return 0; fi
    command dpkg "$@"
}
curl() {
    [[ "$1" == --disable ]] || return 99
    local -a args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --proto|--proto-redir) shift 2 ;;
            https://api.github.com/*) args+=("$TEST_SERVER${1#https://api.github.com}"); shift ;;
            https://github.com/*) args+=("$TEST_SERVER${1#https://github.com}"); shift ;;
            *) args+=("$1"); shift ;;
        esac
    done
    command curl "${args[@]}" --noproxy '*'
}
diu_update
'''
            env = {**os.environ, 'HOME': str(root), 'ROOT': str(ROOT), 'ENV_DEVOPS_PROJECTS_ROOT': str(root),
                   'TEST_SERVER': f'http://127.0.0.1:{api.server_port}', 'INSTALLS': str(root / 'installs'),
                   'TRACE': '1' if trace else '0'}
            try:
                result = subprocess.run(['bash', '-c', script], env=env, capture_output=True,
                                        text=True, timeout=20, check=False)
            finally:
                for server in (api, download):
                    server.shutdown()
                    server.server_close()
                for thread in threads:
                    thread.join()
            installs = (root / 'installs').read_text() if (root / 'installs').exists() else ''
            self.assertNotIn(TOKEN, result.stdout + result.stderr)
            return result, observed, installs

    def test_public_access_ignores_token_and_never_authenticates(self):
        for options in ({}, {'token': False}, {'permissions': 0o644}, {'invalid_token': True, 'trace': True}):
            with self.subTest(options=options):
                result, observed, installs = self.run_update(**options)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(installs, 'installed\n')
                self.assertTrue(observed)
                self.assertTrue(all(auth is None for _, auth in observed))
                self.assertIn(('download', None), observed)

    def test_asset_failure_does_not_install(self):
        result, observed, installs = self.run_update(fail_asset=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(installs, '')
        self.assertFalse(any(kind == 'download' for kind, _ in observed))


if __name__ == '__main__':
    unittest.main()
