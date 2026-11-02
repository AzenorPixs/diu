## ADDED Requirements

### Requirement: Migration de SYSLOG_CLIENT vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYSLOG_CLIENT` vers
`SOFTWARES_APT_SYSLOG_CLIENT` dans `softwares.env` si le nouveau nom n’y est
pas déjà déclaré. Il SHALL préserver `SYSLOG_CLIENT_SERVER`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur SYSLOG_CLIENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYSLOG_CLIENT`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_SYSLOG_CLIENT` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `SYSLOG_CLIENT_SERVER` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_SYSLOG_CLIENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_SYSLOG_CLIENT`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYSLOG_CLIENT ambiguë

- **WHEN** une affectation `SYSLOG_CLIENT` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
