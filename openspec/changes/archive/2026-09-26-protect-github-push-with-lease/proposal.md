# GIT22 — Proposal

## Why

Un projet publié depuis plusieurs machines peut posséder une branche GitHub
plus récente que la référence distante locale. Le push GitHub est alors refusé
ou, sans protection, pourrait écraser un changement distant.

## What Changes

- Récupérer les références du remote GitHub authentifié avant le push de
  branche.
- Publier la branche GitHub avec `--force-with-lease` afin de synchroniser le
  dépôt tout en refusant une modification distante intervenue après la
  récupération des références.
- Arrêter explicitement la publication si la récupération GitHub échoue.

## Capabilities

### New Capabilities

_Aucune._

### Modified Capabilities

- `implement-projects-github-push`: sécuriser la synchronisation de la
  branche GitHub avant sa publication.

## Impact

Les flux `rid projects github push <ID PROJECT>` et CI/CD GitHub sont
concernés. Les parcours Forgejo et GitLab, ainsi que le push de tags GitHub,
restent inchangés.
