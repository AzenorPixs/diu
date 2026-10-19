## Why

Après copie d'un projet ou changement de destination, le remote Forgejo peut
encore pointer vers le modèle. Après correction de l'URL, sa référence de
suivi peut également rester héritée de l'ancien dépôt : le premier push vers
un dépôt absent est alors rejeté avec `stale info`.

## What Changes

- Aligner les URL de récupération et de publication du seul remote Forgejo
  configuré sur la destination déclarée dans `project.env`, avec diagnostic.
- Pour un dépôt annoncé absent, utiliser une attente explicite d'absence de
  la branche distante avec `--force-with-lease=refs/heads/<branche>:`.
- Conserver les références locales, le fetch des dépôts existants, les tags
  sans forçage et les comportements GitLab/GitHub.
- Documenter et tester les deux incidents, l'idempotence, les erreurs et la
  protection contre une création concurrente.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `implement-projects-forgejo-push` : réalignement du remote et premier push
  indépendant d'une référence de suivi héritée.

## Impact

- `modules/projects/git.sh`, `tests/test_projects_forgejo_push.py` et
  `tests/test_rid_help.py`.
- `TECHNICAL.md`, `README.md`, `CHANGELOG.md` et la spécification principale.
- Archivage de ce seul change et rapport `STATISTIQUES.md`.
- Aucun déploiement, modification du projet réel `prompts`, effet réseau,
  changement de credentials ou nouvelle dépendance.
