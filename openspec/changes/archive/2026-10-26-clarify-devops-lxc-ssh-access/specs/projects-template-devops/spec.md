## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version
`0.7` et l'ordre du scénario « Rubriques documentaires conservées ».
Pour template, le titre SHALL être `DEVOPS.md — Template`.
Matériel SHALL suivre immédiatement Système d'exploitation.
Chaque rubrique logicielle SHALL placer le chemin après la version ;
PostgreSQL Serveur SHALL placer l'adresse après la version.
Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.7 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Rubrique LXC documentaire conditionnelle

Le rendu commun SHALL générer `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH`
uniquement si ENV_DEVOPS_TESTS_LXC vaut exactement `1`, indépendamment de Docker.
Une valeur absente, vide ou différente SHALL omettre cette rubrique.
LXC SHALL suivre Docker s'il est présent, sinon Matériel, et SHALL précéder Docker-Compose.
Le format SHALL rester `0.7` et les trois parcours SHALL partager ce comportement.

#### Scenario: Deux conteneurs activés

- **WHEN** les deux indicateurs valent exactement `1`
- **THEN** les rubriques sont Matériel, Conteneur Docker, Conteneur LXC, Docker-Compose

#### Scenario: LXC seul

- **WHEN** seul ENV_DEVOPS_TESTS_LXC vaut exactement `1`
- **THEN** LXC suit Matériel et précède Docker-Compose sans rubrique ni sonde Docker

#### Scenario: LXC désactivé

- **WHEN** ENV_DEVOPS_TESTS_LXC est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique LXC et ses cinq puces sont omises indépendamment de Docker

### Requirement: Contenu documentaire LXC

La rubrique LXC SHALL contenir exactement cinq puces dans l'ordre :
`Variables d'accès disponible dans project.env pour l'accès SSH`, `Debian 13`, `Accès TPM OK`,
puis la puce commune d’autorisation et enfin
`Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests.`.
Les trois premières mentions SHALL rester déclaratives et MUST NOT être présentées comme une
qualification distante.

#### Scenario: Contenu fixe demandé

- **WHEN** LXC est activé dans un des trois parcours
- **THEN** le titre et les cinq puces exactes apparaissent une seule fois dans l'ordre prévu

#### Scenario: Conservation des dépendances de test

- **WHEN** la rubrique LXC est générée
- **THEN** sa cinquième et dernière puce est exactement `Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests.`
- **AND** aucune installation ni désinstallation n’est exécutée par ce rendu documentaire

### Requirement: Absence de connexion pour le rendu LXC

Le générateur MUST NOT lire les identifiants LXC, se connecter à un conteneur
ou lancer une sonde TPM distante pour cette rubrique.

#### Scenario: Rendu sans accès distant

- **WHEN** la rubrique LXC est générée dans un des trois parcours
- **THEN** les cinq puces sont émises sans commande LXC, accès aux identifiants ou sonde TPM distante

### Requirement: Puce commune d'autorisation des tests

Chaque rubrique de conteneur activée SHALL contenir la puce exacte ci-dessous,
en dernière position pour Docker et en quatrième position pour LXC :
`Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests.`.

#### Scenario: Autorisation explicite en dernière position

- **WHEN** Docker est activé dans un des trois parcours de génération
- **THEN** sa dernière puce est la formulation validée
- **AND** elle suit l’image Docker

#### Scenario: Rubrique omise

- **WHEN** une rubrique de conteneur est désactivée
- **THEN** aucune puce d'autorisation n'est émise pour cette rubrique
- **AND** aucune autre rubrique ne reçoit cette autorisation

#### Scenario: Autorisation LXC avant la conservation des dépendances

- **WHEN** LXC est activé dans un des trois parcours de génération
- **THEN** sa quatrième puce est la formulation commune validée
- **AND** elle suit « Accès TPM OK » et précède la puce de conservation des binaires et bibliothèques
