# Renommer le contrôle logiciel LemonLDAP-NG

## Pourquoi

Le point d’entrée consulte `LEMONLDAP` sous `set -u`, mais cette variable ne
correspond pas au mécanisme déclaratif DIU. Elle sert également à initialiser
le réglage indépendant du dépôt APT `SYSTEM_APT_LEMONLDAP`.

## Changements

- Déclarer `SOFTWARES_APT_LEMONLDAP` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `LEMONLDAP=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser la nouvelle variable pour l’installation APT des paquets
  LemonLDAP-NG et comme repli initial pour `SYSTEM_APT_LEMONLDAP`.
- Conserver `SYSTEM_APT_LEMONLDAP` comme contrôle système distinct du dépôt.
