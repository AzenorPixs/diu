# Proposal

## Why

Le document `DEVOPS.md` indique l’image Docker de test Debian mais ne précise pas que le TPM de l’hôte a été vérifié depuis ce conteneur. Le test réalisé a confirmé l’accès via `/dev/tpmrm0` transmis au conteneur ; cette capacité doit apparaître dans la rubrique Docker générée.

## What Changes

- Ajouter la puce exacte `Accès TPM OK` après `debian:stable-slim` et avant l’autorisation commune dans la rubrique Docker.
- Conserver cette mention documentaire fixe sans nouvelle sonde TPM, modification d’infrastructure ou changement du lancement des conteneurs.
- Mettre à jour les tests, la documentation et le format de la rubrique Docker de cinq à six puces.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops` : ajouter la mention d’accès TPM à la rubrique Docker activée.

## Impact

Le rendu commun de `modules/projects/template.sh`, ses tests, la spécification `projects-template-devops`, `README.md`, `TECHNICAL.md` et `CHANGELOG.md` sont concernés. Les documents générés existants adopteront la mention à leur prochaine génération. Les autres rubriques et les sondes restent inchangées.

Périmètre autonome validé : change OpenSpec, implémentation, tests, documentation, mises à jour conditionnelles de la cartographie et du registre, archivage, rapports requis, puis clôture Git conditionnelle SCM.
