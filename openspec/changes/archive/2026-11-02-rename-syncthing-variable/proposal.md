# Renommer le contrôle Syncthing

## Pourquoi

Le point d’entrée consulte `SYNCTHING` sous `set -u`, mais cette variable ne
suit pas le mécanisme déclaratif DIU. Elle pilote aussi la préparation du
fichier `.stignore` pour l’environnement DevOps.

## Changements

- Déclarer `SOFTWARES_APT_SYNCTHING` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `SYNCTHING=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour l’installation APT et la préparation
  conditionnelle de `.stignore`.
