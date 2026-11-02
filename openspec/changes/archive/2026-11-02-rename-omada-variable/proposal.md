# Renommer le contrôle logiciel Omada

## Pourquoi

Le point d’entrée consulte `OMADA` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU. Elle pilote l’installation Omada et les règles
firewall associées; sa version est fournie séparément.

## Changements

- Déclarer `SOFTWARES_APT_OMADA` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `OMADA=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser le nouveau nom pour l’installation et le firewall; préserver
  `OMADA_VERSION` et les autres réglages Omada distincts.
