# Design

Le module `environment_docker.sh` déclare `ENVIRONMENT_DOCKER` en `STATIC`,
`ENABLE`, scope `environnements`, défaut `0`. `config_cleanup` transfère les
valeurs littérales `0` ou `1` de `ENV_DOCKER` depuis `variables.sh` ou
`environnements.env`, conserve la priorité du nouveau nom, puis supprime
l'ancien export. Les paramètres `ENV_DOCKER_*` restent inchangés. Le point
d'entrée utilise le nouvel interrupteur avec repli `0`.
