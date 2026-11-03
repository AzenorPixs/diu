# Proposition

## Why

Un CI/CD lancé avec une version déjà attribuée s'arrête après l'étape de commit, même lorsqu'un rejeu des opérations sur le commit publié est souhaité.

## What Changes

- Afficher et traiter les six étapes lors du rejeu d'une version existante.
- Construire les artefacts depuis une copie isolée du commit désigné par le tag, en préservant les modifications locales en attente.
- Vérifier les dépôts et publications existants sans déplacer de tag ni remplacer un artefact publié.
- Distinguer les opérations déjà réalisées ou ignorées des erreurs effectives.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-cicd`: rejeu des étapes sur un commit versionné isolé.
- `project-version`: traitement d'une version déjà attribuée lors du CI/CD.
- `forgejo-release`: publication d'un commit marqué déjà présent dans l'historique distant.
- `projects-github-debian-release`: publication d'un commit marqué déjà présent dans l'historique distant.

## Impact

Orchestration CI/CD, sélection des sources de construction et publication, aides, tests et documentation. Les modifications locales en attente et les tags existants sont préservés.
