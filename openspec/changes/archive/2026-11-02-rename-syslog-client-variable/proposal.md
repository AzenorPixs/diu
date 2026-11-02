# Renommer le contrôle client syslog

## Pourquoi

Le point d’entrée consulte `SYSLOG_CLIENT` sous `set -u`, mais cette variable
ne suit pas le mécanisme déclaratif DIU. Elle pilote rsyslog et le transfert
vers un serveur dont l’adresse est configurée séparément.

## Changements

- Déclarer `SOFTWARES_APT_SYSLOG_CLIENT` en `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- Migrer exactement la dernière valeur littérale `SYSLOG_CLIENT=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour l’installation et la configuration rsyslog;
  conserver `SYSLOG_CLIENT_SERVER` comme adresse du serveur distant.
