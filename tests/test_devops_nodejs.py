#!/usr/bin/env python3
"""Résolution Node.js isolée : aucun réseau ni installation réelle."""
import os
from pathlib import Path
import re
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'
INDEX_URL = 'https://nodejs.org/dist/index.tab'


class DevopsNodejsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = SCRIPT.read_text(encoding='utf-8')
        start = source.index('    NODE_INDEX="' + INDEX_URL + '"')
        end = source.index('    mkdir -p "$INSTALL_DIR"', start)
        cls.block = source[start:end] + '    mkdir -p "$INSTALL_DIR"\n'
        handler = re.search(r'^error_handler\(\) \{\n.*?^\}', source, re.M | re.S)
        if not handler:
            raise AssertionError('error_handler absent')
        cls.handler = handler.group()

    def run_block(self, content='', status=0):
        code = 'set -Eeuo pipefail\n' + self.handler + '\n'
        code += "trap 'error_handler' ERR\n"
        code += '''
curl() {
    printf 'CURL_ARG=<%s>\n' "$@" >&2
    printf '%s' "$TEST_INDEX_CONTENT"
    if [ "$TEST_CURL_STATUS" -ne 0 ]; then
        printf 'curl: (%s) échec simulé\n' "$TEST_CURL_STATUS" >&2
    fi
    return "$TEST_CURL_STATUS"
}
mkdir() { printf 'NODE_MUTATION\n'; }
NODEJS_SERIES=24
INSTALL_DIR=/controlled/node
'''
        code += self.block + '\nprintf "NODE_SELECTED=%s\\n" "$NODE_LATEST"\n'
        return subprocess.run(
            ['/bin/bash', '--noprofile', '--norc', '-c', code], cwd=ROOT,
            env={'PATH': os.defpath, 'LC_ALL': 'C.UTF-8',
                 'TEST_INDEX_CONTENT': content, 'TEST_CURL_STATUS': str(status)},
            text=True, capture_output=True, timeout=10)

    def test_download_failure_preserves_status_and_stops(self):
        for status in (60, 6, 22, 28):
            for content in ('', 'version\tdate\nv24.99.0\t2026-01-01\n'):
                with self.subTest(status=status, partial=bool(content)):
                    result = self.run_block(content, status)
                    self.assertEqual(result.returncode, status, result.stderr)
                    self.assertEqual(result.stdout, '')
                    self.assertIn(f'curl: ({status}) échec simulé', result.stderr)
                    diagnostic = (f'❌ Node.js : échec de lecture de {INDEX_URL} '
                                  f'(curl={status}).')
                    self.assertEqual(result.stderr.count(diagnostic), 1)
                    self.assertNotIn('ERREUR DIU', result.stderr)
                    self.assertNotIn('tail -n 1', result.stderr)
                    self.assertNotIn('v24.99.0', result.stderr)

    def test_success_preserves_series_and_version_sort(self):
        result = self.run_block(
            'version\tdate\nv24.2.0\t2026-01-01\nv25.1.0\t2026-01-01\n'
            'v24.10.0\t2026-02-01\nv240.99.0\t2026-02-01\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'NODE_MUTATION\nNODE_SELECTED=24.10.0\n')
        self.assertNotIn('❌', result.stderr)

    def test_download_arguments_preserve_tls_and_bound_transfer(self):
        result = self.run_block('version\tdate\nv24.2.0\t2026-01-01\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = re.findall(r'^CURL_ARG=<(.*)>$', result.stderr, re.M)
        self.assertEqual(arguments, ['-fsSL', '--connect-timeout', '10',
                                     '--max-time', '60', INDEX_URL])

    def test_missing_series_preserves_diagnostic_and_stops(self):
        result = self.run_block('version\tdate\nv25.1.0\t2026-01-01\n')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(result.stdout,
                         '❌ Impossible de déterminer la dernière version Node.js 24.x\n')
        self.assertNotIn('ERREUR DIU', result.stderr)

    def test_empty_index_stops_before_mutation(self):
        result = self.run_block()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('Impossible de déterminer la dernière version Node.js 24.x',
                      result.stdout)
        self.assertNotIn('NODE_MUTATION', result.stdout)
        self.assertNotIn('ERREUR DIU', result.stderr)


if __name__ == '__main__':
    unittest.main()
