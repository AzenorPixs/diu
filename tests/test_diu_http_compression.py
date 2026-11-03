import json
import os
import shutil
import subprocess
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]


class DiuHttpCompressionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for name in ('curl', 'zstd', 'jq', 'dpkg', 'dpkg-deb'):
            if not shutil.which(name):
                raise unittest.SkipTest(f'{name} indisponible')
        version = subprocess.run(['curl', '--version'], capture_output=True, text=True, check=True).stdout
        if 'zstd' not in version.lower():
            raise unittest.SkipTest('curl ne prend pas en charge Zstandard')

    def run_update(self, broken=''):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            project = root / 'diu'
            project.mkdir()
            (project / 'project.env').write_text(
                'REMOTE_GITHUB_BASE_URL=https://github.example\n'
                'REMOTE_GITHUB_OWNER=team\nREMOTE_GITHUB_REPOSITORY=diu\n', encoding='utf-8')
            staging = root / 'package'
            (staging / 'DEBIAN').mkdir(parents=True)
            (staging / 'DEBIAN').chmod(0o755)
            (staging / 'DEBIAN' / 'control').write_text(
                'Package: diu\nVersion: 2.0.0\nArchitecture: all\n'
                'Maintainer: Test <test@example.invalid>\nDescription: Fixture\n', encoding='utf-8')
            package = root / 'diu_2.0.0_all.deb'
            build = subprocess.run(['dpkg-deb', '--build', '--root-owner-group', str(staging), str(package)],
                                   check=False, capture_output=True, text=True)
            self.assertEqual(build.returncode, 0, build.stderr)
            def compress(data):
                return subprocess.run(['zstd', '-q', '-c'], input=data, capture_output=True, check=True).stdout

            asset = 'https://github.example/team/diu/releases/download/v2.0.0/diu_2.0.0_all.deb'
            releases = json.dumps([{'tag_name': 'v2.0.0', 'assets': [
                {'name': 'diu_2.0.0_all.deb', 'browser_download_url': asset}]}]).encode()
            requests = []

            class Handler(BaseHTTPRequestHandler):
                def do_GET(self):
                    requests.append(self.path)
                    if self.path.startswith('/api/'):
                        data = b'[]' if 'page=2' in self.path else releases
                        kind = 'api'
                    else:
                        data = package.read_bytes()
                        kind = 'asset'
                    body = b'invalid zstd' if broken == kind else compress(data)
                    self.send_response(200)
                    self.send_header('Content-Encoding', 'zstd')
                    self.send_header('Content-Length', str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)

                def log_message(self, *args):
                    pass

            server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            script = r'''
set -Eeuo pipefail
source "$ROOT/modules/diu/update.sh"
print_error() { printf 'ERROR: %s\n' "$*" >&2; }
print_info() { :; }
dpkg-query() { printf 'installed 1.0.0'; }
dpkg() {
    if [[ "$1" == --install ]]; then printf 'installed\n' >> "$INSTALLS"; return 0; fi
    command dpkg "$@"
}
curl() {
    local -a args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --proto|--proto-redir) shift 2 ;;
            https://github.example/*) args+=("$TEST_SERVER${1#https://github.example}"); shift ;;
            *) args+=("$1"); shift ;;
        esac
    done
    command curl --noproxy '*' "${args[@]}"
}
diu_update
'''
            env = {**os.environ, 'ROOT': str(ROOT), 'DEVOPS_PROJECTS_ROOT': str(root),
                   'TEST_SERVER': f'http://127.0.0.1:{server.server_port}',
                   'INSTALLS': str(root / 'installs')}
            try:
                result = subprocess.run(['bash', '-c', script], env=env, capture_output=True,
                                        text=True, timeout=20, check=False)
            finally:
                server.shutdown()
                thread.join()
                server.server_close()
            installs = (root / 'installs').read_text() if (root / 'installs').exists() else ''
            return result, requests, installs

    def test_zstd_api_and_package_are_decoded_before_install(self):
        result, requests, installs = self.run_update()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any(path.startswith('/api/') for path in requests))
        self.assertTrue(any('/releases/download/' in path for path in requests))
        self.assertEqual(installs, 'installed\n')

    def test_corrupt_zstd_api_stops_before_download(self):
        result, requests, installs = self.run_update('api')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Impossible de consulter les releases', result.stderr)
        self.assertFalse(any('/releases/download/' in path for path in requests))
        self.assertEqual(installs, '')

    def test_corrupt_zstd_package_stops_before_install(self):
        result, requests, installs = self.run_update('asset')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Téléchargement du paquet DIU échoué', result.stderr)
        self.assertTrue(any('/releases/download/' in path for path in requests))
        self.assertEqual(installs, '')


if __name__ == '__main__':
    unittest.main()
