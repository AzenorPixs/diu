## ADDED Requirements

### Requirement: Migration de FASTFETCH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `FASTFETCH` vers
`SOFTWARES_APT_FASTFETCH` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur FASTFETCH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `FASTFETCH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_FASTFETCH` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Valeur SOFTWARES_APT_FASTFETCH déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_FASTFETCH`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur FASTFETCH ambiguë

- **WHEN** une affectation `FASTFETCH` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
