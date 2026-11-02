## ADDED Requirements

### Requirement: Suppression sûre de VERSION_ALIAS

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL supprimer
l’affectation historique simple `VERSION_ALIAS` sans la transférer. Une valeur
non littérale ou nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur littérale VERSION_ALIAS

- **WHEN** `variables.sh` contient une affectation littérale `VERSION_ALIAS`
- **THEN** cette affectation SHALL être supprimée sans évaluation
- **AND** les variables `VERSION` et `VERSION_VARIABLES` SHALL rester intactes

#### Scenario: VERSION_ALIAS ambiguë

- **WHEN** une affectation `VERSION_ALIAS` contient une substitution, une
  expansion ou une expression shell
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation
- **AND** SHALL NOT afficher son contenu
