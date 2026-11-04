# PRJ08 — Préparation OpenSpec groupée

## Why

Le développeur demande le traitement groupé OpenSpec réciproque à DevOps all,
et a validé le périmètre autonome de spécification jusqu'à l'archivage.

## What Changes

- Ajouter projects_template_openspec_all et router `rid projects template openspec all` vers cette fonction.
- Réutiliser la sélection existante des projets configurés, avec cinq variables
  littérales non vides et un PROJECT_ID correspondant au dossier.
- Appeler la fonction individuelle existante pour chaque projet, poursuivre
  après échec et afficher un bilan avec code non nul en cas d'échec.
- Adapter aides, documentation et tests isolés.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-template-openspec`: Sélection, traitement groupé et bilan.
- `rid-help`: Découverte et aide du traitement OpenSpec groupé.

## Impact

modules/projects/template.sh, root-install-debian.sh, lib/rid-help.sh,
TECHNICAL.md, tests/test_projects_template_openspec.py,
tests/test_projects_template_devops.py et tests/test_rid_help.py.
All devient réservé au traitement groupé dans la CLI OpenSpec. Un dossier
all reste éligible dans la boucle et la fonction individuelle peut le traiter
directement. Aucun autre change, projet réel, installation ou opération Git
n'est modifié.
