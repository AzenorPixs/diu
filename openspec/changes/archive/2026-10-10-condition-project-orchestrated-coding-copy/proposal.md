# PRJ13 — Copie conditionnelle du protocole de codage piloté

## Why

Le document ancien protocole local ne concerne que les projets pilotés.
La création le copie actuellement sans condition et la synchronisation
ne le copie jamais, indépendamment du mode enregistré pour le projet.

## What Changes

- Copier et personnaliser le document racine du modèle seulement lorsque
  le mode du projet destination vaut littéralement Yes.
- Préserver un document destination existant pour No, une variable absente
  ou vide ; ne pas exiger la source dans ces cas.
- Refuser un mode invalide et, pour Yes, une source absente, avant la copie.
- Réutiliser le lecteur isolé existant, sans modifier les questionnaires.
- Réconcilier la même exception dans les deltas actifs
  add-projects-sync-broker et refactor-projects-template-copy. Ils restent
  actifs et ne sont ni implémentés davantage ni archivés par cette session.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-sync`: exception conditionnelle à la sélection des copies.
- `implement-projects-update`: utilisation du mode destination lors de la
  copie du modèle à la création et à la synchronisation.

## Impact

modules/projects/projects.sh et des tests synthétiques ciblés sont concernés,
ainsi que TECHNICAL.md, README.md et CHANGELOG.md. La copie générale du modèle
est celle effectuée par create_project ; les commandes template openspec,
devops et all ne copient pas ce document et restent inchangées.
Il n'y a ni migration, suppression d'un document existant, dépendance,
activation de service, inspection Git ni synchronisation d'un projet réel.
La copie en mode Yes écrase le document géré sans sauvegarde automatique,
comme les autres ressources synchronisées.

Le développeur a validé explicitement le périmètre SCM le 2026-10-10,
y compris spécification, implémentation, tests, documentation, réconciliation
des chevauchements et archivage du seul présent change avec son rapport.
