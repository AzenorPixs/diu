# Déclarer le propriétaire des stacks Docker

## Pourquoi

Le profil Docker utilise `DOCKER_USER` pour choisir le compte propriétaire des
stacks et de leurs répertoires. Sous `set -u`, son absence arrête le lancement
du DIU.

## Changements

- Déclarer `ENVIRONMENT_DOCKER_USER` en `STATIC`, `ENABLE`, scope `docker`,
  défaut `docker`.
- Migrer l'ancienne valeur de `DOCKER_USER` exactement vers `docker.env`, avec
  priorité à `ENVIRONMENT_DOCKER_USER` déjà configuré.
- Renommer tous les consommateurs exacts de `DOCKER_USER` sans modifier les
  paramètres distincts `ENV_DOCKER_USER`.
