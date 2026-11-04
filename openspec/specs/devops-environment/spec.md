# devops-environment Specification

## Purpose
TBD - created by archiving change rename-env-devops-activation-variable. Update Purpose after archive.

## Requirements

### Requirement: Déclaration de l'activation DevOps

Le DIU SHALL déclarer `ENVIRONMENTS_DEVOPS` dans
`modules/diu/variables/environnements/env_devops.sh` avec `STATIC`, `ENABLE`,
scope `environnements` et défaut `0`. Le chargeur SHALL découvrir cette
déclaration.

#### Scenario: Valeur absente

- **WHEN** `ENVIRONMENTS_DEVOPS` est absente
- **THEN** le DIU persiste et exporte `ENVIRONMENTS_DEVOPS=0` dans le processus
  courant
- **AND** persiste `export ENVIRONMENTS_DEVOPS=0` dans
  `/root/diu/config/environnements.env`

#### Scenario: Valeur préconfigurée valide

- **WHEN** `ENVIRONMENTS_DEVOPS` vaut `0` ou `1`
- **THEN** le DIU préserve et exporte sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `ENVIRONMENTS_DEVOPS` ne vaut ni `0` ni `1`
- **THEN** sa déclaration échoue avec un diagnostic stderr

#### Scenario: Activation de l'environnement DevOps

- **WHEN** `ENVIRONMENTS_DEVOPS` vaut `1`
- **THEN** le bloc d'installation et de préparation de l'environnement DevOps
  conserve son comportement existant
- **WHEN** `ENVIRONMENTS_DEVOPS` vaut `0` ou est absente
- **THEN** ce bloc est ignoré sans erreur de variable non définie
