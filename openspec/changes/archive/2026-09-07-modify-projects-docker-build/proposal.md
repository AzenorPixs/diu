# Proposition : normaliser la construction Docker des projets

## Contexte

La construction de l'image Docker d'un projet utilise actuellement la fonction
`proj_docker_build` et la commande historique `rid projects dockerb`. Le
routage et les aides ne correspondent pas à une hiérarchie `projects docker`.

## Objectif

Renommer la fonction en `projects_docker_build`, exposer la commande
`rid projects docker build <ID PROJECT>`, renforcer la validation de la
configuration Docker du projet et retirer l'ancien alias `dockerb`.

## Périmètre

- renommer la fonction de construction Docker et ses appels internes ;
- vérifier `PROJECT_DOCKERED` avant les autres contrôles de construction ;
- accepter `Yes`, `YES` ou `1` pour `PROJECT_DOCKERED` dans ce parcours ;
- vérifier la présence de `entrypoint.sh` et du Dockerfile ;
- refactoriser les aides `rid projects help` et `rid projects docker help` ;
- supprimer la commande `rid projects dockerb` du dispatch et des aides.

## Hors périmètre

- modifier les autres validations de projet ou le contenu des images ;
- modifier les variables générales des projets ;
- modifier les parcours Docker root et rootless ;
- modifier les publications d'images après construction.
