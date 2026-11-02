# Déclarer la version du paquet DIU

## Pourquoi

Le résumé final du point d’entrée consulte `VERSION_ALIAS` sous `set -u`. Cette
valeur n’est pas déclarée dans DIU et peut devenir obsolète.

## Changements

- Déclarer `DIU_VERSION` en `DYNAMIC`, `ENABLE`, scope `diu`.
- Générer sa valeur à partir de la version du paquet Debian `diu` installé,
  via `dpkg-query`.
- Afficher cette version dans le résumé final.
- Supprimer l’ancienne affectation `VERSION_ALIAS` sans la transférer.
