# Renommer le contrôle /etc/rc.local

## Pourquoi

Le point d’entrée consulte `RCLOCAL` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SYSTEM_RC_LOCAL` en `STATIC`, `ENABLE`, scope `system`, défaut `0`.
- Migrer exactement la dernière valeur littérale `RCLOCAL=0|1` vers
  `system.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour piloter la génération conditionnelle de
  `/etc/rc.local`.
