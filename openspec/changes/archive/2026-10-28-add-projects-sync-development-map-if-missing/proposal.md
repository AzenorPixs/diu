# Copie initiale de DEVELOPMENT_MAP.md pendant la synchronisation

## Why

La synchronisation ne distribue pas DEVELOPMENT_MAP.md. Le développeur demande
de l'initialiser depuis le modèle uniquement lorsqu'il est absent du projet,
sans écraser une carte de développement existante.

## What Changes

- Ajouter DEVELOPMENT_MAP.md aux copies conditionnelles de sync_project.
- Préserver toute entrée destination existante, y compris lien ou répertoire.
- Exiger une source régulière seulement lorsqu'une copie est nécessaire ;
  échouer avant les copies du modèle si cette source est indisponible.
- Appliquer à la nouvelle copie la personnalisation Markdown et le propriétaire
  existants, indépendamment de PROJECT_ORCHESTRATED_CODING.
- Couvrir les parcours unitaire, groupé et les réexécutions par des tests isolés.

## Impact

- Spécification : projects-sync ; projects-sync-all réutilise déjà son contrat.
- Code : modules/projects/projects.sh, fonction sync_project uniquement.
- Tests : tests/test_projects_development_map.py ; modèles synthétiques de
  tests/test_projects.py et tests/test_projects_orchestrated_copy.py adaptés
  au nouveau prérequis conditionnel, sans modifier leurs assertions.
- Documentation : TECHNICAL.md, README.md, CHANGELOG.md.
- Aucun changement de commande, configuration, dépendance ou création de projet.
- Aucun lancement de synchronisation sur les projets réels ni installation.
- Archivage et STATISTICS.md après validation ; clôture Git selon SCM.

## Autorisation

Périmètre autonome proposé puis explicitement validé par le développeur dans
ce chat le 28 octobre 2026. Change limité à la copie initiale demandée.
