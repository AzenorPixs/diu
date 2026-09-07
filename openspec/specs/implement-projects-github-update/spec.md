# implement-projects-github-update Specification

## Purpose
Définir la création et la mise à jour ciblées de la configuration GitHub d'un
projet DIU, sans altérer ses configurations générales ou concurrentes.

## Requirements

### Requirement: commande de mise à jour GitHub

Le système MUST exposer la commande `rid projects github update <ID PROJECT>`.

Le système DOIT exposer la commande `rid projects github update <ID PROJECT>`.

#### Scenario: vérifier une configuration GitHub existante

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `rid projects github update <ID PROJECT>`
- ALORS les valeurs `REMOTE_GITHUB_*` existantes sont proposées comme valeurs
  courantes
- ET l'utilisateur peut les conserver ou les modifier
- ET les variables générales, Forgejo et GitLab sont conservées

#### Scenario: créer une configuration GitHub absente

- ÉTANT DONNÉ que la configuration générale est conforme
- ET que les variables `REMOTE_GITHUB_*` sont absentes ou incomplètes
- QUAND l'utilisateur exécute `rid projects github update <ID PROJECT>`
- ALORS seules les variables GitHub sont demandées
- ET `REMOTE_GITHUB_REPOSITORY` prend par défaut l'identifiant du projet
- ET `REMOTE_GITHUB_NAME` prend par défaut `origin`
- ET `REMOTE_GITHUB_BRANCH` prend par défaut `main`

#### Scenario: configuration générale non conforme

- ÉTANT DONNÉ que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou
  `PROJECT_DOCKERED` est absent ou incorrect
- QUAND l'utilisateur exécute `rid projects github update <ID PROJECT>`
- ALORS la fonction générique `git_update()` est appelée pour compléter la
  configuration générale
- ET les variables GitHub sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `github_update()` MUST préserver toutes les variables non GitHub.

#### Scenario: conservation des variables non GitHub

- ÉTANT DONNÉ que `project.env` contient des variables générales ou d'autres
  fournisseurs
- QUAND `github_update()` enregistre la configuration GitHub
- ALORS ces variables et leurs valeurs sont conservées

La fonction `github_update()` DOIT modifier uniquement le bloc des variables
`REMOTE_GITHUB_*` dans `project.env` et DOIT conserver toutes les autres
variables du projet, notamment les variables générales, Forgejo et GitLab.

### Requirement: aide CLI

Les aides de mise à jour GitHub MUST décrire la commande et sa syntaxe.

#### Scenario: aide de mise à jour GitHub

- ÉTANT DONNÉ que l'utilisateur demande une aide GitHub
- QUAND il exécute `rid projects github update help`
- ALORS la commande et sa description sont affichées

Les commandes suivantes DOIVENT être décrites :

- `rid projects github help` affiche `update` et `push` ;
- `rid projects github update help` décrit la vérification, la modification
  ou la création des variables GitHub ;
- `rid projects help` conserve l'entrée de niveau `github`.
