## ADDED Requirements

### Requirement: Migration de RCLOCAL vers le scope système

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `RCLOCAL` vers `SYSTEM_RC_LOCAL`
dans `system.env` si le nouveau nom n’y est pas déjà déclaré. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur RCLOCAL littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `RCLOCAL`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SYSTEM_RC_LOCAL` dans `system.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SYSTEM_RC_LOCAL déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_RC_LOCAL`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur RCLOCAL ambiguë

- **WHEN** une affectation `RCLOCAL` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu
