import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class RemovedDebEngineTests(unittest.TestCase):
    def test_deb_commands_are_rejected_without_package_operations(self):
        script = r'''
source "$ROOT/modules/softwares/software.sh"
print_error() { :; }
software_deb() { echo UNEXPECTED; return 0; }
manage_software_action "$@"
'''
        for arguments in (('install', 'deb', 'geany'), ('remove', 'deb', 'geany'),
                          ('update', 'deb', 'geany'), ('update', 'deb')):
            with self.subTest(arguments=arguments):
                result = subprocess.run(['/bin/bash', '-c', script, 'test', *arguments],
                                        env={'ROOT': str(ROOT)}, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('UNEXPECTED', result.stdout)


if __name__ == '__main__':
    unittest.main()
