# Mise à jour de la configuration générale des projets

## Purpose

Définir la mise à jour des variables générales d'un projet DIU.

## Requirements

### Requirement: mise à jour des variables générales d'un projet

DIU MUST exposer `diu projects update <ID PROJECT>` via `update_projects()`, sans changer l'identifiant demandé. La fonction MUST gérer `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED`, `PROJECT_DEBIAN_PACKAGE`, `PROJECT_ORCHESTRATED_CODING` et `PROJECT_VERSION` dans `<projet>/project.env`. Elle MUST proposer les valeurs existantes et préserver les autres lignes et les droits prévus de configuration.

#### Scenario: création de la configuration générale

- **GIVEN** un répertoire de projet existant sans `project.env`
- **WHEN** l'utilisateur configure les variables générales
- **THEN** `PROJECT_TYPE` vaut `BASH` par défaut, les options binaires sont proposées à `No`, et un nom et une version valides sont demandés

#### Scenario: mise à jour ciblée du projet

- **GIVEN** une configuration existante valide
- **WHEN** l'utilisateur conserve les valeurs proposées
- **THEN** les variables générales et la version sont conservées ainsi que les lignes hors périmètre

### Requirement: aide des commandes projects

`diu projects help` MUST afficher toutes les sous-commandes de premier niveau
de `projects` avec leur description, notamment `update` et `git`.

#### Scenario: aide générale des projets

- ÉTANT DONNÉ que l'utilisateur exécute `diu projects help`
- QUAND l'aide est affichée
- ALORS la commande `diu projects update <ID PROJECT>` est décrite
- ET la commande `diu projects git update <ID PROJECT>` est décrite
- ET les commandes projects existantes restent listées

### Requirement: Déclaration du mode de développement du projet

DIU MUST interpréter `PROJECT_ORCHESTRATED_CODING=No` comme un développement
autonome et `Yes` comme un agent de codage piloté par un orchestrateur.
`create_project`, `update_projects` et `git_update_legacy` MUST demander cette
variable, proposer la valeur enregistrée ou `No` si elle est absente, et
persister exclusivement `Yes` ou `No`. La variable MUST NOT activer un service.

#### Scenario: Création autonome par défaut

- **WHEN** un nouveau projet est créé et l'utilisateur accepte le défaut
- **THEN** son `project.env` contient `PROJECT_ORCHESTRATED_CODING=No`
- **AND** la copie du modèle ne remplace pas cette configuration

#### Scenario: Choix du mode piloté

- **WHEN** l'utilisateur répond `Yes` à la question du mode de développement
- **THEN** `PROJECT_ORCHESTRATED_CODING=Yes` est enregistré

### Requirement: Validation interactive du mode de développement

Le questionnaire partagé MUST conserver le défaut proposé pour une entrée
vide, redemander après toute autre saisie que `Yes` ou `No` et signaler
l'erreur sans persister cette saisie. Une fin d'entrée MUST échouer avant
persistance et sans message de réussite de la configuration du projet.

#### Scenario: Saisie invalide puis correction

- **WHEN** l'utilisateur répond une valeur différente de `Yes` ou `No`
- **THEN** DIU redemande la valeur sans persister cette saisie
- **AND** une réponse ultérieure valide est enregistrée

#### Scenario: Fin d'entrée avant choix

- **WHEN** l'entrée se ferme pendant la question du mode de développement
- **THEN** DIU retourne un code non nul et ne remplace pas `project.env`

### Requirement: Lecture rétrocompatible et isolée du mode de développement

DIU MUST fournir `project_orchestrated_coding_get <fichier>` indépendamment
du shell et des projets précédents. Il MUST retourner `No` si le fichier ou
la variable est absent, ou si la valeur littérale est vide, sans écriture.
La variable MUST rester facultative pour les projets historiques et MUST NOT
déclencher une migration globale ou un nouveau critère de sélection des projets.

#### Scenario: Projet historique après un projet piloté

- **GIVEN** le shell contient une valeur `Yes` provenant d'un autre projet
- **WHEN** le lecteur consulte un fichier sans la variable
- **THEN** il retourne `No` sans modifier ce fichier

### Requirement: Lecture littérale contrôlée du mode de développement

Le lecteur MUST reconnaître `Yes` et `No`, avec guillemets simples ou doubles,
espaces et préfixe `export` facultatifs. Il MUST NOT exécuter le fichier ni
évaluer ses expressions shell. Une valeur non vide invalide ou un fichier
présent illisible ou non ordinaire MUST produire un code non nul et un
diagnostic sans reproduire son contenu.

#### Scenario: Lecture littérale sans exécution

- **GIVEN** un fichier contenant la valeur littérale `Yes` et une autre ligne de commande shell
- **WHEN** le lecteur est appelé
- **THEN** il retourne `Yes` sans exécuter cette commande

#### Scenario: Configuration invalide

- **WHEN** le fichier contient une valeur non vide différente de `Yes` ou `No`
- **THEN** le lecteur échoue sans afficher le contenu invalide ni persister de correction

### Requirement: Conservation du mode lors des réécritures historiques

`git_update_legacy` MUST inclure le mode choisi dans son résumé et dans la
réécriture de `project.env`, y compris lorsqu'une configuration existante
contient `Yes`. Le point d'entrée public Git local MUST conserver son
questionnement limité aux variables Git. Le clonage local MUST conserver
la valeur source, ou son absence historique, sans question supplémentaire.

#### Scenario: Réécriture historique d'un projet piloté

- **GIVEN** une configuration valide contenant `PROJECT_ORCHESTRATED_CODING=Yes`
- **WHEN** le parcours historique réenregistre la configuration en conservant les défauts
- **THEN** le résumé et le fichier final conservent `Yes`

#### Scenario: Configuration Git locale seule

- **WHEN** l'utilisateur met à jour les variables Git locales
- **THEN** la nouvelle variable reste inchangée et aucune question de mode n'est posée

#### Scenario: Clonage local

- **WHEN** un projet est cloné localement
- **THEN** la destination conserve la valeur de mode source ou son absence

### Requirement: Questionnaire commun de configuration initiale et mise à jour

DIU MUST présenter les types BASH, GO, JAVASCRIPT, PERL et PYTHON sans interdire les autres types. PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE MUST accepter exclusivement Yes ou No, avec No par défaut et redemande en cas d'entrée invalide. PROJECT_VERSION MUST être demandée au format x.y.z sans zéro initial et enregistrée ; sa valeur existante valide MUST être proposée à la mise à jour. Sans version existante, une saisie valide MUST être fournie. Toute fin d'entrée MUST échouer avant persistance.

#### Scenario: Configuration initiale

- **WHEN** les informations valides sont saisies lors de la création
- **THEN** les variables générales et la version sont enregistrées dans project.env

#### Scenario: Mise à jour et entrée invalide

- **WHEN** une réponse binaire ou une version est invalide
- **THEN** elle est redemandée et ne remplace pas la configuration

### Requirement: Protocole de codage intégré à CAB

La création et la synchronisation MUST NOT exiger ni copier ORCHESTRATED_CODING.md, quel que soit le mode de développement. La synchronisation MUST conserver tout document destination existant.

#### Scenario: Mode piloté sans document source

- **WHEN** un projet piloté est créé ou synchronisé sans document source
- **THEN** l'absence du document ne provoque pas d'échec et aucune copie n'est effectuée
