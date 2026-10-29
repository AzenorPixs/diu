# DEV16 — Détection déclarative de Cython

## Why

Cython déclaré comme outil de compilation n’apparaît pas dans DEVOPS.md : le générateur ne lit que les dépendances d’exécution. Le développeur a validé une détection préalable dans pyproject.toml, suivie seulement en cas de déclaration d’une vérification locale.

## What Changes

- Reconnaître Cython dans [build-system].requires, sans distinction de casse.
- Générer « Python - Outils de compilation » uniquement après confirmation de cette déclaration, entre pip et Prompts.
- Relever version et provenance dans les venv du projet, ou distinguer absence établie et installation non vérifiable.
- Préserver les dépendances d’exécution, le format 0.7 et les parcours individuel, groupé et final de création.
- Ne pas installer de paquet, modifier de manifeste, compiler ni qualifier des extensions.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops` : inventaire conditionnel de Cython déclaré pour la construction.

## Impact

Générateur modules/projects/template.sh, tests/test_projects_template_devops.py, TECHNICAL.md, README.md et CHANGELOG.md. Aucun changement de CLI, de backend de construction ou de dépendance DIU ; les documents existants adoptent ce rendu lors de leur prochaine génération normale. Le cycle OpenSpec et le rapport d’archive sont inclus dans la validation du développeur.
