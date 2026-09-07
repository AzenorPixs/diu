# Configuration différentielle GitLab des projets DIU

## Exigence : séparation des configurations

La configuration générale d'un projet et sa configuration GitLab DOIVENT être traitées par deux fonctions distinctes.

La fonction générique `git_update()` DOIT rester responsable des variables générales du projet et des variables Forgejo existantes. La fonction `gitlab_update()` DOIT être limitée aux variables `REMOTE_GITLAB_*`.

## Exigence : validation préalable de la configuration générale

Avant de compléter GitLab, `gitlab_update()` DOIT vérifier la présence et la conformité de `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` et `PROJECT_DOCKERED` dans `project.env`.

### Scénario : configuration générale absente ou incomplète

- ÉTANT DONNÉ que `project.env` est absent ou qu'une variable générale essentielle est absente
- QUAND `rid projects gitlab push <ID PROJECT>` est exécuté
- ALORS `gitlab_update()` appelle `git_update()` pour compléter la configuration générale
- ET la configuration GitLab n'est traitée qu'après cette complétion

## Exigence : complément GitLab ciblé

`gitlab_update()` DOIT demander et enregistrer uniquement les variables suivantes :

```bash
REMOTE_GITLAB_BASE_URL=
REMOTE_GITLAB_OWNER=
REMOTE_GITLAB_REPOSITORY="<ID PROJECT>"
REMOTE_GITLAB_NAME="origin"
REMOTE_GITLAB_BRANCH="main"
```

La fonction DOIT préserver toutes les autres lignes de `project.env`, notamment les variables générales et Forgejo.

### Scénario : configuration GitLab absente

- ÉTANT DONNÉ que la configuration générale est conforme
- ET que les variables GitLab sont absentes ou incomplètes
- QUAND un push GitLab est demandé
- ALORS seules les valeurs GitLab manquantes sont demandées avec leurs valeurs par défaut
- ET les variables GitLab sont ajoutées ou remplacées sans réécrire le reste de `project.env`

## Exigence : contrôle avant publication

Après `gitlab_update()`, la commande GitLab DOIT recharger `project.env`, revérifier les variables générales essentielles, puis vérifier la complétude des variables `REMOTE_GITLAB_*` avant tout push.
