import os
import subprocess
import tempfile
import unittest
from pathlib import Path


class DevopsCabHmacPermissionsTest(unittest.TestCase):
    def test_normalization_targets_only_real_cab_keys(self):
        source = (Path(__file__).resolve().parents[1] / 'root-install-debian.sh').read_text()
        lines = [line.strip() for line in source.splitlines()
                 if 'find /home/"$ENV_DEVOPS_USER" -type f' in line and '*.hmac.key' in line]
        self.assertEqual(len(lines), 2)
        commands = [line.replace('/home/"$ENV_DEVOPS_USER"', '"$fixture_root"')
                    .replace('/home/$ENV_DEVOPS_USER/', '${fixture_root}/') for line in lines]
        with tempfile.TemporaryDirectory(prefix='diu-hmac-') as temporary:
            root = Path(temporary)
            journal = root / '.opencode/state/cgpt-approval-bridge'
            journal.mkdir(parents=True)
            key = journal / 'events.ndjson.hmac.key'
            neighbour = journal / 'events.ndjson'
            outside = root / 'outside'
            for path in (key, neighbour, outside):
                path.write_text('fixture')
                path.chmod(0o600)
            (journal / 'linked.hmac.key').symlink_to(outside)
            script = 'fixture_root=$1\n' + '\n'.join(commands)
            subprocess.run(['bash', '-c', script, 'fixture', str(root)], check=True)
            self.assertEqual(key.stat().st_mode & 0o777, 0o770)
            self.assertEqual(neighbour.stat().st_mode & 0o777, 0o775)
            # The ordinary outside file is normalized once, but never through the link.
            outside.chmod(0o600)
            subprocess.run(['bash', '-c', 'fixture_root=$1\n' + commands[1], 'fixture', str(root)], check=True)
            self.assertEqual(outside.stat().st_mode & 0o777, 0o600)
            self.assertTrue((journal / 'linked.hmac.key').is_symlink())


if __name__ == '__main__':
    unittest.main()
