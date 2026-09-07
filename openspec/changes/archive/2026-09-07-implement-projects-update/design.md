# Conception

`update_projects()` charge la configuration existante, propose les valeurs
actuelles avec les défauts `BASH`, `No` et `No`, puis met à jour uniquement les
variables `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED` et
`PROJECT_DEBIAN_PACKAGE` dans `project.env`.

`git_update()` conserve son support interne des modes historiques `clone` et
`gitlab`, mais son mode `local` devient la mise à jour ciblée de
`LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et `GIT_USER_EMAIL`. Lorsque la
configuration générale est absente ou incomplète, il appelle
`update_projects()` avant de traiter le dépôt local. Les lignes non concernées
de `project.env` sont conservées.

La création d'un projet appelle successivement `update_projects()` puis
`git_update()`. Les compléments de configuration des fournisseurs distants
continuent d'utiliser `git_update()` selon leurs modes existants et leurs
fonctions dédiées.

L'aide `rid projects help` et ses chemins d'aide anticipée listent toutes les
sous-commandes de premier niveau de `projects`, dont les nouvelles commandes
`update` et `git update`.
