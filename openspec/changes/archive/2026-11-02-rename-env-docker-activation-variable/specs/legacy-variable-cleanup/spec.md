## ADDED Requirements

### Requirement: Migration de ENV_DOCKER

`config_cleanup` SHALL migrer le littéral `ENV_DOCKER=0|1` vers
`ENVIRONMENT_DOCKER` dans `environnements.env`. Une valeur nouvelle existante
reste prioritaire. Les affectations ambiguës bloquent sans évaluation ni
modification; les variables voisines `ENV_DOCKER_*` sont conservées.

#### Scenario: Ancienne valeur ENV_DOCKER littérale

- **WHEN** `variables.sh` ou `environnements.env` contient `ENV_DOCKER=0|1`
- **THEN** sa dernière valeur littérale est transférée exactement vers
  `ENVIRONMENT_DOCKER`
- **AND** l'ancienne affectation est supprimée après migration réussie

#### Scenario: Nouvelle valeur prioritaire

- **WHEN** `environnements.env` déclare `ENVIRONMENT_DOCKER`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Affectation ENV_DOCKER ambiguë

- **WHEN** une affectation historique `ENV_DOCKER` n'est pas un littéral simple
  `0` ou `1`
- **THEN** le nettoyage échoue sans l'évaluer ni modifier les fichiers
- **AND** les variables suffixées `ENV_DOCKER_*` restent inchangées
