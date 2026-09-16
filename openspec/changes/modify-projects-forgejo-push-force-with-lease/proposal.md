## Why

Le push Forgejo d'une branche locale doit pouvoir mettre à jour la branche
distante tout en refusant d'écraser une modification distante inconnue
localement.

## What Changes

- Ajouter `--force-with-lease` au push de branche du parcours Forgejo.
- Conserver le push des tags sans option de forçage.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `implement-projects-forgejo-push`: protection du push de branche par
  `--force-with-lease`.

## Impact

- `modules/projects/git.sh` pour les arguments transmis au provider Forgejo.
- `tests/test_rid_help.py` pour la vérification ciblée du push de branche.
