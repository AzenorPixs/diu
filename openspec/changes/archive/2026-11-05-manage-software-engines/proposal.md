# Gestion des moteurs logiciels

## Why
Activer ou désactiver séparément les moteurs logiciels et garantir leurs dépendances sans supprimer de paquets partagés.

## What Changes
- Commandes `diu system engine install|remove apt|github|flatpak` et aides associées.
- Variables `SYSTEM_APT_ENGINE`, `SYSTEM_GITHUB_ENGINE` et `SYSTEM_FLATPAK_ENGINE`, reprise de `SYSTEM_FLATPAK`.
- Les moteurs actifs contrôlent leurs dépendances ; la désactivation conserve les paquets et bloque l'utilisation du moteur logiciel.
- L'inventaire logiciel affiche l'état du moteur en tenant compte de sa configuration et de ses dépendances.

## Capabilities

### New Capabilities
- `software-engines`: configuration, commandes et dépendances des moteurs logiciels.

### Modified Capabilities
- `system-flatpak`: remplacer le retrait du paquet par la désactivation du moteur et migrer sa variable.
- `system-debian-apt`, `software-flatpak`, `module-infos` : actualiser les références à la variable.
- `software-inventory` : prendre en compte les états et dépendances des moteurs.

## Impact
Routage système, configuration, moteurs logiciels, affichage, documentation et tests. Aucun déploiement ni CI/CD. Code non attribué ; attribution ultérieure par ACL.
