# Renommer l'activation de l'environnement DevOps

## Pourquoi

Le point d'entrée consulte `ENV_DEVOPS` sous `set -u`, mais aucune déclaration
ne l'initialise. Le lancement de l'installation s'arrête avant le bloc de
création du profil DevOps.

## Changements

- Déclarer `ENVIRONMENTS_DEVOPS` en `STATIC`, `ENABLE`, scope `environnements`,
  défaut `0`.
- Migrer exactement l'ancienne valeur `ENV_DEVOPS=0|1` vers
  `environnements.env`, en privilégiant un `ENVIRONMENTS_DEVOPS` déjà déclaré.
- Remplacer le contrôle du bloc d'installation DevOps et les références des
  specs par le nouveau nom.
