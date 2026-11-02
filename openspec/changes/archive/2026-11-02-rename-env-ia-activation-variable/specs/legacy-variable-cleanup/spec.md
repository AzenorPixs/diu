## ADDED Requirements

### Requirement: Migration de ENV_IA

`config_cleanup` SHALL migrer la dernière valeur littérale `0` ou `1` de
`ENV_IA` depuis `variables.sh` ou `environnements.env` vers `ENVIRONMENT_IA`
dans `environnements.env`. Une valeur `ENVIRONMENT_IA` déjà configurée SHALL
rester prioritaire. Une valeur ambiguë bloque le nettoyage sans évaluation ni
modification des fichiers. Les paramètres suffixés `ENV_IA_USER`,
`ENV_IA_GROUP` et `ENV_IA_PASSWORD` restent inchangés.

#### Scenario: Ancienne valeur ENV_IA littérale

- **WHEN** `variables.sh` ou `environnements.env` contient `ENV_IA=0|1`
- **THEN** sa dernière valeur littérale est transférée exactement vers
  `ENVIRONMENT_IA`
- **AND** l'ancienne affectation est supprimée après migration réussie

#### Scenario: Nouvelle valeur prioritaire

- **WHEN** `environnements.env` déclare `ENVIRONMENT_IA`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Affectation ENV_IA ambiguë

- **WHEN** une affectation historique `ENV_IA` n'est pas un littéral simple
  `0` ou `1`
- **THEN** le nettoyage échoue sans l'évaluer ni modifier les fichiers
- **AND** les paramètres suffixés restent préservés
