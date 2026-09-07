# Conception

Le dispatch de `rid projects gitlab push <ID PROJECT>` reste dans `root-install-debian.sh`, qui délègue la publication à `gitlab_push()` dans `modules/projects/git.sh`.

`git_push()` sélectionne le fournisseur à partir de `REMOTE_GIT_TYPE`. Les paramètres GitLab sont lus depuis `REMOTE_GITLAB_BASE_URL`, `REMOTE_GITLAB_OWNER`, `REMOTE_GITLAB_REPOSITORY`, `REMOTE_GITLAB_NAME` et `REMOTE_GITLAB_BRANCH`. Lorsque la configuration est absente, `git_update <ID PROJECT> gitlab` collecte ces valeurs et les écrit dans `project.env`.

Le fournisseur `lib/gitlab-auth.sh` reprend le découpage Forgejo : résolution du remote HTTPS, lecture contrôlée des fichiers d'identifiants, initialisation interactive au premier usage, puis appel à `git_with_token`. Les secrets restent hors des sorties et ne sont pas persistés dans la configuration du remote Git.

La commande d'aide globale intercepte les suffixes `help` et utilise des entrées dédiées pour chacun des niveaux demandés.
