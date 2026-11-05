# Affichage des logiciels par moteur

## Why
Présenter les logiciels déclarés et la disponibilité des moteurs dans les informations DIU.

## What Changes
Ajouter `diu infos softwares`, réutilisé par `diu infos` et `diu softwares infos`, avec colonnes colorées et état des variables sans révéler leurs noms. Mettre à jour les aides et la documentation.

## Capabilities

### New Capabilities
- `software-inventory`: inventaire des logiciels par moteur.

### Modified Capabilities
- `module-infos` : remplacer les variables CrowdSec affichées par les noms et états.
- `diu-help` : exposer la nouvelle syntaxe d’inventaire.

## Impact
Routage, aide, informations logicielles, tests et documentation. Aucun déploiement. Code non attribué ; attribution ultérieure par ACL.
