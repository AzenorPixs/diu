# Déclarer le réglage de mise à jour Traefik/Dockhand

## Pourquoi

Le point d’entrée consulte `DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE` sous
`set -u`, mais ce réglage n’a pas de déclaration dans le scope Docker.

## Changements

- Déclarer `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` en `STATIC`, `ENABLE`, scope
  `docker`, défaut `0`.
- Migrer exactement la valeur historique `DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE=0|1`
  vers `docker.env`, sauf si la nouvelle variable y est déjà définie.
- Utiliser le nouveau nom dans les trois consommateurs de mise à jour et
  préserver les réglages de version voisins.
