# Conception

`gitlab_project_config_ensure()` vérifie `project.env` et les quatre variables générales essentielles. En cas d'absence ou de non-conformité, `gitlab_update()` appelle `git_update <ID PROJECT> local`, puis effectue une nouvelle vérification.

`gitlab_update()` recharge uniquement les variables `REMOTE_GITLAB_*`, demande leurs valeurs avec les défauts prévus, puis filtre les anciennes lignes GitLab dans un fichier temporaire avant d'ajouter le nouveau bloc. Les autres lignes du fichier sont conservées.

`git_push()` utilise ce parcours ciblé lorsque le fournisseur demandé est GitLab. Il recharge ensuite la configuration et maintient le contrôle final des variables générales et GitLab avant de déléguer à `gitlab_git_push()`.
