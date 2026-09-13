# Mise à jour ciblée de la configuration GitLab des projets DIU

## Purpose

Définir la mise à jour ciblée de la configuration GitLab d'un projet DIU.

## Requirements

### Requirement: commande de mise à jour GitLab

Le système MUST exposer la commande `rid projects gitlab update <ID PROJECT>`.

#### Scenario: vérifier une configuration GitLab existante

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS les valeurs `REMOTE_GITLAB_*` existantes sont affichées comme valeurs courantes
- ET l'utilisateur peut les conserver ou les modifier
- ET les variables générales et Forgejo sont conservées

#### Scenario: créer une configuration GitLab absente

- ÉTANT DONNÉ que la configuration générale est conforme
- ET que les variables `REMOTE_GITLAB_*` sont absentes ou incomplètes
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS seules les variables GitLab sont demandées
- ET `REMOTE_GITLAB_REPOSITORY` prend par défaut l'identifiant du projet
- ET `REMOTE_GITLAB_NAME` prend par défaut `origin`
- ET `REMOTE_GITLAB_BRANCH` prend par défaut `main`

#### Scenario: configuration générale non conforme

- ÉTANT DONNÉ que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou `PROJECT_DOCKERED` est absent ou incorrect
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS la fonction `update_projects()` est appelée pour compléter la configuration générale
- ET les variables GitLab sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `gitlab_update()` MUST modifier uniquement le bloc des variables `REMOTE_GITLAB_*` dans `project.env` et MUST conserver les autres variables du projet.

#### Scenario: conservation des variables hors GitLab

- ÉTANT DONNÉ que `project.env` contient des variables générales et Forgejo
- QUAND `gitlab_update()` met à jour la configuration GitLab
- ALORS seules les variables `REMOTE_GITLAB_*` sont modifiées
- ET les autres variables sont conservées

### Requirement: aide CLI

Les commandes suivantes MUST être décrites :

- `rid projects gitlab help` affiche `update` et `push` avec leur description succincte ;
- `rid projects gitlab update help` décrit la vérification, la modification ou la création des variables GitLab ;
- `rid projects help` conserve l'entrée de niveau `gitlab`.

#### Scenario: aide GitLab disponible

- ÉTANT DONNÉ que l'utilisateur demande l'aide GitLab
- QUAND l'aide est affichée
- ALORS les commandes `update` et `push` sont décrites
- ET l'entrée `gitlab` reste disponible dans l'aide des projets
