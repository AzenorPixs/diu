# DEV17 — Détection déclarative de Nuitka

## Why

L’inventaire conditionnel Cython est livré. Le développeur demande et valide sa réciproque pour Nuitka, déclaré dans pyproject.toml, avec une rubrique commune et les mêmes garanties de sondage.

## What Changes

- Reconnaître Nuitka dans [build-system].requires, sans distinction de casse, avec contraintes ou extras comme Nuitka[build-wheel].
- Émettre uniquement les outils déclarés, dans une seule rubrique Python - Outils de compilation, Cython puis Nuitka.
- Relever chaque version et provenance dans les venv du projet ou distinguer absence vérifiée et installation non vérifiable.
- Préserver le format 0.7, les trois parcours, le comportement Cython et les dépendances d’exécution.
- Ne pas installer, compiler, importer les outils ni modifier de manifeste ou de backend.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops` : ajout Nuitka et coexistence avec Cython.

## Impact

modules/projects/template.sh, tests/test_projects_template_devops.py, TECHNICAL.md, README.md, CHANGELOG.md et la spécification DevOps. Nouveau change validé par le développeur, tests, synchronisation, archivage et rapport inclus. Aucune nouvelle dépendance ou CLI ; application aux documents existants à leur prochaine génération normale.
