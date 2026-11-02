# Renommer le contrôle Wazuh Server

## Pourquoi

Le point d’entrée consulte `WAZUH_SERVER` sous `set -u`, mais cette variable ne
suit pas le mécanisme déclaratif DIU. Elle contribue aussi à l’initialisation
du dépôt APT système selon `WAZUH_SERVER_UPGRADE`.

## Changements

- Déclarer `SOFTWARES_APT_WAZUH_SERVER` en `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- Migrer exactement la dernière valeur littérale `WAZUH_SERVER=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour le serveur et comme repli du dépôt APT Wazuh,
  en conservant `WAZUH_SERVER_UPGRADE`.
