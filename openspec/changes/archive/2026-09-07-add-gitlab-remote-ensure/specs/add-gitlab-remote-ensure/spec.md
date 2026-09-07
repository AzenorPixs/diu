# Gestion automatique du remote GitLab des projets DIU

## Exigence : remote GitLab dédié

La commande `rid projects gitlab push <ID PROJECT>` DOIT utiliser le remote défini par `REMOTE_GITLAB_NAME` et ne DOIT pas modifier le remote Forgejo `origin` lorsque les deux noms sont différents.

### Scénario : remote GitLab absent

- ÉTANT DONNÉ que `REMOTE_GITLAB_NAME` et les variables `REMOTE_GITLAB_*` sont conformes
- ET que le remote GitLab n'existe pas dans le dépôt local
- QUAND `rid projects gitlab push <ID PROJECT>` est exécuté
- ALORS le remote GitLab est ajouté avec l'URL construite depuis `REMOTE_GITLAB_BASE_URL`, `REMOTE_GITLAB_OWNER` et `REMOTE_GITLAB_REPOSITORY`
- ET le push est effectué vers ce remote

### Scénario : remote GitLab déjà conforme

- ÉTANT DONNÉ que le remote défini par `REMOTE_GITLAB_NAME` existe
- ET que son URL correspond à la configuration GitLab
- QUAND un push GitLab est demandé
- ALORS le remote est conservé sans modification
- ET le push est effectué vers ce remote

### Scénario : remote GitLab incohérent

- ÉTANT DONNÉ que le remote défini par `REMOTE_GITLAB_NAME` existe avec une autre URL
- QUAND un push GitLab est demandé
- ALORS la commande échoue explicitement
- ET aucun remote existant n'est écrasé

## Exigence : identifiants et remote sélectionné

La validation du remote et la résolution du dépôt GitLab DOIVENT utiliser `REMOTE_GITLAB_NAME`, y compris lorsque sa valeur est `ecn`. Le mécanisme d'identification temporaire existant DOIT rester utilisé pour le token.
