# SYS13 — Gestion du fuseau horaire système

## Why
Migrer le fuseau horaire vers les déclarations unitaires du scope system.

## What Changes
- Déclarer SYSTEM_TIME_ZONE statique, détectée initialement par timedatectl avec repli Europe/Paris.
- Migrer les consommateurs et nettoyer TIME_ZONE sans transfert ni sauvegarde automatique.
- Afficher la variable après SYSTEM_DEBIAN_RELEASE.

## Capabilities
### New Capabilities
- `system-time-zone`: initialisation et persistance du fuseau horaire.
### Modified Capabilities
- `legacy-variable-cleanup`: nettoyage de TIME_ZONE.
- `module-infos`: affichage du fuseau horaire.

## Impact
Déclaration, consommateur historique, nettoyage, informations, tests et TECHNICAL.md. Aucun changement du chargeur ni installation système pendant les validations.
