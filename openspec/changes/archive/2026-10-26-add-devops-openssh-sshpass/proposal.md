# DEV18 — Ajouter OpenSSH et SSHPASS au document DevOps

## Why

Le document généré ne décrit pas les outils locaux employés pour l’accès SSH aux environnements de test. Le développeur a validé le périmètre SCM le 26 octobre 2026.

## What Changes

- Ajouter une rubrique permanente OpenSSH & SSHPASS après les conteneurs éventuels et avant Docker-Compose, avec quatre puces version/chemin pour chaque outil.
- Sonder les binaires hôte avec -V, sans connexion, installation ni lecture d’identifiants ; gérer explicitement absences, échecs, expirations et versions invalides.
- Préserver le format 0.7 et les trois parcours de génération ; mettre à jour tests, documentation et historique.

## Capabilities

### Modified Capabilities

- `projects-template-devops` : ordre documentaire et inventaire local SSH.

## Impact

Fichiers : modules/projects/template.sh, tests/test_projects_template_devops.py, TECHNICAL.md, README.md, CHANGELOG.md et capacité projects-template-devops. Les documents existants prennent ce contenu à leur prochaine génération normale. Aucun changement de CLI, configuration, dépendance ou infrastructure.
