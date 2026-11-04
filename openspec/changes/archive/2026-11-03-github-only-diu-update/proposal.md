# Mise à jour DIU exclusivement depuis GitHub

## Why

La mise à jour du DIU dépend actuellement de trois fournisseurs et peut échouer si un fournisseur autre que GitHub est indisponible. Le développeur demande que GitHub soit l’unique source.

## What Changes

- Rechercher et télécharger le paquet DIU uniquement depuis les releases GitHub configurées.
- Ignorer entièrement les configurations Forgejo et GitLab dans cette commande.
- Préserver les contrôles de version et de paquet, la pagination, l’authentification GitHub et les alias.
- Ne pas modifier les autres opérations de publication ou la version du projet.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `diu-package-update`: GitHub devient l’unique source de mise à jour du DIU.

## Impact

Module `diu`, aide, tests, documentation et spécification de mise à jour. Un GitHub absent ou inaccessible bloque la mise à jour ; aucun repli vers un autre fournisseur.
