# Configuration différentielle GitLab des projets DIU

## Purpose

Définir la séparation entre les configurations générale et GitLab d'un projet.

## Requirements

### Requirement: séparation des configurations

La configuration générale d'un projet et sa configuration GitLab MUST être traitées par deux fonctions distinctes.

La fonction `update_projects()` MUST rester responsable des variables générales du projet. La fonction `git_update()` est limitée aux variables Git locales et `gitlab_update()` MUST être limitée aux variables `REMOTE_GITLAB_*`.

#### Scenario: responsabilités séparées

- ÉTANT DONNÉ qu'une mise à jour de configuration est demandée
- QUAND la configuration GitLab est traitée
- ALORS `gitlab_update()` ne modifie que les variables `REMOTE_GITLAB_*`
- ET `update_projects()` et `git_update()` conservent leurs responsabilités respectives

### Requirement: validation préalable de la configuration générale

Avant de compléter GitLab, `gitlab_update()` MUST vérifier la présence et la conformité de `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` et `PROJECT_DOCKERED` dans `project.env`.

#### Scenario: configuration générale absente ou incomplète

- ÉTANT DONNÉ que `project.env` est absent ou qu'une variable générale essentielle est absente
- QUAND `diu projects gitlab push <ID PROJECT>` est exécuté
- ALORS `gitlab_update()` appelle `update_projects()` pour compléter la configuration générale
- ET la configuration GitLab n'est traitée qu'après cette complétion

### Requirement: complément GitLab ciblé

`gitlab_update()` MUST demander et enregistrer uniquement les variables
suivantes :

```bash
REMOTE_GITLAB_BASE_URL=
REMOTE_GITLAB_REGISTRY=
REMOTE_GITLAB_OWNER=
REMOTE_GITLAB_REPOSITORY="<ID PROJECT>"
REMOTE_GITLAB_NAME="origin"
REMOTE_GITLAB_BRANCH="main"
```

`REMOTE_GITLAB_REGISTRY` MUST contenir l'adresse explicite du registre Docker,
avec son port lorsqu'il est requis. La fonction DOIT préserver toutes les autres
lignes de `project.env`, notamment les variables générales et Forgejo.

#### Scenario: configuration GitLab absente

- **GIVEN** que la configuration générale est conforme
- **AND** que les variables GitLab sont absentes ou incomplètes
- **WHEN** un push GitLab est demandé
- **THEN** seules les valeurs GitLab manquantes sont demandées avec leurs
  valeurs par défaut
- **AND** `REMOTE_GITLAB_REGISTRY` est demandée et enregistrée comme registre
  Docker explicite
- **AND** les variables GitLab sont ajoutées ou remplacées sans réécrire le
  reste de `project.env`

### Requirement: contrôle avant publication

Après `gitlab_update()`, la commande GitLab MUST recharger `project.env`, revérifier les variables générales essentielles, puis vérifier la complétude des variables `REMOTE_GITLAB_*` avant tout push.

#### Scenario: contrôle avant push GitLab

- ÉTANT DONNÉ que `gitlab_update()` vient de terminer
- QUAND un push GitLab est sur le point de démarrer
- ALORS `project.env` est rechargé et les variables requises sont vérifiées
- ET aucun push ne commence si la configuration est incomplète
