## Context

Le flux reprend `gitlab_clone` avec les variables `REMOTE_GITHUB_*` et les
identifiants locaux GitHub. Le clonage est réalisé sous `DEVOPS_USER`.

## Decisions

- La commande appelle `create_project`, puis `github_update`, puis le clonage.
- Un arbre temporaire prépare la fusion, en retirant chaque fichier ou
  répertoire `.git` avant le remplacement transactionnel du projet.
- Les erreurs de clonage ou de fusion nettoient les artefacts temporaires et
  préservent le projet initialisé.
