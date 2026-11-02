# Déclarer le contrôle logiciel de bureau

## Pourquoi

Le point d'entrée consulte `DESKTOP` sous `set -u` pour préparer les journaux
du bureau et installer ses logiciels APT. La variable n'est pas déclarée par
le système de configuration courant et provoque un arrêt prématuré.

## Changements

- Déclarer `SOFTWARES_APT_DESKTOP` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer l'ancienne valeur littérale `DESKTOP=0|1` exactement vers
  `softwares.env`, avec priorité à la nouvelle valeur.
- Remplacer les deux consommateurs historiques par le nouveau contrôle.

## Hors périmètre

- Renommer ou migrer `DESKTOP_GUI`.
- Modifier les recettes ou paquets de bureau.
