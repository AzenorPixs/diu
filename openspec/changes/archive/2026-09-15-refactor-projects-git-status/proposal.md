# GIT20 — Statut Git dans le contexte projects git

## Why

La commande de statut Git d'un projet utilise l'abréviation isolée `gits`,
alors que les opérations Git récentes sont regroupées sous `rid projects git`.
Ce renommage rend l'interface publique cohérente et son aide hiérarchique.

## What Changes

- Exposer le statut Git local par `rid projects git status <ID PROJECTS>`.
- **BREAKING** Retirer la commande publique historique
  `rid projects gits <ID PROJECTS>`.
- Mettre à jour les aides `rid projects help`, `rid projects git help` et
  `rid projects git status help`.

## Capabilities

### New Capabilities

- `projects-git-status`: Routage public du statut Git local d'un projet sous
  le sous-contexte `projects git`.

### Modified Capabilities

- `rid-help`: Les aides contextuelles présentent la commande canonique de
  statut Git et ne présentent plus l'alias retiré.

## Impact

Le dispatch de `root-install-debian.sh`, l'aide de `lib/rid-help.sh` et les
tests d'aide ciblés sont concernés. La fonction `git_status`, ses paramètres
et son comportement restent inchangés.
