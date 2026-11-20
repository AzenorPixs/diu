# Tags DIU sans préfixe v

## Why

Les commandes DIU produisent encore des tags préfixés alors que la livraison CAB publie le numéro directement.

## What Changes

- Utiliser la valeur du tag telle quelle pour chaque nouvelle référence Git, publication ou image du projet.
- Refuser un argument de tag explicite commençant par v avant tout effet.
- Lire les tags historiques pour comparer les versions et rechercher les anciens paquets, avec protection contre les collisions.

## Capabilities

### Modified Capabilities

- project-version
- projects-cicd
- forgejo-release
- projects-github-debian-release
- implement-projects-gitlab-release
- diu-package-update
