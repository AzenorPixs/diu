# Conception

Le sous-dispatch `projects github` reconnaît `update` et délègue à
`github_update <ID PROJECT>`. La fonction vérifie d'abord que
`PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` et `PROJECT_DOCKERED` sont
conformes. Si nécessaire, elle appelle `git_update <ID PROJECT> local`, puis
recharge `project.env`.

La mise à jour collecte les valeurs courantes avec les défauts
`<ID PROJECT>`, `origin` et `main`, puis remplace uniquement le bloc des
variables `REMOTE_GITHUB_*`. Les variables générales, Forgejo et GitLab sont
conservées.
