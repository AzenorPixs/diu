# Renommer le contrôle Postfix

## Pourquoi

Le point d’entrée consulte `POSTFIX` sous `set -u`, mais cette variable ne
suit pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_POSTFIX` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `POSTFIX=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour piloter l’installation APT et conserver
  l’utilisation de `POSTFIX_RELAY_HOST` pour la configuration du relais.
