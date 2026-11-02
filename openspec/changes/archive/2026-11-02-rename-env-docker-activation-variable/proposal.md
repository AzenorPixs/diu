# Renommer le contrôle de provisionnement Docker

## Pourquoi

Le point d'entrée consulte `ENV_DOCKER` sous `set -u`, mais aucune déclaration
ne l'initialise. Le lancement s'arrête au début du provisionnement Docker.

## Changements

- Déclarer `ENVIRONMENT_DOCKER` en `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- Migrer exactement l'ancienne valeur `ENV_DOCKER=0|1` vers
  `environnements.env`, en respectant la priorité d'un nouveau nom déjà
  configuré.
- Remplacer le contrôle du bloc de provisionnement Docker et préserver les
  variables voisines `ENV_DOCKER_USER`, `ENV_DOCKER_GROUP`, etc.
