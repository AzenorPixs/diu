# software-apt-syslog-server Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel syslog-server.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SYSLOG_SERVER

Le DIU SHALL déclarer `SOFTWARES_APT_SYSLOG_SERVER` dans
`modules/diu/variables/softwares/software_apt_syslog_server.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_SYSLOG_SERVER` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_SYSLOG_SERVER=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur serveur syslog renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_SYSLOG_SERVER` à la place de
`SYSLOG_SERVER`. Une valeur absente SHALL être traitée comme `0`. Une valeur
`1` SHALL conserver l’installation rsyslog et les réglages des catégories
`SYSLOG_SERVER_SKIL_*`.

#### Scenario: Serveur syslog désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le serveur rsyslog SHALL ne pas être installé ni configuré sans
  erreur de variable non définie

#### Scenario: Serveur syslog activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer et configurer rsyslog comme serveur
