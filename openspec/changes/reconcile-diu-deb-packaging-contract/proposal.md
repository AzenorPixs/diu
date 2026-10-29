# Réconciliation du contrat de packaging Debian DIU

## Why

Le plan ACSM-DIU-BOOTSTRAP-PACKAGING-20261028-R1 validé réconcilie les contrats et comportements observés.

## What Changes

- Spécifier C1 et V2 sans modifier la liste blanche ni la rotation.
- Implémenter cible paramétrable, alias et retrait du prérequis deb/.
- Partager la sélection de version avec la release et refuser les ambiguïtés.

## Capabilities

### Modified Capabilities

- deb-package
- rid-help
- forgejo-release

## Impact

Sources, tests isolés et documentation dans le périmètre B1, C1 et V2. Aucun archivage ni publication réelle.
