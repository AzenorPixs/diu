## ADDED Requirements

### Requirement: Migration de WAZUH_SERVER vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `WAZUH_SERVER` vers
`SOFTWARES_APT_WAZUH_SERVER` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Il SHALL préserver `WAZUH_SERVER_UPGRADE`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur WAZUH_SERVER littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `WAZUH_SERVER`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_WAZUH_SERVER` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `WAZUH_SERVER_UPGRADE` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_WAZUH_SERVER déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_WAZUH_SERVER`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur WAZUH_SERVER ambiguë

- **WHEN** une affectation `WAZUH_SERVER` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
