# Renommer le contrôle du serveur SSH

## Pourquoi

Le point d’entrée consulte `SSH` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU. Elle pilote l’installation du serveur
OpenSSH et la préparation des clés autorisées.

## Changements

- Déclarer `SOFTWARES_APT_SSH_SERVER` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `SSH=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour les deux consommateurs SSH et préserver les
  variables de clés `KEY_SSH_*`.
