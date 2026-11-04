# Renommer le contrôle d’installation jsvc

## Pourquoi

Le point d’entrée consulte `JSVC` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_JSVC` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `JSVC=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser le nouveau nom pour piloter l’installation APT existante de `jsvc`.
