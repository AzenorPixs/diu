# Déclarer la version des variables DIU

## Pourquoi

Le résumé final lit `VERSION_VARIABLES` sous `set -u`, mais cette ancienne
variable n’est pas chargée dans le conteneur CISMP.

## Changements

- Déclarer `DIU_VARIABLES_VERSION` en `DYNAMIC`, `ENABLE`, scope `diu`.
- Générer sa valeur depuis la version du paquet Debian `diu` installé, avec
  `dpkg-query` et un échec explicite si la version est indisponible.
- Afficher cette variable dans le résumé final.
- Retirer l’affectation historique `VERSION_VARIABLES` sans transférer sa
  valeur littérale; préserver `VERSION`.
