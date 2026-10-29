# GIT04 — Proposition : prise en charge des certificats GitLab autosignés

## Contexte

Les connexions GitLab vers un serveur utilisant un certificat autosigné échouent lors de la vérification TLS avant l'authentification.

## Objectif

Permettre de désactiver ouvertement la vérification TLS pour GitLab au moyen d'une variable de projet, sans affaiblir les connexions Forgejo ni la configuration globale de Git.

## Périmètre

- variable `REMOTE_GITLAB_SSL_VERIFY` ;
- conservation et modification via `gitlab_update()` ;
- application limitée aux opérations GitLab authentifiées ;
- spécification et archivage OpenSpec.
