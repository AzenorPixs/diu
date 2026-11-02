# Renommer le contrôle d’installation Webmin

## Pourquoi

Le point d’entrée consulte `WEBMIN` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU. Le dépôt APT tiers `SYSTEM_APT_WEBMIN` est un
réglage distinct.

## Changements

- Déclarer `SOFTWARES_APT_WEBMIN` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `WEBMIN=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour l’installation ou la suppression du paquet
  Webmin, sans renommer `SYSTEM_APT_WEBMIN`.
