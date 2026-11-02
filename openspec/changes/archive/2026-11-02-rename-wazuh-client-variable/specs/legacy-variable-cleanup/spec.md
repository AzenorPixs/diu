## ADDED Requirements

### Requirement: Migration de WAZUH_CLIENT vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `WAZUH_CLIENT` vers
`SOFTWARES_APT_WAZUH_AGENT` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Il SHALL préserver `WAZUH_CLIENT_VERSION`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur WAZUH_CLIENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `WAZUH_CLIENT`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_WAZUH_AGENT` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `WAZUH_CLIENT_VERSION` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_WAZUH_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_WAZUH_AGENT`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur WAZUH_CLIENT ambiguë

- **WHEN** une affectation `WAZUH_CLIENT` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
