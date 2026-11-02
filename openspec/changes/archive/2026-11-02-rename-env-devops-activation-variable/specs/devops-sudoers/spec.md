## MODIFIED Requirements

### Requirement: Activation de la génération DevOps

DIU SHALL déclarer `ENVIRONMENTS_DEVOPS` dans le scope `environnements` et
appeler la génération sudoers à la fin du bloc `ENVIRONMENTS_DEVOPS=1` dans
`root-install-debian.sh`. DIU SHALL générer des règles uniquement si le compte
désigné par `ENV_DEVOPS_USER` existe. DIU SHALL conserver le comportement des
autres parties du bloc.

#### Scenario: Environnement activé et compte présent

- **WHEN** `ENVIRONMENTS_DEVOPS` vaut `1` et `ENV_DEVOPS_USER` existe
- **THEN** la génération est appelée après la configuration du profil DevOps

#### Scenario: Compte absent

- **WHEN** le compte `ENV_DEVOPS_USER` n'existe pas au moment de la génération
- **THEN** aucun fichier sudoers n'est créé ou remplacé
- **AND** un diagnostic indique que la génération est ignorée

#### Scenario: Environnement désactivé

- **WHEN** `ENVIRONMENTS_DEVOPS` ne vaut pas `1`
- **THEN** la génération n'est pas appelée
- **AND** les éventuelles règles déjà installées ne sont pas révoquées
