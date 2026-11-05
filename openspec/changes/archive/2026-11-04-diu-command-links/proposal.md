# Commandes diu et diut — code non attribué

## Pourquoi

Fournir des commandes accessibles dans le PATH pour le DIU installé et, lorsqu’il existe, son dépôt de développement, en conservant les alias historiques.

## Changements

- Créer conditionnellement le lien `diu` lors de la configuration du paquet.
- Créer conditionnellement `diut` après chargement de `ENV_DEVOPS_PROJECTS_ROOT`.
- Résoudre le chemin réel du point d’entrée et préserver tout chemin déjà occupé.

## Périmètre

Paquet DIU, bootstrap, tests et documentation associés. La racine variable dépend du change actif `migrate-env-devops-projects-root`, validé et archivé le 2026-11-04.
