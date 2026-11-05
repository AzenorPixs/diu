# docker-stack-bunkerweb-update Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle de mise à jour de la stack BunkerWeb.

## Requirements

### Requirement: Déclaration statique de DOCKER_STACK_BUNKERWEB_UPDATE

Le DIU SHALL déclarer `DOCKER_STACK_BUNKERWEB_UPDATE` dans
`modules/diu/variables/docker/docker_stack_bunkerweb_update.sh` avec `STATIC`,
`ENABLE`, scope `docker` et défaut `0`. Le chargeur existant SHALL découvrir
cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `DOCKER_STACK_BUNKERWEB_UPDATE` est absente au chargement
- **THEN** le DIU SHALL persister
  `export DOCKER_STACK_BUNKERWEB_UPDATE=0` dans `/root/diu/config/docker.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs de mise à jour renommés

Les trois consommateurs SHALL utiliser `DOCKER_STACK_BUNKERWEB_UPDATE` à la
place de `DOCKER_STACK_BUNKERWEB_UPGRADE`. Une valeur absente SHALL être traitée
comme `0`. Le choix entre version détectée et version épinglée SHALL continuer
à dépendre de `DOCKER_STACK_BUNKERWEB_AUTO_UPDATE`; la version épinglée SHALL
continuer à provenir de `DOCKER_STACK_BUNKERWEB_VERSION`.

#### Scenario: Mise à jour désactivée ou absente

- **WHEN** `DOCKER_STACK_BUNKERWEB_UPDATE` est absente ou vaut `0`
- **THEN** les trois opérations de mise à jour SHALL être ignorées sans erreur
  de variable non définie

#### Scenario: Mise à jour activée

- **WHEN** `DOCKER_STACK_BUNKERWEB_UPDATE` vaut `1`
- **THEN** les trois opérations existantes SHALL être activées en conservant
  leur sélection de version
