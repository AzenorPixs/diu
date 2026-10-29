# PRJ17 — Personnalisation de PG_DATABASE lors du clonage

## Why

Un projet cloné peut conserver dans `project.env` le nom de la base PostgreSQL
du projet source. La destination doit utiliser son propre identifiant lorsqu'une
variable `PG_DATABASE` est configurée.

## What Changes

- Remplacer conditionnellement `PG_DATABASE` par l'identifiant de destination
  dans le `project.env` cloné.
- Préserver les fichiers qui ne définissent pas cette variable.

## Capabilities

### Modified Capabilities

- `projects-clone`: personnalisation de la configuration PostgreSQL clonée.

## Impact

La fonction `clone_project`, sa spécification et ses tests ciblés sont
concernés. Aucune dépendance, opération réseau, commande Git ni modification
du projet source ne sont introduites.
