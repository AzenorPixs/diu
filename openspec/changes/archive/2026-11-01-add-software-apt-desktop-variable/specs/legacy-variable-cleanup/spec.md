## ADDED Requirements

### Requirement: Migration de DESKTOP

Avant de charger la configuration, `config_cleanup` SHALL transférer la
dernière valeur littérale `0` ou `1` de `DESKTOP` vers
`SOFTWARES_APT_DESKTOP` dans `softwares.env` si aucune valeur nouvelle n'y est
déjà déclarée. La nouvelle valeur conserve la priorité. Une valeur ambiguë
SHALL bloquer le nettoyage sans évaluer son contenu ni modifier les fichiers.

#### Scenario: Ancienne valeur DESKTOP littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  `DESKTOP=0|1`
- **THEN** la dernière valeur est transférée exactement vers
  `SOFTWARES_APT_DESKTOP`
- **AND** les affectations historiques sont supprimées après migration réussie

#### Scenario: Nouvelle valeur prioritaire

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_DESKTOP`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Affectation DESKTOP ambiguë

- **WHEN** une affectation historique nécessite une interprétation shell
- **THEN** le nettoyage échoue sans supprimer l'affectation ni modifier
  `softwares.env`
