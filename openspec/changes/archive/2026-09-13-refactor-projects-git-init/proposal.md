# GIT14 — Initialisation Git dans le contexte projects git

## Why

La commande publique d'initialisation Git utilise actuellement l'abréviation
isolée `giti`, alors que les opérations Git sont regroupées sous
`rid projects git`. Cette incohérence rend l'interface moins prévisible et
l'aide contextuelle incomplète.

## What Changes

- Exposer l'initialisation d'un dépôt local avec
  `rid projects git init <ID PROJECT>`.
- **BREAKING** Retirer la commande publique historique
  `rid projects giti <ID PROJECT>`.
- Afficher la nouvelle commande dans les aides `rid projects help` et
  `rid projects git help`.

## Capabilities

### New Capabilities

- `projects-git-init`: Routage public de l'initialisation d'un dépôt Git
  local de projet.

### Modified Capabilities

- `rid-help`: L'aide contextuelle des projets et du sous-contexte Git expose
  la commande d'initialisation canonique et ne présente plus l'alias retiré.

## Impact

Le dispatch de `root-install-debian.sh`, l'aide de `lib/rid-help.sh` et les
tests d'aide ciblés sont concernés. Aucune dépendance, configuration ni
fonction `git_init` n'est modifiée.
