# Conception

Le sous-dispatch `projects forgejo` reconnaît `update` et délègue à
`forgejo_update <ID PROJECT>`. La fonction vérifie d'abord que
`PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE` et `PROJECT_DOCKERED` sont
conformes. Si nécessaire, elle appelle `git_update <ID PROJECT> local`, puis
recharge `project.env`.

La mise à jour collecte les valeurs courantes avec les défauts
`<ID PROJECT>`, `origin`, `main` et `No`, puis remplace uniquement le bloc des
variables `REMOTE_FORGEJO_*`. Les variables générales, Forgejo historique,
GitLab et GitHub sont conservées.

