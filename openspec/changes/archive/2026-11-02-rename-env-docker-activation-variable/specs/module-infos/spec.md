## ADDED Requirements

### Requirement: Information de l'activation Docker

`environments_infos` SHALL afficher `ENVIRONMENT_DOCKER` sous le titre
`ENVIRONNEMENTS`.

#### Scenario: État Docker affiché

- **WHEN** les informations des environnements sont demandées
- **THEN** la valeur configurée de `ENVIRONMENT_DOCKER` est affichée
- **AND** une variable absente est affichée comme `UNSET`
