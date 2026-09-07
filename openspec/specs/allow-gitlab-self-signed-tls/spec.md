# Désactivation explicite de la vérification TLS GitLab

## Exigence : option TLS GitLab explicite

La configuration GitLab DOIT exposer `REMOTE_GITLAB_SSL_VERIFY` dans `project.env` avec les valeurs `Yes` ou `No`.

La valeur `No` DOIT désactiver explicitement la vérification du certificat TLS uniquement pour les opérations GitLab authentifiées. Elle DOIT être visible dans la configuration et ne DOIT pas modifier la configuration TLS globale de Git.

### Scénario : certificat GitLab autosigné

- ÉTANT DONNÉ que `REMOTE_GITLAB_SSL_VERIFY=No`
- QUAND `rid projects gitlab push <ID PROJECT>` est exécuté
- ALORS GitLab est contacté avec la vérification du certificat désactivée
- ET le token est toujours transmis uniquement par le mécanisme temporaire existant
- ET la vérification TLS des autres fournisseurs reste inchangée

### Scénario : vérification TLS conservée

- ÉTANT DONNÉ que `REMOTE_GITLAB_SSL_VERIFY=Yes`
- QUAND une opération GitLab authentifiée est exécutée
- ALORS Git utilise la vérification normale des certificats TLS

## Exigence : mise à jour ciblée

`gitlab_update()` DOIT afficher et permettre de modifier `REMOTE_GITLAB_SSL_VERIFY` sans demander ni réécrire les variables générales ou Forgejo.

La valeur par défaut de la fonction d'initialisation GitLab DOIT être `No` afin de permettre l'utilisation documentée avec un certificat autosigné dès la première configuration.
