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
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root` si activé, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Distinction entre hôte et environnement DevOps

DIU SHALL relever le système d'exploitation hôte et les versions des outils
hôte Docker-Compose, Git, OpenSSL et PostgreSQL Client. Docker SHALL être
relevé uniquement si ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`. DIU SHALL
relever Go, Node, NPM, OpenCode, OpenSpec, Python et pip depuis les binaires
situés dans `/home/${ENV_DEVOPS_USER}`, sous cet utilisateur. DIU SHALL NOT
remplacer un outil DevOps manquant par un outil hôte. NPM et OpenSpec SHALL
utiliser le Node DevOps et pip SHALL utiliser le Python DevOps, sans dépendre
des shebangs des scripts. Les sondes DevOps SHALL être exécutées depuis le
domicile de cet utilisateur sans changer le répertoire de l'appelant, y
compris lorsque son répertoire courant lui est inaccessible après changement
d'utilisateur. Une sonde absente, échouée ou sans version reconnue
SHALL être indiquée explicitement, sans conserver une version ancienne.

#### Scenario: Versions hôte différentes

- **WHEN** le PATH hôte contient un Node et un Python différents de ceux du domicile DevOps
- **THEN** les rubriques DevOps indiquent les versions et chemins du domicile DevOps

#### Scenario: Outil manquant ou défaillant

- **WHEN** un outil est absent ou sa sonde échoue
- **THEN** sa rubrique indique que sa version est indisponible et le chemin attendu ou l'absence de binaire
- **AND THEN** aucune installation n'est réalisée

#### Scenario: Répertoire de l'appelant inaccessible à DevOps

- **WHEN** la génération est lancée depuis un dossier inaccessible à l'utilisateur DevOps, par exemple /root
- **THEN** les sondes, notamment go version, sont exécutées depuis son domicile accessible
- **AND THEN** la version Go disponible est relevée et le répertoire courant de l'appelant est préservé

### Requirement: Références Docker des tests nécessitant des droits root

La rubrique Docker SHALL porter le titre exact
`Conteneur Docker, pour tests nécessitant des droits root`. Elle SHALL contenir quatre
puces, dans cet ordre : version détectée ou diagnostic existant, chemin du
binaire ou diagnostic existant, `/var/run/docker.sock`, `debian:stable-slim`.
Les deux dernières puces SHALL rester des références documentaires fixes.
Les autres rubriques et sondes SHALL être conservées.

#### Scenario: Docker disponible

- **GIVEN** ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`
- **WHEN** la version et le binaire Docker sont détectés
- **THEN** la rubrique porte le titre exact et les quatre puces dans l'ordre prévu
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
- **THEN** la rubrique Docker, ses quatre puces et sa sonde sont omises
- **AND** Docker-Compose et les autres rubriques restent présents

### Requirement: Structure de l'inventaire matériel TPM

La rubrique Matériel SHALL contenir une sous-rubrique TPM avec six puces
dans cet ordre : Chemin, Version, Fabricant, Identifiant fournisseur,
Révision de spécification, Registres PCR. Le rendu SHALL être commun aux
générations individuelle, groupée et finale de création.

#### Scenario: Rendu matériel commun

- **WHEN** un des trois parcours génère le document
- **THEN** Matériel et TPM apparaissent une seule fois après l'OS et avant les rubriques de conteneurs activées, ou avant Docker-Compose si elles sont omises
- **AND THEN** les six champs sont présents dans l'ordre prévu

## ADDED Requirements

### Requirement: Activation de la rubrique Docker

La rubrique Docker SHALL être générée uniquement si ENV_DEVOPS_TESTS_DOCKER vaut
exactement `1`. Une valeur absente, vide ou différente SHALL omettre la rubrique
et MUST NOT provoquer de résolution ou de sonde du binaire Docker.

#### Scenario: Indicateur Docker désactivant

- **WHEN** ENV_DEVOPS_TESTS_DOCKER est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique Docker et sa sonde sont omises, indépendamment de LXC
- **AND** Docker-Compose reste présent

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
- **THEN** la rubrique LXC et ses trois puces sont omises indépendamment de Docker

### Requirement: Contenu documentaire LXC

La rubrique LXC SHALL contenir exactement trois puces dans l'ordre :
`Variables d'accès disponible dans project.env`, `Debian 13`, `Accès TPM OK`.
Ces mentions SHALL rester déclaratives et MUST NOT être présentées comme une
qualification distante.

#### Scenario: Contenu fixe demandé

- **WHEN** LXC est activé dans un des trois parcours
- **THEN** le titre et les trois puces exactes apparaissent une seule fois dans l'ordre prévu

### Requirement: Absence de connexion pour le rendu LXC

Le générateur MUST NOT lire les identifiants LXC, se connecter à un conteneur
ou lancer une sonde TPM distante pour cette rubrique.

#### Scenario: Rendu sans accès distant

- **WHEN** la rubrique LXC est générée dans un des trois parcours
- **THEN** les trois mentions sont émises sans commande LXC, accès aux identifiants ou sonde TPM distante
