## ADDED Requirements

### Requirement: mise à jour des variables générales d'un projet

Le système DOIT exposer `rid projects update <ID PROJECT>` et la fonction
`update_projects()`.

La fonction DOIT gérer les variables `PROJECT_ID`, `PROJECT_NAME`,
`PROJECT_TYPE`, `PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` dans le fichier
`<projet>/project.env`.

#### Scenario: création de la configuration générale

- ÉTANT DONNÉ que le répertoire du projet existe et que `project.env` est
  absent
- QUAND l'utilisateur exécute `rid projects update <ID PROJECT>`
- ALORS `PROJECT_ID` vaut l'identifiant demandé
- ET `PROJECT_TYPE` vaut `BASH` par défaut
- ET `PROJECT_DOCKERED` vaut `No` par défaut
- ET `PROJECT_DEBIAN_PACKAGE` vaut `No` par défaut
- ET `PROJECT_NAME` est demandé et ne peut pas rester vide

#### Scenario: mise à jour ciblée du projet

- ÉTANT DONNÉ que `project.env` contient une configuration existante
- QUAND l'utilisateur exécute `rid projects update <ID PROJECT>`
- ALORS les valeurs générales existantes sont proposées
- ET seules les variables générales du projet sont remplacées
- ET les variables Git local et distantes sont conservées

### Requirement: aide des commandes projects

`rid projects help` DOIT afficher toutes les sous-commandes de premier niveau
de `projects` avec leur description, notamment `update` et `git`.

#### Scenario: aide générale des projets

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects help`
- QUAND l'aide est affichée
- ALORS la commande `rid projects update <ID PROJECT>` est décrite
- ET la commande `rid projects git update <ID PROJECT>` est décrite
- ET les commandes projects existantes restent listées
