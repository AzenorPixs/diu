# Design

Le module `docker_user.sh` déclare le nom de compte `ENVIRONMENT_DOCKER_USER`
dans le scope `docker`. `config_cleanup` migre un ancien littéral simple
`DOCKER_USER` de `variables.sh` ou `docker.env`, conserve un nouveau nom déjà
déclaré, puis supprime l'ancien. Les valeurs sont validées comme noms de compte
simples avant usage dans les chemins Docker.

Le point d'entrée utilise le nouveau nom pour les chemins et commandes des
stacks, sans remplacer les autres paramètres tels que `ENV_DOCKER_USER`.
