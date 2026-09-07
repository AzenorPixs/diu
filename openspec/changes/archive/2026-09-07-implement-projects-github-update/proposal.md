# Proposition : mise à jour de la configuration GitHub

## Contexte

La publication GitHub nécessite une configuration dédiée persistée dans
`project.env`. Cette configuration doit pouvoir être créée ou rejouée sans
modifier les paramètres généraux du projet ni ceux des autres fournisseurs.

## Objectif

Rendre `github_update()` accessible avec
`rid projects github update <ID PROJECT>` et garantir une mise à jour ciblée
des variables GitHub.

## Périmètre

- validation ou complément de la configuration générale par `git_update()` ;
- création ou modification des seules variables `REMOTE_GITHUB_*` ;
- conservation des autres lignes de `project.env` ;
- aide de la commande `update` ;
- spécification et archivage OpenSpec.
