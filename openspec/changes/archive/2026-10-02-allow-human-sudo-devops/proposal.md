# Why

Les comptes humains locaux doivent pouvoir exécuter des commandes comme
`ENV_DEVOPS_USER` sans mot de passe lorsque l'environnement DevOps est activé.
Le bloc existant prépare ce compte mais ne génère aucune règle sudoers dédiée.

# What Changes

- Ajouter la génération à la fin du bloc `ENV_DEVOPS` du point d'entrée.
- Retenir les comptes locaux dans la plage `UID_MIN`–`UID_MAX` de
  `/etc/login.defs`, avec un shell de connexion existant et exécutable ; exclure
  `root`, les shells `nologin` et `false`, ainsi que les comptes configurés
  `ENV_DEVOPS_USER`, `ENV_DOCKER_USER` et `ENV_IA_USER`.
- Gérer uniquement `/etc/sudoers.d/99-diu-devops`, validé avant remplacement,
  avec propriétaire `root:root` et permissions `0440`.
- Ajouter des tests isolés et documenter cette convention de comptes humains.

# Impact

Les comptes sélectionnés obtiennent tous les droits du compte DevOps via
`sudo -u` ou `sudo -iu`. Aucun droit direct comme root, changement PAM de `su`,
effet Git ou configuration système de la machine de développement n'est inclus.
La spécification, l'implémentation, les tests et l'archivage sont autorisés par
le développeur dans cette session, après la proposition de périmètre SCM.
