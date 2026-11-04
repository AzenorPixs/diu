# GIT25 — Gestion ciblée de safe.directory

## Why

Les dépôts partagés appartiennent au compte DevOps alors que les outils de
développement peuvent fonctionner sous un compte humain. Git refuse alors
d'utiliser le dépôt avec `detected dubious ownership`. La configuration du
seul compte DevOps ne résout pas cet accès partagé.

## What Changes

- Enregistrer une exception `safe.directory` système limitée au chemin
  absolu canonique du projet dans `rid projects git init` et `update`.
- Conserver les autres entrées, éviter les doublons et propager les erreurs.
- Afficher dans `status` la présence ou l'absence de cette exception exacte,
  sa portée système et le chemin concerné, sans modifier cette configuration.
- Préserver le questionnaire Git local et l'initialisation silencieuse,
  notamment pour les dépôts existants.

## Capabilities

### Modified Capabilities

- `projects-git-init`: exception système lors de l'initialisation.
- `implement-projects-git-update`: exception système après enregistrement des variables.
- `projects-git-status`: diagnostic de l'exception système en lecture seule.
- `rid-help`: descriptions des commandes concernées.

## Impact

- `modules/projects/git.sh`, `lib/rid-help.sh` et tests Python ciblés.
- `TECHNICAL.md`, `README.md` et `CHANGELOG.md`.
- Configuration Git système au lancement réel d'`init` ou d'`update` ; les
  tests utilisent exclusivement un fichier système Git temporaire isolé.
- Aucun changement de propriétaire, ajout de dépendance, commit, push ou
  modification de la configuration réelle de la machine pendant la session.
