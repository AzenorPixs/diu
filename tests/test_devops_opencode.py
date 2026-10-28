#!/usr/bin/env python3
"""Mise à jour OpenCode V2 isolée : aucun réseau ni installateur réel."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'root-install-debian.sh'
API_PREFIX = 'https://api.github.com/repos/anomalyco/opencode/releases?per_page=100&page='
INSTALLER = 'https://opencode.ai/v2/install'


class DevopsOpencodeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = SCRIPT.read_text(encoding='utf-8')
        start = source.index('\tif [ "$OPENCODE" -eq 1 ]')
        end = source.index('  if [ "$OPENSPEC" -eq 1 ]', start)
        cls.block = source[start:end]
        old_install_dir = 'INSTALL_DIR="/home/${OPENCODE_USER}/.opencode/bin"'
        if old_install_dir not in cls.block:
            raise AssertionError('chemin d’installation OpenCode absent')
        cls.block = cls.block.replace(old_install_dir,
                                     'INSTALL_DIR="$TEST_INSTALL_DIR"')

    def run_block(self, installed=None, page1='', page2='[]', page3='[]',
                  curl_fail_page=0, curl_status=22, enabled='1'):
        with tempfile.TemporaryDirectory() as temporary:
            install_dir = Path(temporary) / 'bin'
            install_dir.mkdir()
            if installed is not None:
                binary = install_dir / 'opencode'
                binary.write_text(
                    '#!/bin/sh\nprintf \'%s\\n\' "$TEST_INSTALLED_VERSION"\n',
                    encoding='utf-8')
                binary.chmod(0o755)

            code = 'set -Eeuo pipefail\n'
            code += "trap 'printf \"ERR_HANDLER\\n\" >&2' ERR\n"
            code += '''
CURL_CALLS=0
curl() {
    local url="${@: -1}"
    CURL_CALLS=$((CURL_CALLS + 1))
    printf 'CURL_ARG=<%s>\n' "$@" >&2
    if [[ "$CURL_CALLS" -eq "$TEST_CURL_FAIL_PAGE" ]]; then
        printf 'curl: (%s) échec simulé\n' "$TEST_CURL_STATUS" >&2
        return "$TEST_CURL_STATUS"
    fi
    case "$url" in
        *page=1) printf '%s' "$TEST_RELEASES_PAGE_1" ;;
        *page=2) printf '%s' "$TEST_RELEASES_PAGE_2" ;;
        *page=3) printf '%s' "$TEST_RELEASES_PAGE_3" ;;
        *) printf 'page inconnue\n' >&2; return 1 ;;
    esac
}
su() { printf 'SU_ARG=<%s>\n' "$*"; }
chmod() { printf 'CHMOD_ARG=<%s>\n' "$*"; }
rm() { printf 'RM_ARG=<%s>\n' "$*"; }
'''
            code += self.block
            environment = {
                'PATH': os.defpath,
                'LC_ALL': 'C.UTF-8',
                'OPENCODE': enabled,
                'DEVOPS_USER': 'devops-test',
                'TEST_INSTALL_DIR': str(install_dir),
                'TEST_CURL_FAIL_PAGE': str(curl_fail_page),
                'TEST_CURL_STATUS': str(curl_status),
                'TEST_RELEASES_PAGE_1': page1,
                'TEST_RELEASES_PAGE_2': page2,
                'TEST_RELEASES_PAGE_3': page3,
            }
            if installed is not None:
                environment['TEST_INSTALLED_VERSION'] = installed
            return subprocess.run(
                ['/bin/bash', '--noprofile', '--norc', '-c', code],
                cwd=ROOT, env=environment, text=True, capture_output=True,
                timeout=10)

    @staticmethod
    def releases(*tags):
        return '[\n' + ',\n'.join(
            '  {\n    "tag_name": "' + tag + '"\n  }' for tag in tags
        ) + '\n]\n'

    def test_v1_install_updates_to_latest_stable_v2(self):
        result = self.run_block(
            installed='opencode 1.19.4',
            page1=self.releases('v3.0.0', 'v2.10.0-rc.1', 'v1.19.4'),
            page2=self.releases('v2.10.0', 'v2.2.0'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'CURL_ARG=<{API_PREFIX}1>', result.stderr)
        self.assertIn(f'CURL_ARG=<{API_PREFIX}2>', result.stderr)
        self.assertIn(f'curl -fsSL {INSTALLER} | bash -s -- --version 2.10.0 --no-modify-path',
                      result.stdout)
        self.assertIn('CHMOD_ARG=<+x', result.stdout)
        self.assertNotIn('https://opencode.ai/install', result.stdout)

    def test_equal_installed_version_does_not_reinstall(self):
        result = self.run_block(installed='2.10.0',
                                page1=self.releases('v2.10.0'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('OPENCODE OK ✅ (2.10.0)', result.stdout)
        self.assertNotIn('SU_ARG=', result.stdout)

    def test_newer_installed_version_is_not_downgraded(self):
        result = self.run_block(installed='2.11.0',
                                page1=self.releases('v2.10.0'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('OPENCODE OK ✅ (2.11.0)', result.stdout)
        self.assertNotIn('SU_ARG=', result.stdout)

    def test_missing_binary_installs_v2(self):
        result = self.run_block(page1=self.releases('v2.2.0'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'curl -fsSL {INSTALLER} | bash -s -- --version 2.2.0 --no-modify-path',
                      result.stdout)

    def test_numeric_version_comparison(self):
        result = self.run_block(installed='2.9.0',
                                page1=self.releases('v2.10.0'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('--version 2.10.0', result.stdout)

    def test_local_version_failure_stops_before_network_or_install(self):
        result = self.run_block(installed='version inconnue')
        self.assertEqual(result.returncode, 1)
        self.assertIn('version installée illisible', result.stderr)
        self.assertNotIn('CURL_ARG=', result.stderr)
        self.assertNotIn('SU_ARG=', result.stdout)
        self.assertNotIn('ERR_HANDLER', result.stderr)

    def test_github_failure_preserves_curl_status_and_stops(self):
        result = self.run_block(installed='1.19.4',
                                curl_fail_page=1, curl_status=22)
        self.assertEqual(result.returncode, 22, result.stderr)
        self.assertIn('curl: (22) échec simulé', result.stderr)
        self.assertIn('échec de lecture des releases GitHub (curl=22)',
                      result.stderr)
        self.assertNotIn('SU_ARG=', result.stdout)
        self.assertNotIn('ERR_HANDLER', result.stderr)

    def test_release_pages_without_stable_v2_fail_before_install(self):
        result = self.run_block(
            installed='1.19.4',
            page1=self.releases('v3.0.0', 'v2.2.0-rc.1', 'v1.19.4'),
            page2='[]')
        self.assertEqual(result.returncode, 1)
        self.assertIn('aucune release stable V2', result.stderr)
        self.assertNotIn('SU_ARG=', result.stdout)

    def test_opencode_disabled_does_not_query_or_install(self):
        result = self.run_block(enabled='0')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('CURL_ARG=', result.stderr)
        self.assertNotIn('SU_ARG=', result.stdout)


if __name__ == '__main__':
    unittest.main()
