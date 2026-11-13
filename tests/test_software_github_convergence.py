import hashlib
import io
import tarfile
import tempfile
import unittest
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSET = "codex-package-x86_64-unknown-linux-musl.tar.gz"


class GithubConvergenceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix=".github-convergence-test-", dir=ROOT)
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.install_root = self.base / "install"
        self.binary = self.base / "bin" / "codex"
        self.archive = self.base / "archive.tar.gz"
        self.manifest = self.base / "manifest"
        with tarfile.open(self.archive, "w:gz") as archive:
            for name in ("bin/codex", "codex-path/rg"):
                payload = b"#!/bin/sh\nexit 0\n"
                info = tarfile.TarInfo(name)
                info.mode = 0o755
                info.size = len(payload)
                archive.addfile(info, io.BytesIO(payload))
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/github-state.sh"\n'
            'source "$1/modules/softwares/github-convergence.sh"\n'
            'fixture_root="$2"; fixture_binary="$3"; fixture_archive="$4"; fixture_manifest="$5"\n'
            'software_github_convergence_metadata() { case "$2" in\n'
            ' variable) echo SOFTWARE_GITHUB_CODEX_CLI;; owner) echo openai;; repository) echo codex;;\n'
            ' tag-prefix) echo rust-v;; system) echo Linux;; architecture) echo x86_64;; asset) echo codex-package-x86_64-unknown-linux-musl.tar.gz;;\n'
            ' manifest) echo codex-package_SHA256SUMS;; root) echo "$fixture_root";; binary) echo "$fixture_binary";;\n'
            ' executable) echo bin/codex;; companion) echo codex-path/rg;; *) return 1;; esac; }\n'
            'uname() { case "$1" in -s) echo Linux;; -m) echo x86_64;; esac; }\n'
            'software_github_convergence_detect() { printf "0\\n"; }\n'
            'curl() { local url="" output=""; while (($#)); do case "$1" in\n'
            ' -o) output="$2"; shift 2;; --header) shift 2;; https://*) url="$1"; shift;; *) shift;; esac; done\n'
            ' case "$url" in *api.github.com*) printf "{\\"tag_name\\":\\"rust-v1.2.3\\",\\"asset\\":\\"codex-package-x86_64-unknown-linux-musl.tar.gz\\"}\\n";;\n'
            ' *SHA256SUMS) cp -- "$fixture_manifest" "$output";; *.tar.gz) cp -- "$fixture_archive" "$output";; *) return 1;; esac; }\n'
            + body
        )
        return subprocess.run(
            ["bash", "-c", script, "--", str(ROOT), str(self.install_root), str(self.binary),
             str(self.archive), str(self.manifest)],
            text=True, capture_output=True, check=False,
        )

    def test_install_verifies_archive_and_preserves_desired_variable(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_CODEX_CLI=0\n'
            'software_github_install codex-cli || exit $?\n'
            '[[ "$SOFTWARE_GITHUB_CODEX_CLI" == 0 ]]'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.binary.is_symlink())
        self.assertTrue(self.binary.exists())
        self.assertTrue((self.install_root / "packages/standalone/current/codex-path/rg").is_file())

    def test_bad_checksum_does_not_install(self):
        self.manifest.write_text(f"{'0' * 64}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell('software_github_install codex-cli')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.binary.exists())
        self.assertIn("SHA-256", result.stderr)

    def test_archive_with_parent_path_is_rejected(self):
        with tarfile.open(self.archive, "w:gz") as archive:
            payload = b"unsafe"
            info = tarfile.TarInfo("../../escaped")
            info.size = len(payload)
            archive.addfile(info, io.BytesIO(payload))
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell('software_github_install codex-cli')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.base / "escaped").exists())
        self.assertFalse(self.binary.exists())

    def test_archive_with_escaping_symlink_is_rejected(self):
        with tarfile.open(self.archive, "w:gz") as archive:
            link = tarfile.TarInfo("outside")
            link.type = tarfile.SYMTYPE
            link.linkname = "../../escaped"
            archive.addfile(link)
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell('software_github_install codex-cli')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.base / "escaped").exists())
        self.assertFalse(self.binary.exists())

    def test_archive_with_internal_symlink_is_supported(self):
        with tarfile.open(self.archive, "w:gz") as archive:
            for name in ("bin/codex", "codex-path/rg"):
                payload = b"#!/bin/sh\nexit 0\n"
                info = tarfile.TarInfo(name)
                info.mode = 0o755
                info.size = len(payload)
                archive.addfile(info, io.BytesIO(payload))
            link = tarfile.TarInfo("bin/codex-alias")
            link.type = tarfile.SYMTYPE
            link.linkname = "codex"
            archive.addfile(link)
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell('software_github_install codex-cli')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.install_root / "packages/standalone/current/bin/codex-alias").is_symlink())

    def test_archive_cannot_write_through_an_internal_symlink(self):
        with tarfile.open(self.archive, "w:gz") as archive:
            target = tarfile.TarInfo("target")
            target.type = tarfile.DIRTYPE
            archive.addfile(target)
            link = tarfile.TarInfo("alias")
            link.type = tarfile.SYMTYPE
            link.linkname = "target"
            archive.addfile(link)
            payload = b"unsafe"
            child = tarfile.TarInfo("alias/file")
            child.size = len(payload)
            archive.addfile(child, io.BytesIO(payload))
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell('software_github_install codex-cli')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.binary.exists())

    def test_remove_preserves_profile_and_rejects_unrelated_binary(self):
        self.binary.parent.mkdir(parents=True)
        self.binary.write_text("unrelated", encoding="utf-8")
        rejected = self.run_shell('software_github_remove codex-cli')
        self.assertNotEqual(rejected.returncode, 0)
        self.assertEqual(self.binary.read_text(encoding="utf-8"), "unrelated")
        self.binary.unlink()
        self.assertEqual(self.run_shell('software_github_install codex-cli').returncode, 0)
        profile = self.base / "profile"
        profile.write_text("preserved", encoding="utf-8")
        result = self.run_shell('software_github_remove codex-cli')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.binary.exists())
        self.assertEqual(profile.read_text(encoding="utf-8"), "preserved")

    def test_codex_cleanup_removes_only_temporary_installation_files(self):
        temporary = self.install_root / "packages/tmp"
        temporary.mkdir(parents=True)
        (temporary / "partial").write_text("temporary", encoding="utf-8")
        preserved = self.install_root / "profile"
        preserved.write_text("preserved", encoding="utf-8")
        result = self.run_shell('software_github_cleanup_codex_cli')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(temporary.exists())
        self.assertEqual(preserved.read_text(encoding="utf-8"), "preserved")

    def test_failed_link_restores_previous_installation(self):
        target = self.install_root / "packages/standalone/current/bin/codex"
        target.parent.mkdir(parents=True)
        target.write_text("old", encoding="utf-8")
        self.binary.parent.mkdir(parents=True)
        self.binary.symlink_to(target)
        result = self.run_shell('ln() { return 1; }\nsoftware_github_install codex-cli upgrade')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_text(encoding="utf-8"), "old")

    def test_install_does_not_replace_software_appearing_during_download(self):
        result = self.run_shell(
            'software_github_convergence_detect() { printf "1\\n"; }\n'
            'software_github_install codex-cli'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("déjà présent", result.stdout)
        self.assertFalse(self.binary.exists())


if __name__ == "__main__":
    unittest.main()
