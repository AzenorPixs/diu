# Sortie synthétique de la mise à jour DIU

## Why

La vérification à jour utilise un symbole d'information et l'installation expose ses détails techniques au lieu d'un résultat concis.

## What Changes

- Signaler le succès avec une coche lorsque DIU est déjà à jour ou a été installé.
- Masquer les détails techniques en cas de succès et les restituer en cas d'échec.
- Préserver sélection, secours, vérifications et installation d'une version explicite.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `diu-package-update` : présentation du résultat et des diagnostics.

## Impact

Module de mise à jour DIU, tests isolés, documentation technique et historique. Aucun changement d'interface ou de dépendance.
