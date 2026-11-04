# SYS04 — Nettoyage de la variable Debian historique

## Why

Terminer la migration vers SYSTEM_DEBIAN_RELEASE et retirer la déclaration historique de variables.sh de manière idempotente.

## What Changes

- Ajouter config_cleanup avant le chargement de variables.sh.
- Remplacer tous les consommateurs de DEBIAN_RELEASE par SYSTEM_DEBIAN_RELEASE.
- Préserver la configuration locale et les valeurs système déjà définies.

## Capabilities

### New Capabilities

- `legacy-variable-cleanup`: nettoyage idempotent de la variable historique.

### Modified Capabilities

Aucune : la déclaration system-debian-release conserve son comportement.

## Impact

modules/system/variables-cleanup.sh, root-install-debian.sh, TECHNICAL.md et tests isolés.
Aucune dépendance supplémentaire. Les mentions historiques dans le nettoyage et ses tests restent nécessaires.
