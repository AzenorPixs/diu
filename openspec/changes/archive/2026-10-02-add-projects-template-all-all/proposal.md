# PRJ06 — Application de tous les modèles à tous les projets

## Why

Le développeur demande tous les modèles pour tous les projets configurés,
avec DevOps en dernier dans chaque projet, et valide le cycle SCM jusqu'à
l'archivage. Sa correction explicite inclut les commandes help.

## What Changes

- Ajouter `rid projects template all all` et projects_template_all_all.
- Réutiliser la sélection project.env des traitements groupés existants.
- Exécuter OpenSpec puis DevOps pour chaque projet ; un échec OpenSpec
  empêche DevOps pour ce projet et le traitement poursuit les projets suivants.
- Afficher un bilan par projet et rendre un code non nul en cas d'échec.
- Actualiser aides, documentation et tests isolés.

## Capabilities

### New Capabilities

- `projects-template-all`: Tous les modèles, avec DevOps en dernier, pour tous les projets configurés.

### Modified Capabilities

- `rid-help`: Découverte et aide de template all all.

## Impact

modules/projects/template.sh, root-install-debian.sh, lib/rid-help.sh,
TECHNICAL.md, tests/test_projects_template_all.py,
tests/test_projects_template_devops.py et tests/test_rid_help.py.
Les commandes existantes et create sont conservés ; all avec un identifiant
individuel n'est pas ajouté. Aucun projet réel, effet Git, installation,
infrastructure ou autre change n'entre dans ce périmètre.
