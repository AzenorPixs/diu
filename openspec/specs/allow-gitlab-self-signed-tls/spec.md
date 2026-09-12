# Désactivation explicite de la vérification TLS GitLab

## Purpose

Définir le contrôle explicite de la vérification TLS pour GitLab.

## Requirements

### Requirement: option TLS GitLab explicite

La configuration GitLab MUST exposer `REMOTE_GITLAB_SSL_VERIFY` dans `project.env` avec les valeurs `Yes` ou `No`.

La valeur `No` MUST désactiver explicitement la vérification du certificat TLS uniquement pour les opérations GitLab authentifiées. Elle MUST être visible dans la configuration et ne MUST pas modifier la configuration TLS globale de Git.

#### Scenario: certificat GitLab autosigné

- ÉTANT DONNÉ que `REMOTE_GITLAB_SSL_VERIFY=No`
- QUAND `rid projects gitlab push <ID PROJECT>` est exécuté
- ALORS GitLab est contacté avec la vérification du certificat désactivée
- ET le token est toujours transmis uniquement par le mécanisme temporaire existant
- ET la vérification TLS des autres fournisseurs reste inchangée

#### Scenario: vérification TLS conservée

- ÉTANT DONNÉ que `REMOTE_GITLAB_SSL_VERIFY=Yes`
- QUAND une opération GitLab authentifiée est exécutée
- ALORS Git utilise la vérification normale des certificats TLS

### Requirement: mise à jour ciblée

`gitlab_update()` MUST afficher et permettre de modifier `REMOTE_GITLAB_SSL_VERIFY` sans demander ni réécrire les variables générales ou Forgejo.

La valeur par défaut de la fonction d'initialisation GitLab MUST être `No` afin de permettre l'utilisation documentée avec un certificat autosigné dès la première configuration.

#### Scenario: mise à jour de la vérification TLS

- ÉTANT DONNÉ une configuration GitLab existante
- QUAND `gitlab_update()` est exécutée
- ALORS `REMOTE_GITLAB_SSL_VERIFY` est affichée et peut être modifiée
- ET les variables générales et Forgejo ne sont pas réécrites
