# Conception

Le module `docker_stack_traefik_dockhand_update.sh` déclarera l’interrupteur
statique dans le scope Docker. `config_cleanup` migrera la dernière valeur
littérale `0|1` de `DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE` vers
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` dans `docker.env`, avec priorité à une
valeur nouvelle préexistante. Les trois consommateurs utiliseront le nouveau
nom; les réglages de version de la stack resteront inchangés.
