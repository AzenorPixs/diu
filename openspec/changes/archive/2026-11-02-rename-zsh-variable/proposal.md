# Renommer le contrôle Zsh

## Pourquoi

Le point d’entrée consulte `ZSH` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_ZSH` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `ZSH=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour conserver l’installation et la configuration
  existantes de Zsh et Fish.
