# docker-environment Specification

## Purpose
Définir la déclaration et l’activation de l’environnement Docker.

## Requirements

### Requirement: Déclaration de l'activation Docker

Le DIU SHALL déclarer `ENVIRONMENT_DOCKER` dans
`modules/diu/variables/environnements/environment_docker.sh` avec `STATIC`,
`ENABLE`, scope `environnements` et défaut `0`. Le chargeur SHALL découvrir
cette déclaration.

#### Scenario: Valeur absente

- **WHEN** `ENVIRONMENT_DOCKER` est absente
- **THEN** le DIU persiste `export ENVIRONMENT_DOCKER=0` dans
  `/root/diu/config/environnements.env`
- **AND** exporte la valeur `0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `ENVIRONMENT_DOCKER` vaut `0` ou `1`
- **THEN** le DIU préserve et exporte sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `ENVIRONMENT_DOCKER` ne vaut ni `0` ni `1`
- **THEN** sa déclaration échoue avec un diagnostic stderr

#### Scenario: Provisionnement Docker activé ou désactivé

- **WHEN** `ENVIRONMENT_DOCKER` vaut `1`
- **THEN** le bloc existant de provisionnement Docker s'exécute
- **WHEN** `ENVIRONMENT_DOCKER` vaut `0` ou est absente
- **THEN** ce bloc est ignoré sans erreur de variable non définie
