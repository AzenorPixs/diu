# DEV10 — Références Docker pour les tests dans DEVOPS.md

## Why

La rubrique Docker générée indique la version et le binaire, mais ne fournit
pas le chemin du socket ni l'image Debian demandés pour les tests nécessitant
des droits root.

## What Changes

- Intituler la rubrique `Docker, pour tests nécessitant des droits root`.
- Ajouter `/var/run/docker.sock` puis `debian:stable-slim`, après la version
  détectée et le chemin du binaire.
- Conserver ces références documentaires même si Docker est indisponible,
  avec les diagnostics actuels pour la version et le binaire.
- Documenter leur portée : aucune vérification du socket ou de l'image,
  aucun téléchargement et aucun lancement Docker.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops` : compléter le rendu de la rubrique Docker.

## Impact

Périmètre approuvé par le développeur le 22 octobre 2026 dans la session SCM :
générateur `modules/projects/template.sh`, attentes existantes de
`tests/test_projects_template_devops.py`, passages DevOps de `TECHNICAL.md`
et `README.md`, entrée `Unreleased` de `CHANGELOG.md`, présent change,
synchronisation de sa spécification et archivage avec rapport par archive.

La version documentaire reste `0.6`. Le titre Docker change conformément
au rendu approuvé ; les consommateurs recherchant exactement `# Docker`
devront utiliser le nouveau titre. Les autres rubriques, commandes publiques,
sondes et règles d'écriture sont préservées. Les documents déjà générés
adoptent ce rendu lors de leur prochaine génération normale.

Aucune installation, migration, modification du système, action Git ou
exécution Docker n'est incluse. Le repli consiste à rétablir les passages
modifiés du générateur, des attentes et de la documentation.
