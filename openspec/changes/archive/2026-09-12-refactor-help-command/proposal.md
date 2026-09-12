## Why

L'aide de `rid` est aujourd'hui répartie entre des sorties précoces, une aide
contextuelle partielle et `display_usage()`. Les erreurs de routage retombent
sur cette dernière, qui affiche une liste globale obsolète au lieu d'indiquer
l'aide adaptée au chemin déjà reconnu.

## What Changes

- Remplacer les sorties d'aide dispersées par un mécanisme d'aide contextuelle
  unique, disponible sans charger la configuration de production.
- Afficher les commandes immédiatement disponibles avec une description
  concise et alignée pour chaque contexte connu.
- Remplacer `display_usage()` par le mécanisme contextuel et faire proposer
  l'aide du dernier contexte reconnu après une commande inconnue.
- Conserver les alias existants `help` et `?` pour l'aide.

## Capabilities

### New Capabilities

- `rid-help`: Aide hiérarchique et traitement sûr des commandes `rid`
  inconnues.

### Modified Capabilities

- Aucune.

## Impact

- `root-install-debian.sh` : centralisation de l'aide et des erreurs de
  routage.
- `tests/test_rid_help.py` : couverture d'exécution sans configuration de
  production des aides et des commandes inconnues.
- `README.md` : aucune mise à jour nécessaire, car il ne documente pas encore
  le catalogue des commandes `rid`.
- `CHANGELOG.md` : aucune mise à jour nécessaire, car son contenu concerne
  actuellement un autre projet et ne définit pas de convention DIU fiable.
