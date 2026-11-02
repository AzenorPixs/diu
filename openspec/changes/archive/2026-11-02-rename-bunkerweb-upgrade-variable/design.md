# Conception

Le module `docker_stack_bunkerweb_update.sh` déclarera l’interrupteur statique
dans le scope Docker. `config_cleanup` migrera la dernière valeur littérale
`0|1` de `DOCKER_STACK_BUNKERWEB_UPGRADE` vers `DOCKER_STACK_BUNKERWEB_UPDATE`
dans `docker.env`, avec priorité à une nouvelle valeur préexistante. Les trois
consommateurs utiliseront le nouveau nom; les réglages auto-update et version
restent inchangés.
