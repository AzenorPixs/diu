# Conception

`gitlab_update()` ajoute `REMOTE_GITLAB_SSL_VERIFY` au bloc GitLab de `project.env`, avec `No` comme valeur par défaut et une normalisation explicite vers `Yes` ou `No`.

`_gitlab_git_with_token()` encapsule l'appel commun `git_with_token()`. Lorsque la valeur est `No`, il exporte `GIT_SSL_NO_VERIFY=true` uniquement dans une sous-exécution limitée à la commande GitLab. Lorsque la valeur est `Yes`, il conserve le comportement TLS normal.

Aucune variable Git globale et aucune configuration Forgejo ne sont modifiées.
