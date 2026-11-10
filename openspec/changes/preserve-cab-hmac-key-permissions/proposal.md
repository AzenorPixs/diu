# Préserver les droits des clés HMAC CAB

## Why

La normalisation DevOps limite les droits des fichiers du compte et maintient la compatibilité des clés HMAC CAB avec les contrôles de CAB.

## What Changes

- Normaliser en 0770 les seules clés `*.hmac.key` du répertoire de journal CAB du compte DevOps.
- Appliquer 2770 aux répertoires et 0770 aux fichiers ordinaires ; conserver les règles spécifiques des fichiers sensibles et ne pas suivre les liens symboliques.

## Capabilities

### New Capabilities
- `devops-cab-hmac-permissions`: Normalisation ciblée et sûre des droits de la clé HMAC CAB.

### Modified Capabilities

## Impact

Initialisation DevOps DIU, tests et documentation ; CAB doit accepter le mode 0770 sous ses propres contrôles.
