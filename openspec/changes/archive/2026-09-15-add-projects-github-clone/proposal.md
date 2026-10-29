# GIT16 — Clonage des projets depuis GitHub

## Why

Le DIU ne permet pas de créer un projet puis d'y fusionner un dépôt GitHub
distant configuré.

## What Changes

- Ajouter `rid projects github clone <ID PROJECT>` et `github_clone`.
- Réutiliser la création, la configuration GitHub et l'authentification HTTPS.
- Cloner temporairement puis fusionner sans métadonnée Git.

## Impact

Le routage, l'aide, le module Git des projets, le provider GitHub et les tests
ciblés sont concernés. Les clonages local et GitLab restent inchangés.
