# software-apt-fastfetch Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel fastfetch.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_FASTFETCH

Le DIU SHALL déclarer `SOFTWARES_APT_FASTFETCH` dans
`modules/diu/variables/softwares/software_apt_fastfetch.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_FASTFETCH` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_FASTFETCH=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Fastfetch renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_FASTFETCH` à la place de
`FASTFETCH`. Une valeur absente SHALL être traitée comme `0`. Pour une valeur
`1`, le DIU SHALL conserver les installations APT existantes: neofetch sur
Debian bullseye/bookworm et fastfetch sur Debian trixie.

#### Scenario: Fastfetch désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le bloc d’installation SHALL être ignoré sans erreur de variable
  non définie

#### Scenario: Fastfetch activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL sélectionner le paquet selon la version Debian détectée
