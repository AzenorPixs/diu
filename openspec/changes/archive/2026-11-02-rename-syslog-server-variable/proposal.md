# Renommer le contrôle du serveur syslog

## Pourquoi

Le point d’entrée consulte `SYSLOG_SERVER` sous `set -u`, mais cette variable
ne suit pas le mécanisme déclaratif DIU. Elle pilote rsyslog et la réception
des catégories de journaux configurées par des options séparées.

## Changements

- Déclarer `SOFTWARES_APT_SYSLOG_SERVER` en `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- Migrer exactement la dernière valeur littérale `SYSLOG_SERVER=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour installer et activer le serveur rsyslog; garder
  les variables `SYSLOG_SERVER_SKIL_*` distinctes.
