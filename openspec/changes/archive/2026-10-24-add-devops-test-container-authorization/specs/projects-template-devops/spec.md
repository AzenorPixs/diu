## MODIFIED Requirements

### Requirement: Références Docker des tests nécessitant des droits root

La rubrique Docker SHALL porter le titre exact
`Conteneur Docker, pour tests nécessitant des droits root`. Elle SHALL contenir cinq
puces, dans cet ordre : version détectée ou diagnostic existant, chemin du
binaire ou diagnostic existant, `/var/run/docker.sock`, `debian:stable-slim`, puis la puce commune d’autorisation.
Le socket et l’image SHALL rester des références documentaires fixes.


#### Scenario: Docker disponible

- **GIVEN** ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`
- **WHEN** la version et le binaire Docker sont détectés
- **THEN** la rubrique porte le titre exact et les cinq puces dans l'ordre prévu
- **AND THEN** les deux références apparaissent chacune une seule fois

#### Scenario: Docker indisponible

- **GIVEN** ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`
- **WHEN** le binaire Docker est absent ou sa sonde échoue
- **THEN** les diagnostics existants sont conservés dans les premières puces
- **AND THEN** le socket et l'image restent indiqués sans nouvelle sonde ou action Docker

#### Scenario: Portée documentaire des références

- **WHEN** les références Docker sont ajoutées au document
- **THEN** le générateur ne sonde pas le socket, ne télécharge ni ne lance l'image et ne modifie aucune permission
- **AND THEN** leur présence ne constitue pas une preuve de disponibilité ou de fonctionnement

#### Scenario: Docker désactivé

- **WHEN** ENV_DEVOPS_TESTS_DOCKER est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique Docker, ses cinq puces et sa sonde sont omises
- **AND** Docker-Compose et les autres rubriques restent présents

### Requirement: Rubrique LXC documentaire conditionnelle

Le rendu commun SHALL générer `Conteneur LXC, pour tests nécessitant des droits root`
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
- **THEN** la rubrique LXC et ses quatre puces sont omises indépendamment de Docker

### Requirement: Contenu documentaire LXC

La rubrique LXC SHALL contenir exactement quatre puces dans l'ordre :
`Variables d'accès disponible dans project.env`, `Debian 13`, `Accès TPM OK`,
puis la puce commune d’autorisation.
Les trois premières mentions SHALL rester déclaratives et MUST NOT être présentées comme une
qualification distante.

#### Scenario: Contenu fixe demandé

- **WHEN** LXC est activé dans un des trois parcours
- **THEN** le titre et les quatre puces exactes apparaissent une seule fois dans l'ordre prévu

### Requirement: Absence de connexion pour le rendu LXC

Le générateur MUST NOT lire les identifiants LXC, se connecter à un conteneur
ou lancer une sonde TPM distante pour cette rubrique.

#### Scenario: Rendu sans accès distant

- **WHEN** la rubrique LXC est générée dans un des trois parcours
- **THEN** les quatre puces sont émises sans commande LXC, accès aux identifiants ou sonde TPM distante

## ADDED Requirements

### Requirement: Puce commune d'autorisation des tests

Chaque rubrique de conteneur activée SHALL se terminer par la puce exacte :
`Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests.`.

#### Scenario: Autorisation explicite en dernière position

- **WHEN** Docker ou LXC est activé dans un des trois parcours de génération
- **THEN** la dernière puce est la formulation validée, identique pour les deux conteneurs
- **AND** elle suit l'image Docker ou « Accès TPM OK » pour LXC

#### Scenario: Rubrique omise

- **WHEN** une rubrique de conteneur est désactivée
- **THEN** aucune puce d'autorisation n'est émise pour cette rubrique
- **AND** aucune autre rubrique ne reçoit cette autorisation

### Requirement: Portée documentaire de l'autorisation

L'ajout de la puce SHALL rester un rendu documentaire et MUST NOT modifier les
contrôles techniques de permissions des outils ou plateformes, ni lancer des
opérations de test ou de conteneur pendant la génération.
Un échec d'écriture de cette puce SHALL être propagé.

#### Scenario: Génération sans modification des permissions

- **WHEN** la puce est ajoutée à un document
- **THEN** les conditions, sondes, format 0.7 et autres rubriques restent inchangés
- **AND** aucun contrôle technique de permission n'est désactivé

#### Scenario: Échec du rendu de l'autorisation

- **WHEN** l'écriture de la puce échoue
- **THEN** le rendu retourne un statut non nul et l'ancien document est conservé
