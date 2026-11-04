# Code non attribué — Poursuite CI/CD lors d’une indisponibilité en release

## Objectif

Étendre au stade de publication des artefacts le traitement non bloquant des indisponibilités réseau reconnues, pour Forgejo, GitLab et GitHub, en CI/CD normale et en rejeu d’une version existante.

## Périmètre

Qualifier les pannes des transports de release, poursuivre les fournisseurs indépendants, indiquer la publication non confirmée et une éventuelle publication partielle, sans masquer les autres erreurs. Les commandes de release directe gardent leur contrat. Aucune nouvelle dépendance ou configuration.

## Capacités affectées

- `projects-cicd` : poursuite et bilan de publication.
- `git-provider-availability` : classification contextuelle réutilisée par les transports de release.
