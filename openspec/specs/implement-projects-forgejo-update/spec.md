# implement-projects-forgejo-update Specification

## Purpose
Définir la création et la mise à jour ciblées de la configuration Forgejo d'un
projet DIU, sans altérer ses autres configurations.

## Requirements

### Requirement: commande de mise à jour Forgejo

Le système MUST exposer la commande
`diu projects forgejo update <ID PROJECT>`.

#### Scenario: vérifier une configuration Forgejo existante

- **GIVEN** que `project.env` contient une configuration générale conforme
- **WHEN** l'utilisateur exécute `diu projects forgejo update <ID PROJECT>`
- **THEN** les valeurs `REMOTE_FORGEJO_*` existantes sont proposées comme valeurs
  courantes
- **AND** l'utilisateur peut les conserver ou les modifier
- **AND** les variables générales, Forgejo historique, GitLab et GitHub sont
  conservées

#### Scenario: créer une configuration Forgejo absente

- **GIVEN** que la configuration générale est conforme
- **AND** que les variables `REMOTE_FORGEJO_*` sont absentes ou incomplètes
- **WHEN** l'utilisateur exécute `diu projects forgejo update <ID PROJECT>`
- **THEN** seules les valeurs Forgejo sont demandées
- **AND** `REMOTE_FORGEJO_REPOSITORY` prend par défaut l'identifiant du projet
- **AND** `REMOTE_FORGEJO_NAME` prend par défaut `origin`
- **AND** `REMOTE_FORGEJO_BRANCH` prend par défaut `main`
- **AND** `REMOTE_FORGEJO_SSL_VERIFY` prend par défaut `No`

#### Scenario: configuration générale non conforme

- **GIVEN** que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou
  `PROJECT_DOCKERED` est absent ou incorrect
- **WHEN** l'utilisateur exécute `diu projects forgejo update <ID PROJECT>`
- **THEN** la fonction `update_projects()` est appelée pour compléter la
  configuration générale
- **AND** les variables Forgejo sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `forgejo_update()` MUST modifier uniquement le bloc des variables
`REMOTE_FORGEJO_*` dans `project.env` et DOIT conserver toutes les autres
variables du projet, notamment les variables générales, Forgejo historique,
GitLab et GitHub.

#### Scenario: conservation des variables concurrentes

- **GIVEN** que `project.env` contient des variables générales, Forgejo
  historique, GitLab ou GitHub
- **WHEN** `forgejo_update()` enregistre la configuration
- **THEN** ces variables et leurs valeurs sont conservées

### Requirement: validation des valeurs

`REMOTE_FORGEJO_BASE_URL` et `REMOTE_FORGEJO_OWNER` MUST être non vides.
`REMOTE_FORGEJO_SSL_VERIFY` MUST valoir `Yes` ou `No` après normalisation.

#### Scenario: valeur TLS invalide

- **GIVEN** que l'utilisateur saisit une valeur différente de `Yes` ou `No`
- **WHEN** `forgejo_update()` traite la configuration
- **THEN** la fonction échoue explicitement
- **AND** `project.env` n'est pas remplacé par une configuration invalide

### Requirement: aide CLI

Les commandes suivantes MUST être décrites :

- `diu projects forgejo help` affiche `update` et `push` ;
- `diu projects forgejo update help` décrit la vérification, la modification
  ou la création des variables Forgejo ;
- `diu projects help` conserve l'entrée de niveau `forgejo`.

#### Scenario: aide de mise à jour

- **GIVEN** que l'utilisateur demande `diu projects forgejo update help`
- **WHEN** l'aide est affichée
- **THEN** la description de la mise à jour et sa syntaxe sont affichées
