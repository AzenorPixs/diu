# Construction Docker des projets DIU

## Purpose

Normaliser la construction de l'image Docker d'un projet DIU et son exposition
dans la hiérarchie de commandes `projects docker`.

## Requirements

### Requirement: fonction de construction Docker

Le module `projects` DOIT exposer la fonction `projects_docker_build` pour
construire l'image Docker d'un projet. Le code actif NE DOIT plus exposer ni
appeler `proj_docker_build`.

#### Scenario: appel interne de la construction

- ÉTANT DONNÉ qu'un parcours DIU doit construire l'image Docker d'un projet
- QUAND il déclenche la construction
- ALORS il appelle `projects_docker_build`
- ET les paramètres de construction existants sont conservés

### Requirement: commande Docker du projet

Le système DOIT accepter la commande
`rid projects docker build <ID PROJECT>` pour construire l'image Docker du
projet identifié.

#### Scenario: construction demandée

- ÉTANT DONNÉ que le projet `<ID PROJECT>` est accessible et configuré
- QUAND l'utilisateur exécute `rid projects docker build <ID PROJECT>`
- ALORS la construction Docker du projet est déclenchée

#### Scenario: ancienne commande supprimée

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects dockerb <ID PROJECT>`
- QUAND le dispatch traite la commande
- ALORS aucune construction Docker n'est exécutée
- ET la commande est rejetée comme indisponible

### Requirement: activation Docker du projet

`projects_docker_build` DOIT charger `project.env` puis vérifier en premier
parmi les contrôles de construction que `PROJECT_DOCKERED` vaut exactement
`Yes`, `YES` ou `1`. Toute autre valeur, y compris une valeur absente, DOIT
arrêter la fonction avec un code non nul avant la vérification du Dockerfile,
de `entrypoint.sh` ou l'appel à Docker.

#### Scenario: projet non Dockerisé

- ÉTANT DONNÉ que `PROJECT_DOCKERED` est absent ou vaut une autre valeur
- QUAND la construction est demandée
- ALORS un diagnostic indique que le projet n'est pas Dockerisé
- ET aucun contrôle de fichier de construction ni `docker build` n'est exécuté

#### Scenario: projet Dockerisé

- ÉTANT DONNÉ que `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`
- QUAND la construction est demandée
- ALORS les contrôles restants de la construction sont exécutés

### Requirement: fichiers requis pour la construction

Après la validation de `PROJECT_DOCKERED`, la fonction DOIT vérifier la
présence du Dockerfile configuré et de `entrypoint.sh` à la racine du projet.
Un fichier absent DOIT provoquer un échec explicite avant `docker build`.

#### Scenario: fichier requis absent

- ÉTANT DONNÉ que le projet est déclaré Dockerisé
- ET que le Dockerfile ou `entrypoint.sh` est absent
- QUAND la construction est demandée
- ALORS la fonction identifie le fichier manquant
- ET Docker n'est pas appelé

### Requirement: aides des commandes

Les aides DOIVENT décrire la nouvelle hiérarchie sans présenter `dockerb` :

- `rid projects help` DOIT présenter `rid projects docker` et sa description ;
- `rid projects docker help` DOIT présenter `rid projects docker build <ID PROJECT>`
  et sa description ;
- `rid projects docker build help` DOIT rappeler la syntaxe complète de la
  construction.

#### Scenario: aide des projets

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects help`
- QUAND l'aide est affichée
- ALORS la sous-commande `docker` est décrite
- ET l'ancienne sous-commande `dockerb` est absente

#### Scenario: aide Docker

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects docker help`
- QUAND l'aide est affichée
- ALORS la sous-commande `build <ID PROJECT>` est décrite

#### Scenario: aide détaillée de construction

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects docker build help`
- QUAND l'aide est affichée
- ALORS la syntaxe `rid projects docker build <ID PROJECT>` est rappelée
