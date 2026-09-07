# Conception

Le sous-dispatch `projects gitlab` reconnaît l'action `update` et la délègue directement à `gitlab_update <ID PROJECT>`. La fonction existante conserve sa séparation avec `git_update()` : elle vérifie d'abord la configuration générale, demande son complément générique si nécessaire, puis ne traite que les variables `REMOTE_GITLAB_*`.

Les entrées `projects:gitlab:` et `projects:gitlab:update` de l'aide CLI décrivent respectivement les actions disponibles et l'action détaillée.
