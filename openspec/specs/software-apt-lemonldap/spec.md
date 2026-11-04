# software-apt-lemonldap Specification

## Purpose
TBD - created by archiving change rename-lemonldap-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_LEMONLDAP

Le DIU SHALL déclarer `SOFTWARES_APT_LEMONLDAP` dans
`modules/diu/variables/softwares/software_apt_lemonldap.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_LEMONLDAP` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_LEMONLDAP=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur LemonLDAP-NG renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_LEMONLDAP` à la place de
`LEMONLDAP`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation APT existante des paquets LemonLDAP-NG.

#### Scenario: LemonLDAP-NG désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** l’installation APT SHALL être ignorée sans erreur de variable non
  définie

#### Scenario: LemonLDAP-NG activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer les paquets APT LemonLDAP-NG existants
