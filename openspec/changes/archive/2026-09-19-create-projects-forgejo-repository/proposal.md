# GIT21 — Proposal

## Why

Le parcours `rid projects forgejo push <ID PROJECT>` accepte un dépôt Forgejo
absent, mais récupère ses références avant le push. Cette récupération échoue
sur un dépôt absent et empêche donc la première publication.

## What Changes

- Créer explicitement, via l'API Forgejo authentifiée, le dépôt distant absent
  avant toute récupération de références.
- Prendre en charge le propriétaire utilisateur authentifié et le propriétaire
  organisation ; refuser explicitement un compte utilisateur distinct, qui
  nécessiterait un privilège d'administration non demandé.
- Conserver le dépôt vide à la création, puis récupérer les références et
  publier la branche avec `--force-with-lease` et le tag éventuel.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `forgejo-auth`: création API sécurisée d'un dépôt Forgejo absent.
- `implement-projects-forgejo-push`: création du dépôt absent avant le fetch
  et la publication.

## Impact

- `lib/forgejo-auth.sh` pour la détection et la création du dépôt via les
  helpers API existants.
- `modules/projects/git.sh` pour l'ordonnancement création, fetch, push.
- `tests/test_rid_help.py` pour les scénarios Forgejo isolés.
