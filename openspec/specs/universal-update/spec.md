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

### Requirement: Intégration de la mise à jour générale des projets

L'appel projects_update de rid update SHALL exécuter la même mise à jour
générale des modèles que rid projects update, une seule fois à sa position
existante dans l'ordre des modules. Un échec projects SHALL être conservé
dans le résultat global même si softwares_update réussit. Après cet échec,
softwares_update SHALL être appelé à sa position prévue. Lorsque projects
réussit, le retour final de softwares_update SHALL être conservé. Les
parcours rid update diu et les moteurs logiciels explicites SHALL rester
inchangés. Cette évolution SHALL NOT ajouter d'autre opération projects.

#### Scenario: Ordre conservé

- **WHEN** rid update est appelé sans argument et tous les modules réussissent
- **THEN** system, diu, environments, ia, projects puis softwares sont appelés dans l'ordre
- **AND THEN** le traitement des modèles des projets est appelé une seule fois

#### Scenario: Échec projects et réussite softwares

- **WHEN** projects_update échoue et softwares_update réussit
- **THEN** softwares_update est exécuté puis rid update rend le code non nul de projects

#### Scenario: Échec softwares après réussite projects

- **WHEN** projects_update réussit et softwares_update échoue
- **THEN** rid update conserve le code non nul de softwares
