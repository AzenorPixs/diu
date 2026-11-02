# system-log-rotate Specification

## Purpose

Déclarer le contrôle système du bloc logrotate existant.

## Requirements

### Requirement: Déclaration statique de SYSTEM_LOG_ROTATE

Le DIU SHALL déclarer `SYSTEM_LOG_ROTATE` dans
`modules/diu/variables/system/system_log_rotate.sh` avec `STATIC`, `ENABLE`,
scope `system` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_LOG_ROTATE` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_LOG_ROTATE=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_LOG_ROTATE=0` dans le processus courant

#### Scenario: Valeur préconfigurée

- **WHEN** `SYSTEM_LOG_ROTATE` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL la conserver et l’exporter sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SYSTEM_LOG_ROTATE` est définie à une valeur autre que `0` ou `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur logrotate renommé

Le bloc logrotate du point d’entrée SHALL utiliser `SYSTEM_LOG_ROTATE` à la
place de `LOG_ROTATE`. Une valeur absente ou `0` SHALL ignorer ce bloc sans
erreur de variable non définie. Une valeur `1` SHALL conserver l’écriture
existante de `/etc/logrotate.conf`.

#### Scenario: Logrotate actif

- **WHEN** `SYSTEM_LOG_ROTATE` vaut `1`
- **THEN** le DIU SHALL conserver le bloc logrotate existant

#### Scenario: Logrotate désactivé ou absent

- **WHEN** `SYSTEM_LOG_ROTATE` est absent ou vaut `0`
- **THEN** le bloc SHALL être ignoré sans erreur de variable non définie
