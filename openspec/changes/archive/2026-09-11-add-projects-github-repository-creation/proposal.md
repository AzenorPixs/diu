## Why

Un premier push GitHub échoue lorsque le dépôt distant n'a pas été créé au
préalable. Le DIU connaît déjà l'URL cible et les identifiants associés ; il
peut donc signaler l'absence du dépôt et proposer une création contrôlée.

## What Changes

- Vérifier l'existence du dépôt GitHub configuré avant de créer le remote local.
- Demander une confirmation explicite avant de créer un dépôt absent.
- Demander sa visibilité, avec `private` comme valeur par défaut.
- Protéger le token dans les appels API comme dans le flux Git existant.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `implement-projects-github-push`: créer de manière confirmée le dépôt GitHub absent avant sa première publication.

## Impact

- `lib/github-auth.sh` pour les appels API GitHub authentifiés.
- `modules/projects/git.sh` pour intégrer la vérification avant le remote et le push.
- Le token GitHub doit disposer de `Administration: Read and write` si une création de dépôt est demandée.
