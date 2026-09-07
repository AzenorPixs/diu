# Design

La commande `rid projects gitlab release <ID PROJECT>` s'appuie sur deux étapes:

- validation/complétion de la configuration (`update_projects` puis `gitlab_update`)
  avant toute publication;
- publication conditionnelle de Docker puis Debian selon `PROJECT_DOCKERED` et
  `PROJECT_DEBIAN_PACKAGE`.

La logique d'artefacts Docker s'inspire de `projects_forgejo_release_docker` et
pousse vers le registre GitLab calculé à partir de `REMOTE_GITLAB_BASE_URL`,
`REMOTE_GITLAB_OWNER` et `REMOTE_GITLAB_REPOSITORY`.

La logique Debian appelle une API GitLab (`api/v4`) pour créer/valider la release
et joindre le fichier `.deb` depuis `dist/`.

Les prérequis déjà existants sont réutilisés: `project.env`, `update_projects`,
`gitlab_update` et l'authentification locale GitLab.
