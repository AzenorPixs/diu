## ADDED Requirements

### Requirement: Migration de DOCKER_STACK_BUNKERWEB_UPGRADE

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de
`DOCKER_STACK_BUNKERWEB_UPGRADE` vers `DOCKER_STACK_BUNKERWEB_UPDATE` dans
`docker.env` si le nouveau nom n’y est pas déjà déclaré. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `DOCKER_STACK_BUNKERWEB_UPGRADE`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `DOCKER_STACK_BUNKERWEB_UPDATE` dans `docker.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `DOCKER_STACK_BUNKERWEB_AUTO_UPDATE` et
  `DOCKER_STACK_BUNKERWEB_VERSION` SHALL rester inchangées

#### Scenario: Nouvelle valeur déjà configurée

- **WHEN** `docker.env` déclare déjà `DOCKER_STACK_BUNKERWEB_UPDATE`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur ambiguë

- **WHEN** une affectation historique nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `docker.env`
- **AND** SHALL NOT afficher son contenu
