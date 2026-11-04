## ADDED Requirements

### Requirement: Information de l'activation IA

`environments_infos` SHALL afficher `ENVIRONMENT_IA` sous le titre
`ENVIRONNEMENTS`.

#### Scenario: État IA affiché

- **WHEN** les informations des environnements sont demandées
- **THEN** la valeur configurée de `ENVIRONMENT_IA` est affichée
- **AND** une variable absente est affichée comme `UNSET`
