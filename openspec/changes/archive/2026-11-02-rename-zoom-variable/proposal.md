# Renommer le contrôle Zoom

## Pourquoi

Le point d’entrée consulte `ZOOM` sous `set -u`, mais cette variable ne suit
pas le mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_ZOOM` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `ZOOM=0|1` vers
  `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Utiliser le nouveau nom pour conserver le téléchargement, l’installation et
  la mise à jour existants du paquet Debian Zoom.
