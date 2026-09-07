# Conception

`gitlab_remote_ensure()` reçoit le chemin du dépôt, le nom du remote et l'URL GitLab attendue. Il utilise l'utilisateur DevOps pour interroger le remote en mode push. Si le remote est absent, il est ajouté ; s'il existe avec une URL différente, l'opération est refusée sans modification.

`git_push()` appelle cette fonction après avoir construit l'URL GitLab et avant les contrôles de cohérence et le push. `lib/gitlab-auth.sh` reçoit également le nom du remote afin de ne plus dépendre implicitement de `origin`.
