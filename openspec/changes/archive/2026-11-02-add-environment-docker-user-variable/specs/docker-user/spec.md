## ADDED Requirements

### Requirement: Déclaration de l'utilisateur des stacks Docker

Le DIU SHALL déclarer `ENVIRONMENT_DOCKER_USER` dans
`modules/diu/variables/docker/docker_user.sh` avec `STATIC`, `ENABLE`, scope
`docker` et défaut `docker`. Sa valeur SHALL être un nom de compte simple. Les
consommateurs du profil Docker SHALL utiliser ce nom pour les chemins et
commandes des stacks.

#### Scenario: Valeur absente

- **WHEN** `ENVIRONMENT_DOCKER_USER` est absente
- **THEN** le DIU persiste `export ENVIRONMENT_DOCKER_USER=docker` dans
  `/root/diu/config/docker.env`
- **AND** exporte la valeur `docker` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `ENVIRONMENT_DOCKER_USER` contient un nom de compte simple
- **THEN** le DIU conserve et exporte sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `ENVIRONMENT_DOCKER_USER` n'est pas un nom de compte simple
- **THEN** la déclaration échoue avec un diagnostic stderr sans afficher la valeur

#### Scenario: Migration littérale de DOCKER_USER

- **WHEN** `variables.sh` ou `docker.env` contient un ancien nom `DOCKER_USER`
- **THEN** sa valeur littérale est transférée exactement vers
  `ENVIRONMENT_DOCKER_USER` si le nouveau nom n'est pas déjà déclaré
- **AND** l'ancienne déclaration est supprimée après migration réussie

#### Scenario: Propriétaire Docker existant

- **WHEN** le profil Docker utilise le propriétaire des stacks
- **THEN** les chemins et commandes utilisent `ENVIRONMENT_DOCKER_USER`
- **AND** `ENV_DOCKER_USER` reste une variable distincte
