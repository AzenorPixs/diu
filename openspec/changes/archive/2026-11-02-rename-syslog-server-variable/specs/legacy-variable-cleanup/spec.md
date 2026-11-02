## ADDED Requirements

### Requirement: Migration de SYSLOG_SERVER vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYSLOG_SERVER` vers
`SOFTWARES_APT_SYSLOG_SERVER` dans `softwares.env` si le nouveau nom n’y est
pas déjà déclaré. Il SHALL préserver les variables `SYSLOG_SERVER_SKIL_*`. Une
affectation nécessitant une interprétation shell SHALL bloquer le nettoyage
sans modifier les fichiers.

#### Scenario: Ancienne valeur SYSLOG_SERVER littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYSLOG_SERVER`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_SYSLOG_SERVER` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** les affectations `SYSLOG_SERVER_SKIL_*` SHALL rester inchangées

#### Scenario: SOFTWARES_APT_SYSLOG_SERVER déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_SYSLOG_SERVER`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYSLOG_SERVER ambiguë

- **WHEN** une affectation `SYSLOG_SERVER` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
