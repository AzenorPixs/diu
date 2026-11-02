# Conception — DOCKER_STACK_DEVOPS

Ajouter une déclaration statique sous
`modules/diu/variables/docker/docker_stack_devops.sh`, avec le nom actuel,
l’état `ENABLE`, le scope `docker` et le défaut `0`. Le chargeur existant
découvre le fichier sans liste centrale. Si l’environnement ou `docker.env` a
déjà fourni `0` ou `1`, la déclaration conserve et exporte cette valeur.
Sinon, elle persiste puis exporte `0`. Les valeurs hors `0/1` sont refusées.
Le consommateur existant de la stack ne change pas.
