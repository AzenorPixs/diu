import hashlib
import json
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSET = "opencode-linux-x64.tar.gz"
MANIFEST = "SHA256SUMS"


class GithubOpenCodeTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="diu-github-opencode-")
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.install_root = self.base / "install"
        self.binary = self.base / "bin" / "opencode"
        self.archive = self.base / ASSET
        self.manifest = self.base / MANIFEST
        self.releases = self.base / "releases.json"
        self.config = self.base / "softwares.env"

        with tarfile.open(self.archive, "w:gz") as archive:
            payload = b'#!/bin/sh\nprintf "2.3.0\\n"\n'
            info = tarfile.TarInfo("opencode")
            info.mode = 0o755
            info.size = len(payload)
            archive.addfile(info, __import__("io").BytesIO(payload))
        digest = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.manifest.write_text(f"{digest}  {ASSET}\n", encoding="utf-8")
        self.write_releases()

    def write_releases(self, entries=None):
        if entries is None:
            entries = [
                {
                    "tag_name": "v1.19.5",
                    "draft": False,
                    "prerelease": False,
                    "assets": [{"name": ASSET}, {"name": MANIFEST}],
                },
                {
                    "tag_name": "v2.3.0",
                    "draft": False,
                    "prerelease": False,
                    "assets": [{"name": ASSET}, {"name": MANIFEST}],
                },
                {
                    "tag_name": "v2.10.0",
                    "draft": False,
                    "prerelease": False,
                    "assets": [{"name": ASSET}, {"name": MANIFEST}],
                },
                {
                    "tag_name": "v2.11.0",
                    "draft": False,
                    "prerelease": True,
                    "assets": [{"name": ASSET}, {"name": MANIFEST}],
                },
                {
                    "tag_name": "v2.12.0",
                    "draft": False,
                    "prerelease": False,
                    "assets": [{"name": "opencode-desktop-linux-amd64.deb"}],
                },
            ]
        self.releases.write_text(json.dumps(entries), encoding="utf-8")

    def run_shell(self, body):
        script = (
            'source "$1/modules/softwares/convergence.sh"\n'
            'source "$1/modules/softwares/desired-state.sh"\n'
            'source "$1/modules/softwares/github-state.sh"\n'
            'source "$1/modules/softwares/github-convergence.sh"\n'
            'source "$1/modules/softwares/github-management.sh"\n'
            'source "$1/modules/softwares/github.sh"\n'
            'source "$1/modules/softwares/github-version.sh"\n'
            'fixture_root="$2"; fixture_binary="$3"; fixture_archive="$4"\n'
            'fixture_manifest="$5"; fixture_releases="$6"; fixture_base="$7"; fixture_config="$8"\n'
            'software_github_convergence_metadata() {\n'
            '  if [[ "$1" != opencode ]]; then return 1; fi\n'
            '  case "$2" in\n'
            '    variable) echo SOFTWARE_GITHUB_OPENCODE;;\n'
            '    configuration-hook) echo software_github_configure_opencode;;\n'
            '    cleanup-hook) echo software_github_cleanup_opencode;;\n'
            '    owner) echo anomalyco;; repository) echo opencode;; tag-prefix) echo v;;\n'
            '    system) echo Linux;; architecture) echo x86_64;;\n'
            '    asset) echo opencode-linux-x64.tar.gz;; manifest) echo SHA256SUMS;;\n'
            '    root) echo "$fixture_root";; binary) echo "$fixture_binary";;\n'
            '    command) echo opencode;; executable) echo opencode;; companion) echo opencode;;\n'
            '    *) return 1;;\n'
            '  esac\n'
            '}\n'
            'uname() { case "$1" in -s) echo Linux;; -m) echo x86_64;; esac; }\n'
            'curl() {\n'
            '  local url="" output=""\n'
            '  while (($#)); do\n'
            '    case "$1" in\n'
            '      -o) output="$2"; shift 2;;\n'
            '      --header) shift 2;;\n'
            '      https://*) url="$1"; shift;;\n'
            '      *) shift;;\n'
            '    esac\n'
            '  done\n'
            '  case "$url" in\n'
            '    *api.github.com*) cat -- "$fixture_releases";;\n'
            '    *SHA256SUMS) cp -- "$fixture_manifest" "$output";;\n'
            '    *.tar.gz) cp -- "$fixture_archive" "$output";;\n'
            '    *) return 1;;\n'
            '  esac\n'
            '}\n'
            + body
        )
        return subprocess.run(
            [
                "bash", "-c", script, "--", str(ROOT), str(self.install_root),
                str(self.binary), str(self.archive), str(self.manifest),
                str(self.releases), str(self.base), str(self.config),
            ],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_latest_stable_v2_ignores_v1_prerelease_and_desktop_only(self):
        result = self.run_shell("software_github_opencode_latest_stable_tag")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "v2.10.0")

    def test_global_declaration_uses_the_github_scope(self):
        result = subprocess.run(
            ["bash", "-c",
             'software_github_declare_desired() { printf "%s|%s\\n" "$1" "$2"; }\n'
             'source "$1/modules/diu/variables/softwares/desired_github_opencode.sh"',
             "--", str(ROOT)], text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "/root/diu/config/softwares.env|opencode\n")

    def test_detection_uses_only_declared_system_binary(self):
        old_binary = self.base / "old-home" / ".opencode" / "bin" / "opencode"
        old_binary.parent.mkdir(parents=True)
        old_binary.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        old_binary.chmod(0o700)
        result = self.run_shell(
            'PATH="$fixture_base/old-home/.opencode/bin:/usr/bin:/bin"\n'
            'software_github_opencode_detect'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "0\n")
        self.assertFalse(self.binary.exists())

    def test_install_verifies_digest_and_installs_system_link(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_OPENCODE=0\n'
            'software_github_install opencode || exit $?\n'
            'software_github_opencode_version'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines()[-1], "2.3.0")
        self.assertTrue(self.binary.is_symlink())
        self.assertEqual(
            self.binary.resolve(),
            self.install_root / "packages/standalone/current/opencode",
        )

    def test_bad_digest_does_not_install(self):
        self.manifest.write_text(f"{'0' * 64}  {ASSET}\n", encoding="utf-8")
        result = self.run_shell("software_github_install opencode")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.binary.exists())
        self.assertIn("SHA-256", result.stderr)

    def test_unowned_system_binary_is_not_replaced_or_removed(self):
        self.binary.parent.mkdir(parents=True)
        self.binary.write_text("unmanaged\n", encoding="utf-8")
        before = self.binary.read_bytes()
        result = self.run_shell("software_github_install opencode")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.binary.read_bytes(), before)

    def test_remove_preserves_unrelated_configuration(self):
        result = self.run_shell(
            'SOFTWARE_GITHUB_OPENCODE=1\n'
            'mkdir -p "$fixture_root/packages/standalone/current" "$(dirname "$fixture_binary")"\n'
            'printf "#!/bin/sh\\nexit 0\\n" > "$fixture_root/packages/standalone/current/opencode"\n'
            'chmod 700 "$fixture_root/packages/standalone/current/opencode"\n'
            'ln -s "$fixture_root/packages/standalone/current/opencode" "$fixture_binary"\n'
            'printf "keep\\n" > "$fixture_root/config.json"\n'
            'software_github_manage_one "$fixture_config" remove opencode || exit $?\n'
            '[[ ! -e "$fixture_binary" && -f "$fixture_root/config.json" ]]'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_GITHUB_OPENCODE=0\n")
        self.assertEqual((self.install_root / "config.json").read_text(encoding="utf-8"), "keep\n")

    def test_system_version_update_uses_latest_stable_v2(self):
        self.binary.parent.mkdir(parents=True)
        self.binary.write_text("#!/bin/sh\nprintf '2.3.0\\n'\n", encoding="utf-8")
        self.binary.chmod(0o700)
        self.config.write_text("export SOFTWARE_GITHUB_OPENCODE=1\n", encoding="utf-8")
        result = self.run_shell(
            'SOFTWARE_GITHUB_OPENCODE=1\n'
            'software_github_convergence_detect() { printf "1\\n"; }\n'
            'software_github_opencode_latest_stable_tag() { printf "v2.10.0\\n"; }\n'
            'software_github_install() { echo UPGRADE; }\n'
            'software_github_update_version opencode "$fixture_config"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("UPGRADE", result.stdout)
        self.assertEqual(self.config.read_text(encoding="utf-8"), "export SOFTWARE_GITHUB_OPENCODE=1\n")


if __name__ == "__main__":
    unittest.main()
