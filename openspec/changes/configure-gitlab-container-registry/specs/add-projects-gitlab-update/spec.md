## MODIFIED Requirements

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
