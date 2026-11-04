# GIT11 — Proposition : configuration différentielle GitLab

## Contexte

Le premier parcours GitLab réutilisait `git_update()` avec le mode GitLab. Cette fonction affichait et réécrivait toute la configuration du projet, alors que la publication GitLab ne doit compléter que son propre différentiel.

## Objectif

Créer un parcours `gitlab_update()` dédié aux variables `REMOTE_GITLAB_*`, précédé d'une vérification des variables générales essentielles et d'un appel à `git_update()` uniquement si cette configuration générale est non conforme.

## Périmètre

- séparation entre `git_update()` et `gitlab_update()` ;
- conservation des variables générales et Forgejo ;
- initialisation ciblée de la configuration GitLab ;
- contrôle final avant publication ;
- documentation et archivage OpenSpec.
