#!/usr/bin/env python3
"""Tests isolés de migration sans lecture de la configuration locale."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ConfigCleanupTests(unittest.TestCase):
    def run_cleanup(self, path, prelude=""):
        return subprocess.run(
            ["bash", "-c", 'set -Eeuo pipefail\nsource "$ROOT/modules/system/variables-cleanup.sh"\n'
             + prelude + '\nconfig_cleanup "$TARGET" "$SYSTEM_CONFIG" "$SOFTWARES_CONFIG"'],
            env=dict(os.environ, ROOT=str(ROOT), TARGET=str(path),
                     SYSTEM_CONFIG=str(path.parent / 'system.env'),
                     SOFTWARES_CONFIG=str(path.parent / 'softwares.env')),
            text=True, capture_output=True)

    def test_cleanup_and_idempotence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            preserved = ('# DEBIAN_RELEASE=comment\n# DEBIAN_TYPE=comment\n# DISPLAY_LINK=comment\n'
                         '# PROXY_CA=comment\n'
                         'SYSTEM_DRIVERS_DISPLAY_LINK=1\nDISPLAY_LINK_EXTRA=keep\n'
                         '# TIME_ZONE=comment\nSYSTEM_TIME_ZONE=UTC\nTIME_ZONE_EXTRA=keep\n'
                         'SYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n'
                         'SYSTEM_DEBIAN_ENVIRONNEMENT=VM\nDEBIAN_TYPE_EXTRA=keep\n'
                         'SYSTEM_DEBIAN_RELEASE=bookworm\n'
                         'DEBIAN_RELEASE_EXTRA=keep\nOTHER=keep\n\n')
            path.write_text('DEBIAN_RELEASE=old\n export DEBIAN_RELEASE="old"\n'
                            '\texport\tDEBIAN_RELEASE=old # comment\n'
                            'DEBIAN_TYPE=PHYSICAL\n export DEBIAN_TYPE=VM\n'
                            '\texport\tDEBIAN_TYPE=LXC # comment\n'
                            'TIME_ZONE=UTC\n export TIME_ZONE=Europe/London\n'
                            '\texport\tTIME_ZONE=UTC # comment\n'
                            'DISPLAY_LINK=1\n export DISPLAY_LINK=0\n'
                            '\texport\tDISPLAY_LINK=1 # comment\n'
                            'PROXY_CA=0\n export PROXY_CA="1"\n'
                            '\texport\tPROXY_CA=1 # comment\n' + preserved)
            with path.open('a') as stream:
                stream.write('PROXY=0\n export PROXY=1 # legacy\nPROXY_HTTP=1\n'
                             'DRIVERS_NVIDIA=0\n export DRIVERS_NVIDIA=1 # legacy\n'
                             'DRIVERS_NVIDIA_EXTRA=keep\n')
            path.chmod(0o640)
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved + 'PROXY_HTTP=1\nDRIVERS_NVIDIA_EXTRA=keep\n')
            self.assertEqual((Path(directory) / 'system.env').read_text(),
                             'export SYSTEM_PROXY=1\nexport SYSTEM_DRIVERS_NVIDIA=1\n')
            self.assertEqual(path.stat().st_mode & 0o777, 0o640)
            before = path.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), preserved + 'PROXY_HTTP=1\nDRIVERS_NVIDIA_EXTRA=keep\n')
            self.assertEqual(path.stat().st_mtime_ns, before.st_mtime_ns)
            self.assertEqual(path.stat().st_ino, before.st_ino)
            self.assertEqual(result.stdout, '')

    def test_proxy_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('PROXY=0\nexport PROXY=1\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_PROXY=1\n')
            before = system_config.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.stat().st_mtime_ns, before.st_mtime_ns)

            path.write_text('PROXY=0\n')
            system_config.write_text('export SYSTEM_PROXY=1\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_PROXY=1\n')

    def test_ambiguous_proxy_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export PROXY="${PROXY_ENABLED}"\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), 'export PROXY="${PROXY_ENABLED}"\nOTHER=keep\n')
            self.assertFalse((Path(directory) / 'system.env').exists())
            self.assertNotIn('PROXY_ENABLED', result.stderr)
            self.assertEqual(result.stdout, '')

    def test_drivers_nvidia_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('DRIVERS_NVIDIA=0\nexport DRIVERS_NVIDIA=1\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_DRIVERS_NVIDIA=1\n')
            before = system_config.stat()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.stat().st_mtime_ns, before.st_mtime_ns)

            path.write_text('DRIVERS_NVIDIA=0\n')
            system_config.write_text('export SYSTEM_DRIVERS_NVIDIA=1\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_DRIVERS_NVIDIA=1\n')

    def test_ambiguous_drivers_nvidia_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            original = 'export DRIVERS_NVIDIA="${NVIDIA_ENABLED}"\nOTHER=keep\n'
            path.write_text(original)
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertFalse((Path(directory) / 'system.env').exists())
            self.assertNotIn('NVIDIA_ENABLED', result.stderr)
            self.assertEqual(result.stdout, '')

    def test_fstab_values_migrate_as_literals(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('FSTAB=1\n'
                            'export FSTAB_CONFIG1="UUID=abc /data ext4 defaults 0 2"\n'
                            "FSTAB_CONFIG2='tmpfs /var/log tmpfs rw,nosuid 0 0' # comment\n"
                            'FSTAB_CONFIG3=NONE\n'
                            'export FSTAB_CONFIG4=""\n'
                            'FSTAB_CONFIG5=UUID=abc # comment\n'
                            'export FSTAB_CONFIG6="UUID=def /backup ext4 defaults 0 2"\n'
                            '# FSTAB_CONFIG1=comment\nFSTAB_CONFIG_EXTRA=keep\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(),
                             '# FSTAB_CONFIG1=comment\nFSTAB_CONFIG_EXTRA=keep\nOTHER=keep\n')
            self.assertEqual(result.stdout, '')
            loaded = subprocess.run(
                ['bash', '-c', 'source "$SYSTEM_CONFIG"; printf "%s\\n" '
                 '"$SYSTEM_FSTAB" "$SYSTEM_FSTAB_CONFIG1" "$SYSTEM_FSTAB_CONFIG2" '
                 '"$SYSTEM_FSTAB_CONFIG3" "$SYSTEM_FSTAB_CONFIG4" "$SYSTEM_FSTAB_CONFIG5" '
                 '"$SYSTEM_FSTAB_CONFIG6"'],
                env=dict(os.environ, SYSTEM_CONFIG=str(system_config)),
                text=True, capture_output=True)
            self.assertEqual(loaded.returncode, 0, loaded.stderr)
            self.assertEqual(loaded.stdout.splitlines(), [
                '1', 'UUID=abc /data ext4 defaults 0 2',
                'tmpfs /var/log tmpfs rw,nosuid 0 0', 'NONE', '', 'UUID=abc',
                'UUID=def /backup ext4 defaults 0 2'])

    def test_fstab_new_values_precede_legacy_values(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('FSTAB=1\nFSTAB_CONFIG1="old row"\n'
                            'FSTAB_CONFIG2="new row"\nFSTAB_CONFIG6="sixth row"\n')
            system_config.write_text('export SYSTEM_FSTAB=0\n'
                                     'export SYSTEM_FSTAB_CONFIG1=existing\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            loaded = subprocess.run(
                ['bash', '-c', 'source "$SYSTEM_CONFIG"; printf "%s\\n" '
                 '"$SYSTEM_FSTAB" "$SYSTEM_FSTAB_CONFIG1" "$SYSTEM_FSTAB_CONFIG2"'],
                env=dict(os.environ, SYSTEM_CONFIG=str(system_config)),
                text=True, capture_output=True)
            self.assertEqual(loaded.returncode, 0, loaded.stderr)
            self.assertEqual(loaded.stdout.splitlines(), ['0', 'existing', 'new row'])
            self.assertIn('export SYSTEM_FSTAB_CONFIG6=sixth\\ row',
                          system_config.read_text())

    def test_ambiguous_fstab_values_are_not_executed_or_removed(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            sentinel = Path(directory) / 'executed'
            original = f'FSTAB=1\nFSTAB_CONFIG1="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertFalse((Path(directory) / 'system.env').exists())
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_files2ram_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('FILES2RAM=1\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_FILES2RAM=1\n')

            path.write_text('export FILES2RAM=1\n')
            system_config.write_text('export SYSTEM_FILES2RAM=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_FILES2RAM=0\n')

    def test_grub_config_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('GRUB_CONFIG=0\nexport GRUB_CONFIG=1 # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_GRUB_CONFIG=1\n')

            path.write_text('export GRUB_CONFIG=1\n')
            system_config.write_text('export SYSTEM_GRUB_CONFIG=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_GRUB_CONFIG=0\n')

            path.write_text('export GRUB_CONFIG=0\n')
            system_config.unlink()
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_GRUB_CONFIG=0\n')

    def test_ambiguous_grub_config_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            sentinel = Path(directory) / 'executed'
            original = f'GRUB_CONFIG="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config = Path(directory) / 'system.env'
            system_config.write_text('export SYSTEM_GRUB_CONFIG=1\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_GRUB_CONFIG=1\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_ipv6_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('IPv6=0\nexport IPv6=1 # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_IPV6=1\n')

            path.write_text('export IPv6=0\n')
            system_config.write_text('export SYSTEM_IPV6=1\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_IPV6=1\n')

            system_config.unlink()
            path.write_text('IPv6=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_IPV6=0\n')

    def test_ambiguous_ipv6_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'IPv6="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_IPV6=1\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_IPV6=1\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_log_rotate_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('LOG_ROTATE=0\nexport LOG_ROTATE=1 # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_LOG_ROTATE=1\n')

            path.write_text('export LOG_ROTATE=1\n')
            system_config.write_text('export SYSTEM_LOG_ROTATE=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_LOG_ROTATE=0\n')

            system_config.unlink()
            path.write_text('LOG_ROTATE=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_LOG_ROTATE=0\n')

    def test_ambiguous_log_rotate_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'LOG_ROTATE="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_LOG_ROTATE=1\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_LOG_ROTATE=1\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_journald_max_use_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('JOURNALD_MAX_USE=100M\nexport JOURNALD_MAX_USE="500M" # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=500M\n')

            path.write_text("export JOURNALD_MAX_USE='1G'\n")
            system_config.write_text('export SYSTEM_JOURNALD_MAX_USE=250M\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=250M\n')

    def test_ambiguous_journald_max_use_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'JOURNALD_MAX_USE="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_JOURNALD_MAX_USE=500M\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=500M\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_journald_keep_free_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('JOURNALD_KEEP_FREE=500M\nexport JOURNALD_KEEP_FREE="1G" # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_KEEP_FREE=1G\n')

            path.write_text("export JOURNALD_KEEP_FREE='2G'\n")
            system_config.write_text('export SYSTEM_JOURNALD_KEEP_FREE=500M\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_KEEP_FREE=500M\n')

    def test_ambiguous_journald_keep_free_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'JOURNALD_KEEP_FREE="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_JOURNALD_KEEP_FREE=1G\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_KEEP_FREE=1G\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_no_sleep_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('NO_SLEEP=0\nexport NO_SLEEP=1 # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_NO_SLEEP=1\n')

            path.write_text('export NO_SLEEP=0\n')
            system_config.write_text('export SYSTEM_NO_SLEEP=1\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_NO_SLEEP=1\n')

            system_config.unlink()
            path.write_text('NO_SLEEP=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_NO_SLEEP=0\n')

    def test_ambiguous_no_sleep_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'NO_SLEEP="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_NO_SLEEP=1\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_NO_SLEEP=1\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_apache2_migration_to_softwares_scope_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            softwares_config = Path(directory) / 'softwares.env'
            path.write_text('APACHE2=0\nexport APACHE2=1 # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(softwares_config.read_text(), 'export SOFTWARES_APT_APACHE2=1\n')
            self.assertFalse((Path(directory) / 'system.env').exists())

            path.write_text('export APACHE2=1\n')
            softwares_config.write_text('export SOFTWARES_APT_APACHE2=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(softwares_config.read_text(), 'export SOFTWARES_APT_APACHE2=0\n')

            softwares_config.unlink()
            path.write_text('APACHE2=0\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(softwares_config.read_text(), 'export SOFTWARES_APT_APACHE2=0\n')

    def test_ambiguous_apache2_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            softwares_config = Path(directory) / 'softwares.env'
            sentinel = Path(directory) / 'executed'
            original = f'APACHE2="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            softwares_config.write_text('export SOFTWARES_APT_APACHE2=1\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(softwares_config.read_text(), 'export SOFTWARES_APT_APACHE2=1\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_journald_max_use_migration_and_precedence(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            path.write_text('JOURNALD_MAX_USE=100M\nexport JOURNALD_MAX_USE="500M" # active\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=500M\n')

            path.write_text("export JOURNALD_MAX_USE='1G'\n")
            system_config.write_text('export SYSTEM_JOURNALD_MAX_USE=250M\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), '')
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=250M\n')

    def test_ambiguous_journald_max_use_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            system_config = Path(directory) / 'system.env'
            sentinel = Path(directory) / 'executed'
            original = f'JOURNALD_MAX_USE="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            system_config.write_text('export SYSTEM_JOURNALD_MAX_USE=500M\n')
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertEqual(system_config.read_text(), 'export SYSTEM_JOURNALD_MAX_USE=500M\n')
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_ambiguous_files2ram_is_preserved_without_exposure(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            sentinel = Path(directory) / 'executed'
            original = f'FILES2RAM="$(touch {sentinel})"\nOTHER=keep\n'
            path.write_text(original)
            result = self.run_cleanup(path)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(), original)
            self.assertFalse((Path(directory) / 'system.env').exists())
            self.assertFalse(sentinel.exists())
            self.assertNotIn(str(sentinel), result.stderr)
            self.assertEqual(result.stdout, '')

    def test_missing_file(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'missing.sh'
            self.assertEqual(self.run_cleanup(path).returncode, 0)
            self.assertFalse(path.exists())

    def test_debian_type_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export DEBIAN_TYPE="PROXMOX"\nOTHER=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')
            self.assertEqual(result.stdout, '')

    def test_display_link_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            original = 'export DISPLAY_LINK="1"\nOTHER=keep\n'
            path.write_text(original)
            for prelude in ('grep() { return 2; }', 'sed() { return 1; }'):
                result = self.run_cleanup(path, prelude)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(path.read_text(), original)
                self.assertEqual(result.stdout, '')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'OTHER=keep\n')

    def test_proxy_ca_only(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            path.write_text('export PROXY_CA=1\nSYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n')
            result = self.run_cleanup(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(path.read_text(), 'SYSTEM_PROXY_CA=0\nPROXY_CA_EXTRA=keep\n')
            self.assertEqual(result.stdout, '')

    def test_read_and_write_errors(self):
        with tempfile.TemporaryDirectory(dir=ROOT) as directory:
            path = Path(directory) / 'variables.sh'
            original = 'DEBIAN_RELEASE=old\n'
            path.write_text(original)
            for prelude in ('grep() { return 2; }', 'sed() { return 1; }'):
                result = self.run_cleanup(path, prelude)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Erreur', result.stderr)
                self.assertEqual(result.stdout, '')
                self.assertEqual(path.read_text(), original)

    def test_startup_order_and_consumers(self):
        text = (ROOT / 'root-install-debian.sh').read_text()
        self.assertLess(text.index('modules/system/variables-cleanup.sh'), text.index('config_cleanup || exit 1'))
        self.assertLess(text.index('config_cleanup || exit 1'), text.index('. "/root/diu/variables.sh"'))
        self.assertNotRegex(text, r'\bDEBIAN_RELEASE\b')
        self.assertIn('SYSTEM_DEBIAN_RELEASE', text)
        self.assertNotRegex(text, r'\bTIME_ZONE\b')
        self.assertIn('timedatectl set-timezone "$SYSTEM_TIME_ZONE"', text)
        self.assertNotRegex(text, r'\bDEBIAN_TYPE\b')
        self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT', text)
        self.assertNotRegex(text, r'\bDISPLAY_LINK\b')
        self.assertIn('PROXY_CA', (ROOT / 'modules/system/variables-cleanup.sh').read_text())
        self.assertNotRegex(text, r'\bPROXY_CA\b')
        self.assertNotRegex(text, r'\$(?:\{)?DRIVERS_NVIDIA(?:\})?(?![A-Z0-9_])')
        self.assertEqual(text.count('if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]'), 6)
        self.assertNotRegex(text, r'\$(?:\{)?FILES2RAM(?:\})?(?![A-Z0-9_])')
        self.assertIn('if [[ "${SYSTEM_FILES2RAM:-0}" == "1" ]]', text)
        self.assertNotRegex(text, r'\$(?:\{)?GRUB_CONFIG(?:\})?(?![A-Z0-9_])')
        self.assertIn('if [[ "${SYSTEM_GRUB_CONFIG:-0}" == "1" ]]', text)
        self.assertNotRegex(text, r'\$(?:\{)?IPv6(?:\})?(?![A-Z0-9_])')
        self.assertIn('if [[ "${SYSTEM_IPV6:-0}" == "1" ]]', text)
        self.assertNotRegex(text, r'\$(?:\{)?LOG_ROTATE(?:\})?(?![A-Z0-9_])')
        self.assertIn('if [[ "${SYSTEM_LOG_ROTATE:-0}" == "1" ]]', text)
        self.assertIn('. "$BASH_SCRIPT_PATH/modules/system/drivers.sh"', text)
        drivers = (ROOT / 'modules/system/drivers.sh').read_text()
        self.assertNotRegex(drivers, r'\bDISPLAY_LINK\b')
        self.assertIn('SYSTEM_DRIVERS_DISPLAY_LINK', drivers)


if __name__ == '__main__':
    unittest.main()
