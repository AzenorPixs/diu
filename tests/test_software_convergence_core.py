import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "modules/softwares/convergence.sh"


class ConvergenceCoreTests(unittest.TestCase):
    def run_shell(self, body):
        script = 'source "$1"\n' + body
        return subprocess.run(
            ["bash", "-c", script, "--", str(CORE)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_matching_state_does_not_mutate(self):
        for state in ("0", "1"):
            with self.subTest(state=state):
                result = self.run_shell(
                    f'detect() {{ printf {state}; }}\n'
                    'install() { echo unexpected; return 1; }\n'
                    'remove() { echo unexpected; return 1; }\n'
                    f'software_converge demo {state} detect install remove'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f"état réel {state}, conforme", result.stdout)
                self.assertNotIn("unexpected", result.stdout)

    def test_mismatch_calls_correct_action_and_verifies(self):
        for desired, actual, expected in (("1", "0", "INSTALL"), ("0", "1", "REMOVE")):
            with self.subTest(desired=desired):
                result = self.run_shell(
                    f'detect() {{ if [[ $phase == before ]]; then printf {actual}; '
                    f'else printf {desired}; fi; }}\n'
                    'install() { echo INSTALL; phase=after; }\n'
                    'remove() { echo REMOVE; phase=after; }\n'
                    'phase=before\n'
                    f'software_converge demo {desired} detect install remove'
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(expected, result.stdout)
                self.assertIn(f"état réel {desired}, conforme", result.stdout)

    def test_detection_failure_and_bad_values_never_mutate(self):
        for detector in ('return 1', 'printf unknown'):
            with self.subTest(detector=detector):
                result = self.run_shell(
                    f'detect() {{ {detector}; }}\n'
                    'install() { echo unexpected; }\n'
                    'remove() { echo unexpected; }\n'
                    'software_converge demo 1 detect install remove'
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("unexpected", result.stdout)

    def test_action_failure_is_propagated(self):
        result = self.run_shell(
            'detect() { printf 0; }\n'
            'install() { return 1; }\n'
            'remove() { return 0; }\n'
            'software_converge demo 1 detect install remove'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("échec", result.stderr)

    def test_unchanged_state_after_action_is_failure(self):
        result = self.run_shell(
            'detect() { printf 0; }\n'
            'install() { return 0; }\n'
            'remove() { return 0; }\n'
            'software_converge demo 1 detect install remove'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("non confirmé", result.stderr)

    def test_unknown_configuration_stops_without_mutation(self):
        result = self.run_shell(
            'detect() { printf 1; }\n'
            'check() { return 2; }\n'
            'install() { echo unexpected; }\n'
            'remove() { echo unexpected; }\n'
            'software_converge demo 1 detect install remove check'
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("indéterminée", result.stderr)
        self.assertNotIn("unexpected", result.stdout)


if __name__ == "__main__":
    unittest.main()
