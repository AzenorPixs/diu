# software-apt-syslog-client Specification

## Purpose
TBD - created by archiving change rename-syslog-client-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SYSLOG_CLIENT

Le DIU SHALL déclarer `SOFTWARES_APT_SYSLOG_CLIENT` dans
`modules/diu/variables/softwares/software_apt_syslog_client.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_SYSLOG_CLIENT` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_SYSLOG_CLIENT=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur syslog renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_SYSLOG_CLIENT` à la place de
`SYSLOG_CLIENT`. Une valeur absente SHALL être traitée comme `0`. Une valeur
`1` SHALL conserver l’installation rsyslog et son transfert vers
`SYSLOG_CLIENT_SERVER`.

#### Scenario: Client syslog désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** rsyslog SHALL ne pas être installé ni configuré comme client sans
  erreur de variable non définie

#### Scenario: Client syslog activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer rsyslog et transférer les journaux vers
  `SYSLOG_CLIENT_SERVER`
