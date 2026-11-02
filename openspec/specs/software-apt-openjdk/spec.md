# software-apt-openjdk Specification

## Purpose
TBD - created by archiving change rename-openjdk-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_OPENJDK

Le DIU SHALL déclarer `SOFTWARES_APT_OPENJDK` dans
`modules/diu/variables/softwares/software_apt_openjdk.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_OPENJDK` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_OPENJDK=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur OpenJDK renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_OPENJDK` à la place de
`OPENJDK`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation et la configuration APT existantes: OpenJDK 17
sur Bullseye/Bookworm et OpenJDK 21 sur Trixie.

#### Scenario: OpenJDK désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** l’installation OpenJDK SHALL être ignorée sans erreur de variable
  non définie

#### Scenario: OpenJDK activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL sélectionner la version et les paquets selon Debian
