## ADDED Requirements

### Requirement: Migration de SYNCTHING vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYNCTHING` vers
`SOFTWARES_APT_SYNCTHING` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur SYNCTHING littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYNCTHING`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_SYNCTHING` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_SYNCTHING déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_SYNCTHING`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYNCTHING ambiguë

- **WHEN** une affectation `SYNCTHING` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
