# DEV04 — Réorganisation de la syntaxe template devops

## Why

Le développeur demande la même position du sélecteur pour DevOps et OpenSpec,
et a validé le périmètre autonome jusqu'à l'archivage.

## What Changes

- Exposer `rid projects template devops <ID PROJECT>` et
  `rid projects template devops all`.
- Adapter routage, aides, diagnostics, documentation technique et tests.
- Rejeter les anciennes syntaxes lorsqu'elles ne correspondent pas déjà à
  une commande valide dans la nouvelle interface.
- Conserver génération, sélection groupée, bilans, appel après OpenSpec
  lors de la création et syntaxe OpenSpec.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-template-devops`: Position du sélecteur pour génération individuelle et groupée.
- `rid-help`: Aides des templates DevOps et cohérence des références OpenSpec.
- `projects-template-openspec`: Cohérence de l'exception pour les anciens ordres
  qui correspondent désormais à une commande DevOps valide.

## Impact

root-install-debian.sh, lib/rid-help.sh, les diagnostics de
modules/projects/template.sh, TECHNICAL.md, tests/test_rid_help.py et
tests/test_projects_template_devops.py. Les alias et scripts utilisant
l'ancienne syntaxe devront être adaptés. Aucun autre change, opération Git,
installation ou projet réel n'est modifié.
