# Renommer le contrôle Fastfetch

## Pourquoi

Le point d’entrée consulte `FASTFETCH` sous `set -u`, mais la variable ne suit
pas le nouveau mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_FASTFETCH` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `FASTFETCH=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà définie.
- Utiliser le nouveau nom dans le point d’entrée et préserver l’installation
  APT selon la version Debian.
