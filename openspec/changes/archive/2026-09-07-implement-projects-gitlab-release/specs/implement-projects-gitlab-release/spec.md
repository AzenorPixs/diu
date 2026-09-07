# Release GitLab des projets DIU

## Requirements

### Requirement: commande de release GitLab

Le système SHALL exposer la commande `rid projects gitlab release <ID PROJECT>`.

#### Scenario: release d'un projet Dockerisé

- ÉTANT DONNÉ le dépôt local du projet `diu`.
- QUAND l'utilisateur exécute `rid projects gitlab release diu`.
- ALORS l'image Docker locale `diu:latest` est poussée vers le registre GitLab configuré.

### Requirement: initialisation de configuration incomplète

Si `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED`,
`PROJECT_DEBIAN_PACKAGE` ou toute variable `REMOTE_GITLAB_*` attendue est manquante,
`projects_gitlab_release` SHALL appeler automatiquement:
- `update_projects <ID PROJECT>`
- `gitlab_update <ID PROJECT>`

Puis la fonction reprend la commande de release.

### Requirement: publication Docker conditionnelle

Lorsque `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`, la commande SHALL tenter la
publication Docker.

Lorsque `PROJECT_DOCKERED` n’a pas cette valeur, la commande SHALL ignorer la
partie Docker.

### Requirement: publication Debian conditionnelle

Lorsque `PROJECT_DEBIAN_PACKAGE` vaut `Yes`, `YES` ou `1`, la commande SHALL tenter
la publication du paquet Debian.

Lorsque `PROJECT_DEBIAN_PACKAGE` n’a pas cette valeur, la commande SHALL ignorer la
partie Debian.

### Requirement: sélection de paquet Debian

Lorsque le répertoire `dist/` est requis par la configuration Debian:

- s'il est absent → la commande SHALL retourner une erreur explicite.
- s'il contient zéro `.deb` → la commande SHALL retourner une erreur explicite.
- s'il contient plus d'un `.deb` → la commande SHALL retourner une erreur explicite
en listant les fichiers détectés.
- s'il contient un seul `.deb` → la commande poursuit la publication GitLab.

### Requirement: aide CLI

`rid projects help` SHALL présenter `gitlab` avec `release`.

`rid projects gitlab help` SHALL présenter `update`, `push` et `release`.

`rid projects gitlab release <ID PROJECT>` SHALL afficher une aide cohérente.

### Requirement: compatibilité

L'ajout de `projects gitlab release` SHALL préserver les comportements existants
de `rid projects gitlab push`, `projects_forgejo_release`, `git_push_provider` et des
parcours d'authentification GitLab.
