# Préserver les droits des clés HMAC CAB

## Why

La normalisation récursive DevOps applique 0775 à la clé HMAC CAB. Le développeur a validé une normalisation spécifique en 0770 et une adaptation coordonnée de CAB.

## What Changes

- Normaliser en 0770 les seules clés `*.hmac.key` du répertoire de journal CAB du compte DevOps.
- Préserver les règles de tous les autres fichiers et ne pas suivre les liens symboliques.

## Capabilities

### New Capabilities
- `devops-cab-hmac-permissions`: Normalisation ciblée et sûre des droits de la clé HMAC CAB.

### Modified Capabilities

## Impact

Initialisation DevOps DIU, tests et documentation ; CAB doit accepter le mode 0770 sous ses propres contrôles.
