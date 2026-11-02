## MODIFIED Requirements

### Requirement: Migration de DESKTOP

Avant de charger la configuration, `config_cleanup` SHALL transférer la
dernière valeur littérale `0` ou `1` de `DESKTOP` de `variables.sh` vers
`desktop.env` si `DESKTOP` n'y est pas déjà déclaré. Il SHALL aussi transférer
`SOFTWARES_APT_DESKTOP=0|1` de `softwares.env` vers `DESKTOP` dans
`desktop.env`, avec priorité à `DESKTOP` déjà présent, puis à l'ancienne valeur
`SOFTWARES_APT_DESKTOP` sur l'affectation `DESKTOP` de `variables.sh`. Après
une migration réussie, les anciennes affectations sont retirées de leurs
fichiers sources. Toute syntaxe ambiguë SHALL bloquer le nettoyage sans
évaluation ni modification des fichiers.

#### Scenario: Ancienne valeur DESKTOP littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  `DESKTOP=0|1`
- **THEN** la dernière valeur est transférée exactement vers `desktop.env`
- **AND** les affectations historiques sont supprimées après migration réussie

#### Scenario: Nouvelle valeur prioritaire

- **WHEN** `desktop.env` déclare déjà `DESKTOP`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Affectation DESKTOP ambiguë

- **WHEN** une affectation historique nécessite une interprétation shell
- **THEN** le nettoyage échoue sans supprimer l'affectation ni modifier
  `desktop.env`

#### Scenario: Migration de l'ancien scope logiciels

- **WHEN** `softwares.env` déclare `SOFTWARES_APT_DESKTOP=0|1` et
  `desktop.env` ne déclare pas encore `DESKTOP`
- **THEN** la valeur est transférée exactement sous le nom `DESKTOP`
- **AND** l'ancienne déclaration logiciels est supprimée
