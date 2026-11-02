# software-apt-zsh Specification

## Purpose
TBD - created by archiving change rename-zsh-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_ZSH

Le DIU SHALL déclarer `SOFTWARES_APT_ZSH` dans
`modules/diu/variables/softwares/software_apt_zsh.sh` avec `STATIC`, `ENABLE`,
scope `softwares` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_ZSH` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_ZSH=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Zsh renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_ZSH` à la place de `ZSH`. Une
valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL conserver
l’installation de Zsh, Fish et des outils associés, ainsi que la configuration
des shells.

#### Scenario: Zsh désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le bloc d’installation et de configuration SHALL être ignoré sans
  erreur de variable non définie

#### Scenario: Zsh activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL conserver les installations APT et la configuration
  Zsh/Fish existantes
