## MODIFIED Requirements

### Requirement: Suppression sûre de VERSION_VARIABLES

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL supprimer
l’affectation historique littérale `VERSION_VARIABLES` sans transférer sa
valeur. Une valeur non littérale ou nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur littérale VERSION_VARIABLES

- **WHEN** `variables.sh` contient une affectation littérale
  `VERSION_VARIABLES`
- **THEN** cette affectation SHALL être supprimée sans évaluation
- **AND** SHALL NOT transférer sa valeur vers une variable de configuration

#### Scenario: VERSION_VARIABLES ambiguë

- **WHEN** une affectation `VERSION_VARIABLES` contient une substitution, une
  expansion ou une expression shell
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation
- **AND** SHALL NOT afficher son contenu
