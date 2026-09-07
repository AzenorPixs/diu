# Proposition : publication Forgejo unifiée des projets

## Contexte

Le parcours `gitpdi` publie uniquement l'image Docker et dépend d'une
fonction historique nommée `git_push_docker_image`. La configuration du projet
et celle de Forgejo ne sont pas complétées automatiquement, et la publication
d'un paquet Debian n'est pas disponible pour les projets génériques.

## Objectif

Remplacer ce parcours par `projects_forgejo_release`, accessible avec la
commande `rid projects forgejo release <ID PROJECT>`, afin de publier dans une
même opération les artefacts activés du projet : image Docker et paquet
Debian.

## Périmètre

- renommer et refactoriser complètement le parcours historique ;
- compléter automatiquement les variables générales et Forgejo manquantes ;
- publier l'image Docker existante lorsque `PROJECT_DOCKERED` est activé ;
- publier l'unique paquet Debian présent dans `dist/` lorsque
  `PROJECT_DEBIAN_PACKAGE` est activé ;
- rejeter explicitement les configurations ou artefacts incohérents ;
- supprimer la commande `rid projects gitpdi <ID PROJECT>` ;
- documenter les aides `projects` et `projects forgejo`.

Les publications Git dédiées, la release DIU historique et les autres
fournisseurs distants restent hors périmètre.
