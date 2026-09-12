# universal-update Specification

## Purpose

Déclencher la mise à jour générale des modules du DIU.

## Requirements

### Requirement: Mise à jour universelle

`rid update` sans argument SHALL lancer la mise à jour générale de chaque
module du DIU. Il SHALL appeler `system_update` en premier, puis `diu_update`,
`environments_update`, `ia_update`, `projects_update` et `softwares_update`.

Les comportements de mise à jour, leurs prérequis et leurs validations restent
définis par les modules concernés.

#### Scenario: Invocation globale

- **WHEN** `rid update` est invoqué sans argument
- **THEN** DIU appelle les mises à jour générales des modules dans l'ordre
  défini
