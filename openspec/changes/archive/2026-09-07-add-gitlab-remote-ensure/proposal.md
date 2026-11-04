# GIT02 — Proposition : création automatique du remote GitLab

## Contexte

Le projet peut déjà avoir `origin` configuré vers Forgejo. La publication GitLab doit pouvoir utiliser un remote séparé, tel que `ecn`, sans demander une configuration Git manuelle.

## Objectif

Faire vérifier et créer automatiquement le remote défini par `REMOTE_GITLAB_NAME` avant le push GitLab, sans écraser un remote incohérent.

## Périmètre

- création idempotente du remote GitLab absent ;
- validation de l'URL d'un remote existant ;
- utilisation du remote configuré pour l'authentification GitLab ;
- conservation du remote Forgejo ;
- spécification et archivage OpenSpec.
