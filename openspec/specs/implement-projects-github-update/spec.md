# implement-projects-github-update Specification

## Purpose
Définir la création et la mise à jour ciblées de la configuration GitHub d'un
projet DIU, sans altérer ses configurations générales ou concurrentes.

## Requirements

### Requirement: commande de mise à jour GitHub

Le système MUST exposer la commande `diu projects github update <ID PROJECT>`.

Le système DOIT exposer la commande `diu projects github update <ID PROJECT>`.

#### Scenario: vérifier une configuration GitHub existante

- **GIVEN** que `project.env` contient une configuration générale conforme
- **WHEN** l'utilisateur exécute `diu projects github update <ID PROJECT>`
- **THEN** les valeurs `REMOTE_GITHUB_*` existantes sont proposées comme valeurs
  courantes
- **AND** l'utilisateur peut les conserver ou les modifier
- **AND** les variables générales, Forgejo et GitLab sont conservées

#### Scenario: créer une configuration GitHub absente

- **GIVEN** que la configuration générale est conforme
- **AND** que les variables `REMOTE_GITHUB_*` sont absentes ou incomplètes
- **WHEN** l'utilisateur exécute `diu projects github update <ID PROJECT>`
- **THEN** seules les variables GitHub sont demandées
- **AND** `REMOTE_GITHUB_REPOSITORY` prend par défaut l'identifiant du projet
- **AND** `REMOTE_GITHUB_NAME` prend par défaut `origin`
- **AND** `REMOTE_GITHUB_BRANCH` prend par défaut `main`

#### Scenario: configuration générale non conforme

- **GIVEN** que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou
  `PROJECT_DOCKERED` est absent ou incorrect
- **WHEN** l'utilisateur exécute `diu projects github update <ID PROJECT>`
- **THEN** la fonction `update_projects()` est appelée pour compléter la
  configuration générale
- **AND** les variables GitHub sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `github_update()` MUST préserver toutes les variables non GitHub.

#### Scenario: conservation des variables non GitHub

- **GIVEN** que `project.env` contient des variables générales ou d'autres
  fournisseurs
- **WHEN** `github_update()` enregistre la configuration GitHub
- **THEN** ces variables et leurs valeurs sont conservées

La fonction `github_update()` DOIT modifier uniquement le bloc des variables
`REMOTE_GITHUB_*` dans `project.env` et DOIT conserver toutes les autres
variables du projet, notamment les variables générales, Forgejo et GitLab.

### Requirement: aide CLI

Les aides de mise à jour GitHub MUST décrire la commande et sa syntaxe.

#### Scenario: aide de mise à jour GitHub

- **GIVEN** que l'utilisateur demande une aide GitHub
- **WHEN** il exécute `diu projects github update help`
- **THEN** la commande et sa description sont affichées

Les commandes suivantes DOIVENT être décrites :

- `diu projects github help` affiche `update` et `push` ;
- `diu projects github update help` décrit la vérification, la modification
  ou la création des variables GitHub ;
- `diu projects help` conserve l'entrée de niveau `github`.
