# docker-stack-devops Specification

## Purpose

Déclarer et initialiser le contrôle de la stack Docker DevOps dans la configuration du DIU.

## Requirements

### Requirement: Déclaration statique de DOCKER_STACK_DEVOPS

Le DIU SHALL déclarer `DOCKER_STACK_DEVOPS` dans
`modules/diu/variables/docker/docker_stack_devops.sh` avec `STATIC`, `ENABLE`,
scope `docker` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `DOCKER_STACK_DEVOPS` est absente au chargement
- **THEN** le DIU SHALL persister `export DOCKER_STACK_DEVOPS=0` dans
  `/root/diu/config/docker.env`
- **AND** SHALL exporter `DOCKER_STACK_DEVOPS=0` dans le processus courant

#### Scenario: Valeur préconfigurée

- **WHEN** `DOCKER_STACK_DEVOPS` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans la réécrire

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `DOCKER_STACK_DEVOPS` est définie à une valeur autre que `0` ou `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr
