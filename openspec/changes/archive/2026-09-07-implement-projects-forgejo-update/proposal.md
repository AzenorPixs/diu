# GIT07 — Proposition : mise à jour de la configuration Forgejo

## Contexte

La publication Forgejo dédiée nécessite une configuration propre dans
`project.env`. Cette configuration doit pouvoir être créée ou rejouée sans
réécrire les paramètres généraux ni les configurations GitLab et GitHub.

## Objectif

Rendre `forgejo_update()` accessible avec
`rid projects forgejo update <ID PROJECT>` et garantir une mise à jour ciblée
des variables Forgejo.

## Périmètre

- validation ou complément de la configuration générale par `git_update()` ;
- création ou modification des seules variables `REMOTE_FORGEJO_*` ;
- valeurs par défaut adaptées au projet ;
- conservation des autres lignes de `project.env` ;
- aide de la commande `update` ;
- spécification et archivage OpenSpec.

