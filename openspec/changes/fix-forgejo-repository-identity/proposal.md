# GIT29 — Proposal

## Why

La vérification d'un dépôt Forgejo existant appelle l'endpoint `/user`, qui
renvoie HTTP 404 sur l'instance ciblée. Ce comportement bloque `rcicddiu`
alors que le token, le dépôt et l'identité Forgejo locale sont déjà validés.

## What Changes

- Réutiliser l'identifiant Forgejo local déjà lu et validé pour déterminer le
  propriétaire personnel du dépôt.
- Supprimer la requête API `/user` du parcours de vérification et de création.
- Construire les appels API avec le préfixe `/api/v1` requis par Forgejo.
- Éliminer les octets NUL des réponses API temporaires avant leur lecture Bash.
- Préserver l'absence de création pour un dépôt existant et le parcours
  identique de `rcicddiu` et `rid projects forgejo push all`.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

<!-- None : correction interne conforme aux spécifications existantes. -->

## Impact

- `lib/forgejo-auth.sh` pour la résolution du propriétaire.
- `tests/test_rid_help.py` pour la non-utilisation de l'endpoint `/user`.
