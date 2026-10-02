## MODIFIED Requirements

### Requirement: Activation de la génération Docker
DIU SHALL appeler `configure_docker_sudoers` en fin de branche active du bloc
`ENV_DOCKER=1` de `root-install-debian.sh`, avant son else externe. La
génération SHALL agir uniquement si ENV_DOCKER_USER existe et SHALL préserver
les autres comportements du bloc.

#### Scenario: Environnement actif et compte présent
- **WHEN** ENV_DOCKER vaut 1 et ENV_DOCKER_USER existe
- **THEN** la génération est appelée en dernière instruction de la branche active, avant le else de désactivation

#### Scenario: Environnement désactivé
- **WHEN** ENV_DOCKER ne vaut pas 1
- **THEN** aucune génération n'est appelée et les règles existantes ne sont pas révoquées

#### Scenario: Compte cible absent
- **WHEN** ENV_DOCKER_USER n'existe pas au moment de la génération
- **THEN** aucun fragment n'est créé ou remplacé et un diagnostic signale l'omission

## ADDED Requirements

### Requirement: Compte rendu des autorisations publiées
Après publication réussie, DIU SHALL afficher `Sudoers Docker configuré pour
humain1 humain2.` avec les noms réellement inscrits dans le candidat validé,
séparés par un espace, dans l'ordre des règles et sans espace final. Une
sélection vide SHALL produire `Sudoers Docker : aucun compte humain retenu.`.
Un échec ou un compte cible absent SHALL NOT produire de message de succès.
Un préfixe visuel MAY précéder ces messages.

#### Scenario: Plusieurs comptes autorisés
- **WHEN** le fragment est publié avec les règles pour alice puis bob
- **THEN** le message est Sudoers Docker configuré pour alice bob.
- **AND** les comptes exclus ne sont pas affichés

#### Scenario: Aucun compte sélectionné
- **WHEN** le fragment commenté est publié sans autorisation
- **THEN** le message indique aucun compte humain retenu

#### Scenario: Publication impossible ou cible absente
- **WHEN** la génération échoue ou le compte cible est absent
- **THEN** le diagnostic correspondant est affiché sans message de succès
