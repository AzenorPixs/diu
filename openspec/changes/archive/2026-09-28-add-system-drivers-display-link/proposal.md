## Why

DISPLAY_LINK est une variable historique manuelle. Son remplacement doit suivre
le mécanisme déclaratif du scope system et distinguer installation complète,
absence et impossibilité de découverte.

## What Changes

- Ajouter SYSTEM_DRIVERS_DISPLAY_LINK, STATIC, ENABLE, scope system, valeurs 0/1/UNSET.
- Détecter initialement displaylink-driver et evdi-dkms, puis persister la valeur.
- Migrer les consommateurs et nettoyer DISPLAY_LINK avant le chargement historique.
- Préserver la condition d'installation à 1 et le bloc d'installation existant.

## Capabilities

### New Capabilities
- `system-drivers-display-link`: état initial persisté des paquets DisplayLink.

### Modified Capabilities
- `legacy-variable-cleanup`: retrait de DISPLAY_LINK et migration de ses consommateurs.
- `system-prerequisites`: condition DisplayLink sous son nouveau nom.

## Impact

Nouvelle déclaration, point d'entrée, nettoyage, tests ciblés et TECHNICAL.md.
Aucun ajout de dépôt, changement de pilote ni écriture de configuration réelle
pendant le job. Aucune modification des autres changes actifs.
