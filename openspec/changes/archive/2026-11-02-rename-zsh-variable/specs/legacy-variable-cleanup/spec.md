## ADDED Requirements

### Requirement: Migration de ZSH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `ZSH` vers `SOFTWARES_APT_ZSH`
dans `softwares.env` si le nouveau nom n’y est pas déjà déclaré. Une
affectation nécessitant une interprétation shell SHALL bloquer le nettoyage
sans modifier les fichiers.

#### Scenario: Ancienne valeur ZSH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `ZSH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_ZSH` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_ZSH déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_ZSH`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur ZSH ambiguë

- **WHEN** une affectation `ZSH` nécessite une interprétation shell ou ne vaut
  pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
