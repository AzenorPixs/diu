# Proposition : séparation de la configuration des projets et de Git local

## Contexte

La fonction `git_update()` gère actuellement à la fois les variables générales
du projet, les variables du dépôt Git local et plusieurs configurations de
dépôts distants. Cette responsabilité mélangée rend les mises à jour ciblées
impossibles et expose les valeurs à des réécritures non nécessaires.

## Objectif

Exposer deux mises à jour ciblées :

- `rid projects update <ID PROJECT>` pour les variables générales du projet ;
- `rid projects git update <ID PROJECT>` pour les variables du dépôt Git local.

Les fonctions doivent conserver les autres blocs de `project.env`, notamment
les configurations de dépôts distants déjà gérées par les modules dédiés.

## Périmètre

- ajout de `update_projects()` dans `modules/projects/projects.sh` ;
- adaptation de `git_update()` dans `modules/projects/git.sh` ;
- ajout de `PROJECT_DEBIAN_PACKAGE` aux variables générales du projet ;
- redirection de la création et des compléments de configuration vers les deux
  périmètres ciblés ;
- exposition des commandes et refactorisation de `rid projects help` ;
- validation puis archivage de cette évolution OpenSpec.
