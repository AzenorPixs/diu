## ADDED Requirements

### Requirement: Information de l'activation DevOps

`environments_infos` SHALL afficher `ENVIRONMENTS_DEVOPS` sous le titre
`ENVIRONNEMENTS`.

#### Scenario: État DevOps affiché

- **WHEN** les informations des environnements sont demandées
- **THEN** la valeur configurée de `ENVIRONMENTS_DEVOPS` est affichée
- **AND** une variable absente est affichée comme `UNSET`
