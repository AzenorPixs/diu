## Why

Les informations réseau restent monolithiques et les modules ne disposent pas
d'une interface commune d'information.

## What Changes

- Extraire display_infos en system_info_network dans modules/system/infos.sh.
- Ajouter les informations Debian, les agrégateurs système et global et les
  commandes infos de sept modules, avec leur aide contextuelle.
- Préserver les affichages réseau et les commandes existantes.

## Capabilities

### New Capabilities
- `module-infos`: informations de module et agrégation globale.

### Modified Capabilities
- `rid-help`: aide des commandes infos.

## Impact

Sept fichiers modules/*/infos.sh, bootstrap/routage monolithique,
modules/system/apt.sh, lib/rid-help.sh, tests et TECHNICAL.md.
Aucune opération système ou Git pendant les validations.
