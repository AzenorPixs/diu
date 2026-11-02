# Renommer le contrôle qemu-guest-agent

## Pourquoi

Le point d’entrée consulte `QEMU_GUEST_AGENT` sous `set -u`, mais cette
variable ne suit pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_QEMU_GUEST_AGENT` en `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- Migrer exactement la dernière valeur littérale `QEMU_GUEST_AGENT=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour piloter l’installation APT existante.
