# software-apt-postfix Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel postfix.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_POSTFIX

Le DIU SHALL déclarer `SOFTWARES_APT_POSTFIX` dans
`modules/diu/variables/softwares/software_apt_postfix.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_POSTFIX` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_POSTFIX=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Postfix renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_POSTFIX` à la place de
`POSTFIX`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation APT de Postfix et la configuration existante
avec `POSTFIX_RELAY_HOST`.

#### Scenario: Postfix désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** l’installation SHALL être ignorée sans erreur de variable non
  définie

#### Scenario: Postfix activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer le paquet APT `postfix`
- **AND** configurer `relayhost` à partir de `POSTFIX_RELAY_HOST`
