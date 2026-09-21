# Proposal

## Why

La création API d'un dépôt Forgejo absent échoue avec un token valide mais
restreint. Elle empêche Forgejo d'appliquer sa fonctionnalité configurée de
création du dépôt lors du premier push Git.

## What Changes

- Ne plus créer un dépôt absent via l'API Forgejo.
- Ignorer la récupération des références inexistantes et réaliser le premier
  push Git vers Forgejo.
- Préserver le fetch et `--force-with-lease` pour un dépôt déjà existant.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `forgejo-auth`: déléguer la création d'un dépôt absent au push Git Forgejo.
- `implement-projects-forgejo-push`: publier un premier push sans fetch
  préalable lorsque le dépôt est absent.

## Impact

- `lib/forgejo-auth.sh`, `modules/projects/git.sh` et les tests ciblés.
