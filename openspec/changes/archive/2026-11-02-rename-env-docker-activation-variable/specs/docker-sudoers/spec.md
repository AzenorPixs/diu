## MODIFIED Requirements

### Requirement: Activation de la génération Docker

DIU SHALL déclarer `ENVIRONMENT_DOCKER` dans le scope `environnements` et
appeler `configure_docker_sudoers` en fin de branche active du bloc
`ENVIRONMENT_DOCKER=1` de `root-install-debian.sh`, avant son else externe. La
génération SHALL agir uniquement si `ENV_DOCKER_USER` existe et SHALL préserver
les autres comportements du bloc.

#### Scenario: Environnement actif et compte présent

- **WHEN** `ENVIRONMENT_DOCKER` vaut 1 et `ENV_DOCKER_USER` existe
- **THEN** la génération est appelée en dernière instruction de la branche active, avant le else de désactivation

#### Scenario: Environnement désactivé

- **WHEN** `ENVIRONMENT_DOCKER` ne vaut pas 1
- **THEN** aucune génération n'est appelée et les règles existantes ne sont pas révoquées

#### Scenario: Compte cible absent

- **WHEN** `ENV_DOCKER_USER` n'existe pas au moment de la génération
- **THEN** aucun fragment n'est créé ou remplacé et un diagnostic signale l'omission
