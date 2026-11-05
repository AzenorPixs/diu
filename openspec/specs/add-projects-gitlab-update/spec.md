# Mise à jour ciblée de la configuration GitLab des projets DIU

## Purpose

Définir la mise à jour ciblée de la configuration GitLab d'un projet DIU.

## Requirements

### Requirement: commande de mise à jour GitLab

Le système MUST exposer la commande `diu projects gitlab update <ID PROJECT>`.

#### Scenario: vérifier une configuration GitLab existante

- **GIVEN** que `project.env` contient une configuration générale conforme
- **WHEN** l'utilisateur exécute `diu projects gitlab update <ID PROJECT>`
- **THEN** les valeurs `REMOTE_GITLAB_*` existantes, y compris
  `REMOTE_GITLAB_REGISTRY`, sont affichées comme valeurs courantes
- **AND** l'utilisateur peut les conserver ou les modifier
- **AND** les variables générales et Forgejo sont conservées

#### Scenario: créer une configuration GitLab absente

- **GIVEN** que la configuration générale est conforme
- **AND** que les variables `REMOTE_GITLAB_*` sont absentes ou incomplètes
- **WHEN** l'utilisateur exécute `diu projects gitlab update <ID PROJECT>`
- **THEN** seules les variables GitLab sont demandées
- **AND** `REMOTE_GITLAB_REPOSITORY` prend par défaut l'identifiant du projet
- **AND** `REMOTE_GITLAB_NAME` prend par défaut `origin`
- **AND** `REMOTE_GITLAB_BRANCH` prend par défaut `main`
- **AND** `REMOTE_GITLAB_REGISTRY` est demandée comme adresse de registre
  Docker explicite

#### Scenario: configuration générale non conforme

- **GIVEN** que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou
  `PROJECT_DOCKERED` est absent ou incorrect
- **WHEN** l'utilisateur exécute `diu projects gitlab update <ID PROJECT>`
- **THEN** la fonction `update_projects()` est appelée pour compléter la
  configuration générale
- **AND** les variables GitLab sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `gitlab_update()` MUST modifier uniquement le bloc des variables `REMOTE_GITLAB_*` dans `project.env` et MUST conserver les autres variables du projet.

#### Scenario: conservation des variables hors GitLab

- **GIVEN** que `project.env` contient des variables générales et Forgejo
- **WHEN** `gitlab_update()` met à jour la configuration GitLab
- **THEN** seules les variables `REMOTE_GITLAB_*` sont modifiées
- **AND** les autres variables sont conservées

### Requirement: aide CLI

Les commandes suivantes MUST être décrites :

- `diu projects gitlab help` affiche `update` et `push` avec leur description succincte ;
- `diu projects gitlab update help` décrit la vérification, la modification ou la création des variables GitLab ;
- `diu projects help` conserve l'entrée de niveau `gitlab`.

#### Scenario: aide GitLab disponible

- **GIVEN** que l'utilisateur demande l'aide GitLab
- **WHEN** l'aide est affichée
- **THEN** les commandes `update` et `push` sont décrites
- **AND** l'entrée `gitlab` reste disponible dans l'aide des projets
