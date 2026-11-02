## ADDED Requirements

### Requirement: Migration de ENV_DEVOPS

Avant le chargement de configuration, `config_cleanup` SHALL migrer la
dernière valeur littérale `0` ou `1` de `ENV_DEVOPS` depuis `variables.sh` ou
`environnements.env` vers `ENVIRONMENTS_DEVOPS` dans `environnements.env` si le
nouveau nom n'y est pas déjà déclaré. Une valeur déjà déclarée sous le nouveau
nom SHALL rester prioritaire. Une affectation ambiguë SHALL bloquer le
nettoyage sans évaluation ni modification des fichiers.

#### Scenario: Ancienne valeur ENV_DEVOPS littérale

- **WHEN** `variables.sh` ou `environnements.env` contient une affectation
  `ENV_DEVOPS=0|1`
- **THEN** sa dernière valeur littérale est transférée exactement vers
  `ENVIRONMENTS_DEVOPS`
- **AND** l'ancienne affectation est supprimée après migration réussie
- **AND** les noms voisins tels que `ENV_DEVOPS_USER` sont préservés

#### Scenario: Nouvelle valeur prioritaire

- **WHEN** `environnements.env` déclare `ENVIRONMENTS_DEVOPS`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Affectation ENV_DEVOPS ambiguë

- **WHEN** une affectation historique n'est pas un littéral simple `0` ou `1`
- **THEN** le nettoyage échoue sans l'évaluer ni modifier les fichiers
