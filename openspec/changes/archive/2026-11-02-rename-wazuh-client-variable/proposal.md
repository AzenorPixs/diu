# Renommer le contrôle de l’agent Wazuh

## Pourquoi

Le point d’entrée consulte `WAZUH_CLIENT` sous `set -u`, mais cette variable
ne suit pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_WAZUH_AGENT` en `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- Migrer exactement la dernière valeur littérale `WAZUH_CLIENT=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom et garder `WAZUH_CLIENT_VERSION` comme sélecteur de
  version indépendant.
