# software-apt-syncthing Specification

## Purpose
TBD - created by archiving change rename-syncthing-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SYNCTHING

Le DIU SHALL déclarer `SOFTWARES_APT_SYNCTHING` dans
`modules/diu/variables/softwares/software_apt_syncthing.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_SYNCTHING` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_SYNCTHING=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs Syncthing renommés

Les consommateurs SHALL utiliser `SOFTWARES_APT_SYNCTHING` à la place de
`SYNCTHING`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation APT de Syncthing et la préparation de `.stignore`.

#### Scenario: Syncthing désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** aucun paquet Syncthing ni fichier `.stignore` spécifique ne SHALL
  être créé sans erreur de variable non définie

#### Scenario: Syncthing activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer Syncthing et générer `.stignore` comme avant
