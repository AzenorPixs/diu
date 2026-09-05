## Why

Le DIU doit exposer le nom de code de la distribution courante en minuscules.

## What Changes

- Ajouter SYSTEM_DEBIAN_RELEASE, DYNAMIC, ENABLE, scope system.
- Déclarer son générateur dans modules/diu/variables/system/system_debian_release.sh.
- Tester la génération et les erreurs sans modifier le système.

## Capabilities

### New Capabilities

- `system-debian-release` : identification dynamique du nom de code de la distribution.

### Modified Capabilities

Aucune.

## Impact

Une déclaration découverte automatiquement par config_generator et des tests dédiés.
Aucune dépendance nouvelle, aucune migration des variables historiques.
