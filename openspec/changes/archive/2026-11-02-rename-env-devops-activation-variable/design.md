# Design

Le module `env_devops.sh` déclare `ENVIRONMENTS_DEVOPS` en `STATIC`, `ENABLE`,
scope `environnements`, défaut `0`. `config_cleanup` migre `ENV_DEVOPS=0|1` de
`variables.sh` ou de `environnements.env`, conserve la priorité de
`ENVIRONMENTS_DEVOPS` et supprime les anciennes affectations après écriture
réussie. Les variables voisines comme `ENV_DEVOPS_USER` restent inchangées.

Le point d'entrée et les parcours Python/Sudoers utilisent le nouveau
interrupteur avec repli désactivé si la variable n'est pas définie.
