#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SystemAptTests(unittest.TestCase):
    def test_nvidia_deb822_sources_omit_components(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            directory = Path(directory)
            script = r'''
set -Eeuo pipefail
print_error() { printf '%s\n' "$*" >&2; }
source "$ROOT/modules/system/apt.sh"
SYSTEM_DEBIAN_RELEASE=trixie
SYSTEM_APT_THIRD_PARTY_DIRECTORY="$TMPDIR/sources.list.d"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="$TMPDIR/keyrings"
system_apt_is_deb822() { return 0; }
install() { mkdir -p "$TMPDIR/sources.list.d" "$TMPDIR/keyrings"; }
curl() { printf 'fake-key'; }
gpg() {
    touch "$TMPDIR/keyrings/nvidia-archive-keyring.gpg"
    touch "$TMPDIR/keyrings/nvidia-container-toolkit-archive-keyring.gpg"
}
system_apt_repository_engine 1 nvidia key deb / amd64 https://nvidia.example/ ""
system_apt_repository_engine 1 nvidia-container-toolkit key deb / amd64 https://nvidia.example/container/ ""
! grep -q '^Components:' "$TMPDIR/sources.list.d/nvidia.sources"
! grep -q '^Components:' "$TMPDIR/sources.list.d/nvidia-container-toolkit.sources"
'''
            result = subprocess.run(
                ["bash", "-c", script],
                env=dict(os.environ, ROOT=str(ROOT), TMPDIR=str(directory),
                          SYSTEM_APT_NVIDIA="1"),
                text=True,
                capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
