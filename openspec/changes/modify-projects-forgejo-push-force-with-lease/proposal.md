## Why

Le push Forgejo d'une branche locale doit pouvoir mettre à jour la branche
distante tout en refusant d'écraser une modification distante inconnue
localement.

## What Changes

- Récupérer les références Forgejo authentifiées avant le push de branche,
  puis ajouter `--force-with-lease` à ce push.
- Conserver le push des tags sans option de forçage.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `implement-projects-forgejo-push`: protection du push de branche par
  `--force-with-lease`.

## Impact

- `modules/projects/git.sh` et `lib/forgejo-auth.sh` pour la récupération des
  références et les arguments transmis au provider Forgejo.
- `tests/test_rid_help.py` pour la vérification ciblée du push de branche.
