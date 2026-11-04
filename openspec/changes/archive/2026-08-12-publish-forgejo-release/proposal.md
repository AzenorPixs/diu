# ART02 — Publication des releases Forgejo

## Why

Le DIU ne possède aucun moyen automatisé de publier une Release Forgejo
contenant le paquet Debian construit par `build_deb()`. La publication
manuelle est sujette aux erreurs et ne garantit pas la cohérence entre
le tag, la Release et l'asset uploadé. Une fonction `publish_release()`
dédiée permettra de automatiser cette étape tout en restant indépendante
de `git_push()` et `build_deb()`.

## What Changes

- Ajout d'une commande `rid proj rel <project_id>` déclenchant la
  publication d'une Release Forgejo
- Création d'un module `modules/projects/forgejo-release.sh` contenant
  la fonction `publish_release()` responsable de la publication
- La fonction vérifie la cohérence du paquet `.deb` dans `dist/`
  (nom, Package, Version) avant toute publication
- La fonction vérifie la synchronisation Git (HEAD == origin/main)
  avant publication
- La fonction gère l'authentification via token stocké dans
  `config/forgejo.token` avec bootstrap automatique si absent
- La fonction crée le tag `v<VERSION>`, la Release, puis upload le
  paquet comme asset via l'API REST Forgejo (curl + jq)
- Les Releases existantes ne sont jamais écrasées (immutabilité)
- Adaptation du `.gitignore` pour exclure `config/forgejo.token`

## Capabilities

### New Capabilities

- `forgejo-release`: Publication d'une Release Forgejo à partir du
  paquet Debian construit, incluant la vérification Git, la gestion
  du token d'authentification, la création de Release et l'upload
  de l'asset

### Modified Capabilities

Aucune. La fonction `publish_release()` est une responsabilité distincte
qui ne modifie pas le comportement de `build_deb()`, `git_push()` ou
du packaging Debian existant.

## Impact

- Nouveau fichier : `modules/projects/forgejo-release.sh`
- Modification de `root-install-debian.sh` : ajout du sourcing du
  nouveau module et du dispatch vers `publish_release()` via
  `manage_project_action`
- Ajout de `config/forgejo.token` dans `.gitignore`
- Nouvelle dépendance runtime : `curl` et `jq` (vérifiés en amont)
- Aucune modification de `modules/projects/packaging.sh`
- Aucune modification de `variables.sh`
