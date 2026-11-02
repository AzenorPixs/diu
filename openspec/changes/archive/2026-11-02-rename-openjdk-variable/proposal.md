# Renommer le contrôle OpenJDK

## Pourquoi

Le point d’entrée consulte `OPENJDK` sous `set -u`, mais cette variable ne
correspond pas au mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_OPENJDK` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `OPENJDK=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser le nouveau nom et conserver les paquets Java 17/21 sélectionnés
  selon la version Debian.
