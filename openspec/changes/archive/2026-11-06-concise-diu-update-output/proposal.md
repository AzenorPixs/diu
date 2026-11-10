# Sortie synthétique de la mise à jour DIU

## Why

La vérification à jour utilise un symbole d'information et l'installation expose ses détails techniques au lieu d'un résultat concis.

## What Changes

- Signaler le succès avec une coche lorsque DIU est déjà à jour ou a été installé.
- Masquer les détails techniques en cas de succès et les restituer en cas d'échec.
- Préserver sélection, secours, vérifications et installation d'une version explicite.
- Faire exécuter le parcours `hosts update` par la mise à jour réseau et expliciter les aides réseau.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `diu-package-update` : présentation du résultat et des diagnostics.
- `system-network-hosts` : parcours et résultat communs aux mises à jour réseau et hosts.
- `diu-help` : accès aux aides réseau et description exacte de hosts.

## Impact

Modules de mise à jour DIU et réseau, aide, tests isolés, documentation technique et historique. Aucun changement de syntaxe ou de dépendance.
