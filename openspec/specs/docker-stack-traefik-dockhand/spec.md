# docker-stack-traefik-dockhand Specification

## Purpose

Déclarer le contrôle Docker de la stack Traefik/Dockhand.

## Requirements

### Requirement: Déclaration statique de DOCKER_STACK_TRAEFIK_DOCKHAND

Le DIU SHALL déclarer `DOCKER_STACK_TRAEFIK_DOCKHAND` dans
`modules/diu/variables/docker/docker_stack_traefik_dockhand.sh` avec
`STATIC`, `ENABLE`, scope `docker` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND` est absente au chargement
- **THEN** le DIU SHALL persister
  `export DOCKER_STACK_TRAEFIK_DOCKHAND=0` dans `/root/diu/config/docker.env`
- **AND** SHALL exporter `DOCKER_STACK_TRAEFIK_DOCKHAND=0` dans le processus
  courant

#### Scenario: Valeur préconfigurée

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans la réécrire

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND` est définie à une valeur autre que
  `0` ou `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs de la stack préservés

Les consommateurs de la stack Traefik/Dockhand SHALL continuer d’utiliser
`DOCKER_STACK_TRAEFIK_DOCKHAND`. Une valeur `1` active les traitements
existants; une valeur absente ou `0` les ignore.

#### Scenario: Stack activée

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND` vaut `1`
- **THEN** les traitements existants de la stack restent activés

#### Scenario: Stack désactivée ou absente

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND` est absente ou vaut `0`
- **THEN** les traitements de la stack sont ignorés sans erreur de variable
  non définie

### Requirement: Déclaration statique de DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE

Le DIU SHALL déclarer `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` dans
`modules/diu/variables/docker/docker_stack_traefik_dockhand_update.sh` avec
`STATIC`, `ENABLE`, scope `docker` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` est absente au chargement
- **THEN** le DIU SHALL persister
  `export DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE=0` dans
  `/root/diu/config/docker.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs de mise à jour Traefik/Dockhand renommés

Les trois consommateurs SHALL utiliser
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` à la place de
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE`. Une valeur absente SHALL être traitée
comme `0`. Les réglages de version préexistants SHALL rester inchangés.

#### Scenario: Mise à jour désactivée ou absente

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` est absente ou vaut `0`
- **THEN** les trois opérations de mise à jour SHALL être ignorées sans erreur
  de variable non définie

#### Scenario: Mise à jour activée

- **WHEN** `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE` vaut `1`
- **THEN** les trois opérations de mise à jour existantes SHALL être activées
