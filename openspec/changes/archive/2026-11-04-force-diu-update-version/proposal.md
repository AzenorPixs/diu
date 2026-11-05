# Installer une version DIU explicitement demandée

## Why

La mise à jour automatique ne permet pas de réinstaller ou de retrouver une version disponible sur GitHub.

## What Changes

- Accepter `rid diu update <VERSION>` et installer la version exacte disponible sur GitHub, indépendamment de la version installée.
- Conserver le fonctionnement automatique sans version et les contrôles du paquet.
- Documenter la syntaxe dans l’aide et les documents publics.

## Capabilities

### Modified Capabilities

- `diu-package-update`: sélection et réinstallation d’une version explicitement demandée.

## Impact

Routage, moteur de mise à jour, aide, tests et documentation. Aucune installation réelle pendant les validations.
