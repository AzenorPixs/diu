## MODIFIED Requirements

### Requirement: Initialisation ou actualisation sous le compte DevOps

La fonction SHALL exécuter dans le répertoire du projet, via
`su - "$ENV_DEVOPS_USER" -c`, `openspec update` si le dossier openspec existe.
Sinon, elle SHALL déterminer une valeur OpenCode effective locale au projet.
Sans dossier `.opencode` dans le projet, cette valeur SHALL être 0, quelle que
soit la valeur configurée de OPENCODE ; un fichier non répertoire SHALL NOT
compter comme dossier. Avec ce dossier, la valeur effective SHALL être la
valeur configurée de OPENCODE. La fonction SHALL NOT modifier la variable
OPENCODE de l'appelant ou des projets suivants.
Elle SHALL exécuter `openspec init --tools opencode --profile custom` si la
valeur effective vaut 1 et `openspec init --profile custom` si elle vaut 0.
Une valeur effective absente ou différente SHALL empêcher l'initialisation
avec diagnostic. Les caractères spéciaux du chemin SHALL être transmis
littéralement au shell enfant. Un échec SHALL produire un diagnostic et un
code non nul, sans succès. La fonction SHALL NOT supprimer les écritures
partielles d'OpenSpec.

#### Scenario: Initialisation avec OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE=1
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --tools opencode --profile custom dans le projet

#### Scenario: Initialisation sans OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE=0
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --profile custom dans le projet

#### Scenario: Dossier OpenCode absent

- **WHEN** openspec et le dossier .opencode sont absents, avec OPENCODE égal à 0, 1, une valeur invalide, vide ou non définie
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --profile custom dans le projet
- **AND** OPENCODE conserve sa valeur configurée ou son absence dans l'appelant

#### Scenario: Fichier OpenCode non répertoire

- **WHEN** openspec est absent, .opencode est un fichier ordinaire et OPENCODE=1
- **THEN** l'initialisation utilise openspec init --profile custom

#### Scenario: Valeur invalide avec dossier OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE est invalide, vide ou non défini
- **THEN** la fonction rend un code non nul avec diagnostic sans appeler su

#### Scenario: Projets mixtes sans contamination du choix OpenCode

- **WHEN** un appel groupé avec OPENCODE=1 traite un projet sans .opencode puis un projet avec ce dossier
- **THEN** le premier est initialisé sans intégration OpenCode et le second avec --tools opencode
- **AND** la variable configurée reste égale à 1

#### Scenario: Actualisation indépendante du choix OpenCode

- **WHEN** le dossier openspec existe déjà, notamment après copie du modèle, avec ou sans dossier .opencode
- **THEN** le compte ENV_DEVOPS_USER exécute openspec update dans le projet indépendamment de OPENCODE

#### Scenario: Chemin contenant des caractères shell

- **WHEN** le chemin contient espaces, apostrophes, dollars ou backticks
- **THEN** le shell enfant rejoint exactement ce chemin sans interpréter son contenu comme une commande

#### Scenario: Échec de l'outil

- **WHEN** su ou OpenSpec échoue
- **THEN** l'opération signale un échec sans annoncer de succès ni supprimer le projet
