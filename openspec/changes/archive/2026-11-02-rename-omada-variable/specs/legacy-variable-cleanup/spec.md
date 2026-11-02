## ADDED Requirements

### Requirement: Migration de OMADA vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `OMADA` vers
`SOFTWARES_APT_OMADA` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Il SHALL préserver `OMADA_VERSION`. Une affectation nécessitant une
interprétation shell SHALL bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur OMADA littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `OMADA`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_OMADA` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** une affectation `OMADA_VERSION` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_OMADA déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_OMADA`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur OMADA ambiguë

- **WHEN** une affectation `OMADA` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
