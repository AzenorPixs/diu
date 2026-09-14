## Purpose

Permettre de dupliquer localement un projet géré par DIU sous un nouvel
identifiant, sans transférer aucune métadonnée Git.

## ADDED Requirements

### Requirement: Commande de clonage local d'un projet

DIU MUST accepter `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`
et appeler `clone_project` avec les deux identifiants dans cet ordre. La
commande MUST exiger les deux identifiants, refuser un identifiant contenant
un chemin, une source absente ou non répertoire, une source sans `project.env`
et une destination qui existe déjà. Elle MUST échouer avec un code non nul
avant toute écriture dans la destination lorsqu'un de ces prérequis n'est pas
satisfait.

#### Scenario: Clonage d'un projet valide

- **WHEN** l'utilisateur exécute `rid projects clone source destination` pour
  une source valide et une destination absente
- **THEN** DIU crée le projet `destination` à partir de `source`

#### Scenario: Précondition non satisfaite

- **WHEN** un identifiant est absent, la source est invalide, `project.env`
  est absent ou la destination existe déjà
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun nouveau répertoire destination partiel n'est conservé

### Requirement: Copie complète sans métadonnées Git

Lors d'un clonage réussi, DIU MUST copier récursivement le contenu du projet
source, y compris les éléments cachés ordinaires, dans le projet destination.
DIU MUST exclure de la copie tout répertoire nommé `.git` et l'intégralité de
son contenu, y compris lorsqu'il est imbriqué. DIU MUST NOT exécuter de
commande Git ni modifier le projet source pendant cette opération.

#### Scenario: Projet source contenant un dépôt Git

- **WHEN** la source contient un répertoire `.git` à sa racine et des fichiers
  cachés ordinaires
- **THEN** la destination contient les fichiers cachés ordinaires
- **AND THEN** elle ne contient pas le répertoire `.git` source

#### Scenario: Métadonnée Git imbriquée

- **WHEN** la source contient un répertoire `.git` dans un sous-répertoire
- **THEN** ce répertoire et son contenu sont absents de la destination
- **AND THEN** les autres éléments du sous-répertoire sont copiés

### Requirement: Identifiant de destination dans la configuration clonée

Après la copie réussie, DIU MUST remplacer l'affectation `PROJECT_ID` du
fichier `project.env` destination par `<ID PROJECT DESTINATION>`. DIU MUST
préserver les autres variables et les lignes non ciblées de ce fichier.

#### Scenario: Mise à jour de project.env

- **WHEN** `source/project.env` définit `PROJECT_ID=source` et d'autres
  variables
- **THEN** `destination/project.env` définit `PROJECT_ID=destination`
- **AND THEN** les autres variables et lignes non ciblées sont conservées
