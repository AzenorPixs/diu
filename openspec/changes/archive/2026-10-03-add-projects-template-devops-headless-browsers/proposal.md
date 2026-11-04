# DEV05 — Inventaire des navigateurs pour les tests headless

## Why

La génération de DEVOPS.md ne documente pas les navigateurs externes de l'hôte
disponibles pour les tests headless. Le projet ne permet donc pas d'identifier
leurs versions et leurs chemins à partir de ce document généré.

## What Changes

- Ajouter en fin de DEVOPS.md la section « Tests navigateurs extérieurs en mode headless ».
- Documenter Chromium et Firefox avec leur version, leur chemin hôte et l'option --headless.
- Rechercher chromium puis chromium-browser, et firefox puis firefox-esr, dans le chemin système hôte déjà utilisé par le générateur.
- Réutiliser les sondes de version limitées à 15 secondes et signaler explicitement les absences et les échecs.
- Préserver l'ordre des rubriques existantes, la version documentaire 0.2, l'idempotence et les protections d'écriture.

La détection ne constitue pas un test de fonctionnement du mode headless.
Aucun navigateur, pilote ou outil de test n'est installé ou démarré pour naviguer.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops`: section finale de détection des navigateurs hôte.

## Impact

Le périmètre validé couvre modules/projects/template.sh,
tests/test_projects_template_devops.py, TECHNICAL.md, les artefacts de ce change,
la synchronisation de openspec/specs/projects-template-devops/spec.md et
l'archivage de ce seul change après validation complète.

La CLI conserve sa syntaxe. Les générations groupées et finales de création
bénéficient de la même section par réutilisation du générateur individuel.
Les autres cadrages, la configuration, les dépendances et Git restent hors périmètre.
