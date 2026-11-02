# software-apt-desktop Specification

## Purpose
TBD - created by archiving change add-software-apt-desktop-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration du contrôle logiciel DESKTOP

Le DIU SHALL déclarer `DESKTOP` dans
`modules/diu/variables/desktop/desktop.sh` avec `STATIC`, `ENABLE`, scope
`desktop` et défaut `0`. Le chargeur SHALL découvrir cette déclaration dans
`desktop.env`. Le point d'entrée SHALL utiliser cette variable pour ses deux
branches de configuration des logiciels et journaux du bureau.

#### Scenario: Valeur absente

- **WHEN** `DESKTOP` est absente
- **THEN** le DIU persiste `export DESKTOP=0` dans
  `/root/diu/config/desktop.env`
- **AND** exporte la valeur `0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `DESKTOP` vaut `0` ou `1`
- **THEN** le DIU conserve et exporte la valeur sans la réécrire

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `DESKTOP` a une autre valeur
- **THEN** sa déclaration échoue avec un diagnostic stderr

#### Scenario: Migration littérale de DESKTOP

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  `DESKTOP=0|1`
- **THEN** la dernière valeur est transférée exactement vers `desktop.env` si
  aucun `DESKTOP` n'y est déjà déclaré
- **AND** les anciennes affectations sont supprimées après migration réussie

#### Scenario: Valeur DESKTOP ambiguë

- **WHEN** une affectation historique `DESKTOP` ne vaut pas littéralement
  `0` ou `1`
- **THEN** `config_cleanup` échoue sans évaluer sa valeur ni modifier les
  fichiers de configuration

#### Scenario: Profil de bureau désactivé ou activé

- **WHEN** `DESKTOP` vaut `0` ou est absente
- **THEN** les deux branches réservées au profil de bureau sont ignorées
- **WHEN** `DESKTOP` vaut `1`
- **THEN** les traitements existants de configuration et d'installation du
  profil de bureau restent actifs
