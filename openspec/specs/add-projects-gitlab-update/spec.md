# Mise à jour ciblée de la configuration GitLab des projets DIU

## Exigence : commande de mise à jour GitLab

Le système DOIT exposer la commande `rid projects gitlab update <ID PROJECT>`.

### Scénario : vérifier une configuration GitLab existante

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS les valeurs `REMOTE_GITLAB_*` existantes sont affichées comme valeurs courantes
- ET l'utilisateur peut les conserver ou les modifier
- ET les variables générales et Forgejo sont conservées

### Scénario : créer une configuration GitLab absente

- ÉTANT DONNÉ que la configuration générale est conforme
- ET que les variables `REMOTE_GITLAB_*` sont absentes ou incomplètes
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS seules les variables GitLab sont demandées
- ET `REMOTE_GITLAB_REPOSITORY` prend par défaut l'identifiant du projet
- ET `REMOTE_GITLAB_NAME` prend par défaut `origin`
- ET `REMOTE_GITLAB_BRANCH` prend par défaut `main`

### Scénario : configuration générale non conforme

- ÉTANT DONNÉ que `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` ou `PROJECT_DOCKERED` est absent ou incorrect
- QUAND l'utilisateur exécute `rid projects gitlab update <ID PROJECT>`
- ALORS la fonction générique `git_update()` est appelée pour compléter la configuration générale
- ET les variables GitLab sont traitées après cette complétion

## Exigence : conservation de project.env

La fonction `gitlab_update()` DOIT modifier uniquement le bloc des variables `REMOTE_GITLAB_*` dans `project.env` et DOIT conserver les autres variables du projet.

## Exigence : aide CLI

Les commandes suivantes DOIVENT être décrites :

- `rid projects gitlab help` affiche `update` et `push` avec leur description succincte ;
- `rid projects gitlab update help` décrit la vérification, la modification ou la création des variables GitLab ;
- `rid projects help` conserve l'entrée de niveau `gitlab`.
