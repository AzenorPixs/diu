# Renommer le contrôle logiciel MongoDB

## Pourquoi

Le point d’entrée consulte `MONGODB` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU. Elle pilote les paquets MongoDB et initialise
aussi le dépôt tiers `SYSTEM_APT_MONGODB` avec la version indiquée séparément.

## Changements

- Déclarer `SOFTWARES_APT_MONGODB` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `MONGODB=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser le nouveau nom pour installer les paquets et comme repli initial
  du dépôt `SYSTEM_APT_MONGODB`; garder `MONGODB_VERSION` distinct.
