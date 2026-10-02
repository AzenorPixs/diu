#!/usr/bin/env python3
"""Politique Docker et coexistence avec DevOps dans des fixtures isolées."""
import unittest

import test_devops_sudoers as sudoers_tests


class DockerSudoersTests(sudoers_tests.DevopsSudoersTests):
    SCOPE = 'docker'
    LABEL = 'Docker'
    TARGET = 'containers'

    def test_configured_docker_target_is_used(self):
        self.passwd.write_text(self.passwd.read_text().replace('containers', 'dock-worker'))
        result = self.run_generator(target='dock-worker')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text(),
                         '# Managed by DIU: local human accounts to Docker\n'
                         'alice ALL=(dock-worker) NOPASSWD: ALL\n'
                         'bob ALL=(dock-worker) NOPASSWD: ALL\n')

    def test_both_environments_coexist_in_either_order(self):
        for first, second in (('devops', 'docker'), ('docker', 'devops')):
            with self.subTest(first=first):
                targets = {'devops': 'builder', 'docker': 'containers'}
                result = self.run_generator(scope=first, target=targets[first])
                self.assertEqual(result.returncode, 0, result.stderr)
                first_file = self.sudoers / f'99-diu-{first}'
                original = first_file.read_bytes()
                result = self.run_generator(scope=second, target=targets[second])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(first_file.read_bytes(), original)
                self.assertIn('alice ALL=(builder)',
                              (self.sudoers / '99-diu-devops').read_text())
                self.assertIn('alice ALL=(containers)', self.destination.read_text())
                self.assert_no_candidate()

    def test_docker_failure_keeps_devops_policy(self):
        result = self.run_generator(scope='devops', target='builder')
        self.assertEqual(result.returncode, 0, result.stderr)
        devops = self.sudoers / '99-diu-devops'
        original = devops.read_bytes()
        self.destination.write_text('# previous Docker policy\n')
        result = self.run_generator(fault='visudo')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(devops.read_bytes(), original)
        self.assertEqual(self.destination.read_text(), '# previous Docker policy\n')
        self.assert_no_candidate()

    def test_unknown_scope_cannot_publish(self):
        self.destination.write_text('# previous Docker policy\n')
        for scope in ('', 'unknown', '../../outside'):
            with self.subTest(scope=scope):
                result = self.run_generator(scope=scope)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('environnement inconnu', result.stderr)
                self.assertEqual(self.destination.read_text(), '# previous Docker policy\n')
                self.assertFalse(self.calls.exists())
                self.assert_no_candidate()


if __name__ == '__main__':
    unittest.main()
