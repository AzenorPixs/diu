## ADDED Requirements

### Requirement: Migration de DOCKER_USER

`config_cleanup` SHALL migrer un ancien nom de compte littéral `DOCKER_USER`
depuis `variables.sh` ou `docker.env` vers `ENVIRONMENT_DOCKER_USER` dans
`docker.env` si le nouveau nom n'y est pas déjà déclaré. La nouvelle valeur
reste prioritaire; une valeur ambiguë bloque le nettoyage sans évaluation ni
modification des fichiers. Les variables `ENV_DOCKER_USER` et
`ENV_DOCKER_GROUP` restent inchangées.

#### Scenario: Ancienne valeur DOCKER_USER littérale

- **WHEN** un fichier de configuration contient `DOCKER_USER` comme nom de
  compte simple
- **THEN** sa valeur est transférée exactement vers `ENVIRONMENT_DOCKER_USER`
- **AND** l'ancienne déclaration est supprimée après migration réussie

#### Scenario: Nouveau nom prioritaire

- **WHEN** `docker.env` déclare déjà `ENVIRONMENT_DOCKER_USER`
- **THEN** cette valeur reste prioritaire et n'est pas réécrite

#### Scenario: Ancienne valeur ambiguë

- **WHEN** l'ancienne valeur `DOCKER_USER` nécessite une interprétation shell
- **THEN** le nettoyage échoue sans l'évaluer ni modifier les fichiers
- **AND** les paramètres voisins `ENV_DOCKER_USER` et `ENV_DOCKER_GROUP` sont préservés
