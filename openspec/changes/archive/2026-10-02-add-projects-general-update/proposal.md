## Why

Le développeur demande une mise à jour générale des projets qui applique
tous les modèles à tous les projets configurés et soit appelée par rid update.
Le périmètre SCM, aides, tests et archivage inclus, a été validé explicitement.

## What Changes

- Rendre projects_update effective en appelant projects_template_all_all.
- Router rid projects update sans argument vers projects_update.
- Préserver rid projects update <ID PROJECT> pour les variables générales.
- Répercuter l'échec de projects_update dans le résultat de rid update,
  sans modifier l'ordre des modules ni intégrer une autre opération projects.
- Documenter les deux usages et actualiser les aides help et ?.

## Capabilities

### New Capabilities

- `projects-general-update`: Mise à jour générale des modèles des projets.

### Modified Capabilities

- `universal-update`: Répercussion d'un échec de la mise à jour des projets.
- `rid-help`: Aides distinctes de mise à jour générale et ciblée des projets.

## Impact

modules/projects/projects.sh, root-install-debian.sh,
modules/diu/update-all.sh, lib/rid-help.sh, TECHNICAL.md,
tests/test_projects_general_update.py et tests/test_rid_help.py.
Sélection, ordre OpenSpec puis DevOps et bilan restent délégués aux modèles.
Pas de sync all, modification Git, fournisseur, installation, configuration
réelle ou refonte générale. La divergence préexistante entre la description
d'une orchestration globale enrichie dans TECHNICAL.md et le parcours simple
actuel reste signalée et hors du périmètre de correction.
