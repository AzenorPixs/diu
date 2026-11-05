# environment-ia Specification

## Purpose
Définir la déclaration et l’activation de l’environnement IA.

## Requirements

### Requirement: Déclaration de l'activation IA

Le DIU SHALL déclarer `ENVIRONMENT_IA` dans
`modules/diu/variables/environnements/environment_ia.sh` avec `STATIC`,
`ENABLE`, scope `environnements` et défaut `0`. Le chargeur SHALL découvrir
cette déclaration.

#### Scenario: Valeur absente

- **WHEN** `ENVIRONMENT_IA` est absente
- **THEN** le DIU persiste `export ENVIRONMENT_IA=0` dans
  `/root/diu/config/environnements.env`
- **AND** exporte la valeur `0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `ENVIRONMENT_IA` vaut `0` ou `1`
- **THEN** le DIU préserve et exporte sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `ENVIRONMENT_IA` ne vaut ni `0` ni `1`
- **THEN** sa déclaration échoue avec un diagnostic stderr

#### Scenario: Provisionnement IA activé ou désactivé

- **WHEN** `ENVIRONMENT_IA` vaut `1`
- **THEN** les traitements existants de provisionnement IA s'exécutent
- **WHEN** `ENVIRONMENT_IA` vaut `0` ou est absente
- **THEN** ces traitements sont ignorés sans erreur de variable non définie
