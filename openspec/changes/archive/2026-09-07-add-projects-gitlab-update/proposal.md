# GIT03 — Proposition : commande de mise à jour GitLab

## Contexte

La fonction `gitlab_update()` complète déjà de manière ciblée les variables GitLab nécessaires à la publication, mais elle n'est pas directement accessible depuis la commande `rid`.

## Objectif

Rendre cette fonction accessible par `rid projects gitlab update <ID PROJECT>` afin de permettre la vérification, la modification ou la création manuelle de la configuration GitLab d'un projet.

## Périmètre

- ajout du dispatch CLI ;
- mise à jour des aides `projects gitlab` ;
- conservation de la validation générale et du complément GitLab ciblé ;
- spécification et archivage OpenSpec.
