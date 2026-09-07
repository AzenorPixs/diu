# implement-projects-forgejo-update Specification

## Purpose
Définir la création et la mise à jour ciblées de la configuration Forgejo d'un
projet DIU, sans altérer ses autres configurations.

## Requirements

### Requirement: commande de mise à jour Forgejo

Le système MUST exposer la commande
`rid projects forgejo update <ID PROJECT>`.

#### Scenario: vérifier une configuration Forgejo existante

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `rid projects forgejo update <ID PROJECT>`
- ALORS les valeurs `REMOTE_FORGEJO_*` existantes sont proposées comme valeurs
  courantes
- ET l'utilisateur peut les conserver ou les modifier
- ET les variables générales, Forgejo historique, GitLab et GitHub sont
  conservées

#### Scenario: créer une configuration Forgejo absente

- ÉTANT DONNÉ que la configuration générale est conforme
- ET que les variables `REMOTE_FORGEJO_*` sont absentes ou incomplètes
- QUAND l'utilisateur exécute `rid projects forgejo update <ID PROJECT>`
- ALORS seules les valeurs Forgejo sont demandées
- ET `REMOTE_FORGEJO_REPOSITORY` prend par défaut l'identifiant du projet
- ET `REMOTE_FORGEJO_NAME` prend par défaut `origin`
- ET `REMOTE_FORGEJO_BRANCH` prend par défaut `main`
- ET `REMOTE_FORGEJO_SSL_VERIFY` prend par défaut `No`

#### Scenario: configuration générale non conforme

- ÉTANT DONNÉ que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou
  `PROJECT_DOCKERED` est absent ou incorrect
- QUAND l'utilisateur exécute `rid projects forgejo update <ID PROJECT>`
- ALORS la fonction générique `git_update()` est appelée pour compléter la
  configuration générale
- ET les variables Forgejo sont traitées après cette complétion

### Requirement: conservation de project.env

La fonction `forgejo_update()` MUST modifier uniquement le bloc des variables
`REMOTE_FORGEJO_*` dans `project.env` et DOIT conserver toutes les autres
variables du projet, notamment les variables générales, Forgejo historique,
GitLab et GitHub.

#### Scenario: conservation des variables concurrentes

- ÉTANT DONNÉ que `project.env` contient des variables générales, Forgejo
  historique, GitLab ou GitHub
- QUAND `forgejo_update()` enregistre la configuration
- ALORS ces variables et leurs valeurs sont conservées

### Requirement: validation des valeurs

`REMOTE_FORGEJO_BASE_URL` et `REMOTE_FORGEJO_OWNER` MUST être non vides.
`REMOTE_FORGEJO_SSL_VERIFY` MUST valoir `Yes` ou `No` après normalisation.

#### Scenario: valeur TLS invalide

- ÉTANT DONNÉ que l'utilisateur saisit une valeur différente de `Yes` ou `No`
- QUAND `forgejo_update()` traite la configuration
- ALORS la fonction échoue explicitement
- ET `project.env` n'est pas remplacé par une configuration invalide

### Requirement: aide CLI

Les commandes suivantes MUST être décrites :

- `rid projects forgejo help` affiche `update` et `push` ;
- `rid projects forgejo update help` décrit la vérification, la modification
  ou la création des variables Forgejo ;
- `rid projects help` conserve l'entrée de niveau `forgejo`.

#### Scenario: aide de mise à jour

- ÉTANT DONNÉ que l'utilisateur demande `rid projects forgejo update help`
- QUAND l'aide est affichée
- ALORS la description de la mise à jour et sa syntaxe sont affichées
