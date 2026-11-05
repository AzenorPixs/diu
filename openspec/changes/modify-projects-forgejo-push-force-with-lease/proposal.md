# GIT30 — Protection des publications Forgejo par force-with-lease

## Why

Le push Forgejo d'une branche locale doit pouvoir mettre à jour la branche
distante tout en refusant d'écraser une modification distante inconnue
localement.

## What Changes

- Récupérer les références Forgejo authentifiées avant le push de branche,
  puis ajouter `--force-with-lease` à ce push.
- Déclencher les push Forgejo, GitLab et GitHub sans confirmation interactive
  supplémentaire.
- Conserver le push des tags sans option de forçage.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `implement-projects-forgejo-push`: protection du push de branche par
  `--force-with-lease`.
- `implement-projects-gitlab-push`: publication sans confirmation de push.
- `implement-projects-github-push`: publication sans confirmation de push.

## Impact

- `modules/projects/git.sh` et `lib/forgejo-auth.sh` pour la récupération des
  références et les arguments transmis au provider Forgejo.
- `tests/test_diu_help.py` pour la vérification ciblée du push de branche et
  de l'absence de confirmation des trois fournisseurs.
