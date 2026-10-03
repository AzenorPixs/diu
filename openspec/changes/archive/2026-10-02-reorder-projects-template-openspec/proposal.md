## Why

Le développeur demande de placer openspec avant l'identifiant de projet et a
validé le périmètre autonome de spécification, implémentation et archivage.

## What Changes

- Remplacer la syntaxe OpenSpec par `rid projects template openspec <ID PROJECT>`.
- Réserver openspec après template, avec priorité sur le routage DevOps.
- Rejeter l'ancienne syntaxe et adapter les aides, diagnostics, documentation
  technique et tests.
- Conserver les trois commandes OpenSpec, le compte d'exécution et l'appel
  avant DevOps lors de la création.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-template-openspec`: Nouvelle position de l'identifiant dans la CLI.
- `rid-help`: Nouvelle syntaxe et aides intermédiaire et terminale.

## Impact

root-install-debian.sh, lib/rid-help.sh, le diagnostic de
modules/projects/template.sh, TECHNICAL.md, tests/test_rid_help.py et
tests/test_projects_template_devops.py. Les autres changes et les opérations
Git restent hors périmètre. Incompatibilité acceptée : openspec est désormais
prioritaire ; template openspec devops vise OpenSpec pour le projet devops.
