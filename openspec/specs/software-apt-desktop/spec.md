# software-apt-desktop Specification

## Purpose
TBD - created by archiving change add-software-apt-desktop-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration du contrôle logiciel DESKTOP

Le DIU SHALL déclarer `SOFTWARES_APT_DESKTOP` dans
`modules/diu/variables/softwares/software_apt_desktop.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur SHALL découvrir cette
déclaration. Le point d'entrée SHALL utiliser cette variable pour ses deux
branches de configuration des logiciels et journaux du bureau.

#### Scenario: Valeur absente

- **WHEN** `SOFTWARES_APT_DESKTOP` est absente
- **THEN** le DIU persiste `export SOFTWARES_APT_DESKTOP=0` dans
  `/root/diu/config/softwares.env`
- **AND** exporte la valeur `0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SOFTWARES_APT_DESKTOP` vaut `0` ou `1`
- **THEN** le DIU conserve et exporte la valeur sans la réécrire

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SOFTWARES_APT_DESKTOP` a une autre valeur
- **THEN** sa déclaration échoue avec un diagnostic stderr

#### Scenario: Migration littérale de DESKTOP

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  `DESKTOP=0|1`
- **THEN** la dernière valeur est transférée exactement vers
  `SOFTWARES_APT_DESKTOP` si aucun nouveau nom n'est déjà déclaré
- **AND** les anciennes affectations sont supprimées après migration réussie

#### Scenario: Valeur DESKTOP ambiguë

- **WHEN** une affectation `DESKTOP` ne vaut pas littéralement `0` ou `1`
- **THEN** `config_cleanup` échoue sans évaluer sa valeur ni modifier les
  fichiers de configuration

#### Scenario: Profil de bureau désactivé ou activé

- **WHEN** `SOFTWARES_APT_DESKTOP` vaut `0` ou est absente
- **THEN** les deux branches réservées au profil de bureau sont ignorées
- **WHEN** `SOFTWARES_APT_DESKTOP` vaut `1`
- **THEN** les traitements existants de configuration et d'installation du
  profil de bureau restent actifs
