# GIT08 — Proposition : publication des projets vers GitHub

## Contexte

DIU sait publier un dépôt local vers Forgejo et GitLab, mais ne propose pas de
parcours dédié à GitHub. La commande doit sélectionner GitHub explicitement et
conserver les configurations des autres fournisseurs.

## Objectif

Ajouter `rid projects github push <ID PROJECT>` avec une configuration GitHub
dédiée, une initialisation sécurisée des identifiants et une aide CLI cohérente.

## Périmètre

- variables `REMOTE_GITHUB_*` dans `project.env` ;
- identifiants locaux `config/github.username` et `config/github.token` ;
- publication HTTPS via le mécanisme Git temporaire existant ;
- ajout ou validation du remote GitHub configuré ;
- aides `rid`, `rid projects`, `rid projects github` et `rid projects github push` ;
- conservation des parcours Forgejo et GitLab.
