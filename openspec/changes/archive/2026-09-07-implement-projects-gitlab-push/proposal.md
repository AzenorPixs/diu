# Proposition : publication des projets vers GitLab

## Contexte

DIU sait publier un dépôt local vers Forgejo, mais ne dispose pas d'un parcours équivalent vers un GitLab distant. La hiérarchie d'aide CLI ne décrit pas non plus correctement les commandes `projects` et `gitlab`.

## Objectif

Ajouter `rid projects gitlab push diu`, avec une configuration GitLab dédiée, une initialisation des identifiants calquée sur Forgejo et une aide CLI cohérente.

## Périmètre

- variables `REMOTE_GITLAB_*` dans `project.env` ;
- identifiants locaux `config/gitlab.username` et `config/gitlab.token` ;
- publication HTTPS via le mécanisme `git_with_token` existant ;
- aide des niveaux `rid`, `projects`, `projects gitlab` et `projects gitlab push` ;
- conservation du comportement Forgejo.
