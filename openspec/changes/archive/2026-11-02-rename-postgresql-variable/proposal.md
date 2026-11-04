# Renommer le contrôle d’installation PostgreSQL

## Pourquoi

Le point d’entrée consulte `POSTGRESQL` sous `set -u`, mais cette variable ne
suit pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_POSTGRESQL` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `POSTGRESQL=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour conserver l’installation APT existante de
  PostgreSQL.
