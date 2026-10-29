# DEV08 — Priorité aux environnements Python des projets

## Why

Les dépendances de DEVOPS.md sont recherchées uniquement dans le Python DevOps. Une distribution installée dans un venv du projet peut donc être présentée comme non installée et son emplacement réel reste invisible.

## What Changes

- Générer le format documentaire 0.4.
- Découvrir les venv du projet et préférer leurs distributions par dépendance, avec priorité déterministe puis repli DevOps explicite.
- Publier l'environnement, le chemin d'entrée Python et l'installation observée, sans inventer un chemin depuis le nom du paquet.
- Distinguer absence vérifiée et sonde/recherche impossible ; préserver l'isolation, les bornes et les garanties documentaires existantes.
- Actualiser légende, cadrage technique, README et changelog.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- projects-template-devops : dépendances issues prioritairement des venv du projet, provenance réelle et version documentaire 0.4.

## Impact

modules/projects/template.sh, tests/test_projects_template_devops.py, TECHNICAL.md, README.md, CHANGELOG.md et le seul canon projects-template-devops. Aucun environnement réel activé, paquet installé, fichier de projet réel régénéré, changement Git ou nouvelle dépendance. Création du change, implémentation, validations et archivage autorisés par le développeur, qui a demandé Version : 0.4. Les autres changes restent hors périmètre.
