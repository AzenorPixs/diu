import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "modules/diu/update-playlist.sh"


class DiuConvergencePlaylistTests(unittest.TestCase):
    def run_shell(self, body):
        script = (
            'source "$1"\n'
            'diu_update() { echo diu; return "${DIU_STATUS:-0}"; }\n'
            'system_update() { echo system; return "${SYSTEM_STATUS:-0}"; }\n'
            'environments_update() { echo environments; return "${ENV_STATUS:-0}"; }\n'
            'ia_update() { echo ia; return "${IA_STATUS:-0}"; }\n'
            'projects_update() { echo projects; return "${PROJECT_STATUS:-0}"; }\n'
            'softwares_update() { echo softwares; return "${SOFTWARE_STATUS:-0}"; }\n'
            + body
        )
        return subprocess.run(["bash", "-c", script, "--", str(MODULE)],
                              text=True, capture_output=True, check=False)

    def test_playlist_calls_softwares_last_even_after_failures(self):
        result = self.run_shell('DIU_STATUS=3; PROJECT_STATUS=4\ndiu_update_playlist')
        self.assertEqual(result.returncode, 4)
        self.assertEqual(result.stdout.splitlines(), ["diu", "system", "environments", "ia", "projects", "softwares"])

    def test_softwares_failure_is_reported(self):
        result = self.run_shell('SOFTWARE_STATUS=5\ndiu_update_playlist')
        self.assertEqual(result.returncode, 5)
        self.assertEqual(result.stdout.splitlines()[-1], "softwares")


if __name__ == "__main__":
    unittest.main()
