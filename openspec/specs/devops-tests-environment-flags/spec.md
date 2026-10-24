# devops-tests-environment-flags Specification

## Purpose
Initialiser à zéro les indicateurs de tests DevOps Docker et LXC lorsqu'ils
sont absents, avec persistance dans le scope environnements, conservation des
valeurs existantes et traitement explicite des erreurs, sans lancer de tests.

## Requirements

### Requirement: Déclarations des indicateurs de tests DevOps

Le DIU SHALL déclarer `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC`
dans deux fichiers unitaires sous `modules/diu/variables/environnements/`,
avec `config=STATIC`, `state=ENABLE`, `scope=environnements` et `default_value=0`.
Le chargeur existant SHALL les découvrir sans modification.

#### Scenario: Découverte des déclarations

- **WHEN** `config_generator` parcourt les déclarations unitaires
- **THEN** les fichiers `env_devops_tests_docker.sh` et `env_devops_tests_lxc.sh` sont chargés dans le scope `environnements`

### Requirement: Initialisation indépendante et persistante

Chaque variable absente SHALL être persistée à `0` dans
`/root/diu/config/environnements.env`, puis exportée à `0`.
Chaque nouvelle ligne SHALL commencer par huit espaces ASCII avant
`export NOM=0`. La déclaration SHALL créer le répertoire de configuration si
nécessaire et SHALL conserver les autres lignes du fichier.

#### Scenario: Première initialisation

- **WHEN** les deux variables et le fichier de configuration sont absents
- **THEN** le fichier contient une déclaration `export NOM=0` précédée exactement de huit espaces pour chacune des deux variables
- **AND** les deux variables valent `0` dans l'environnement des processus enfants

#### Scenario: Configuration partielle

- **WHEN** une seule des deux variables est absente après chargement de la configuration
- **THEN** seule cette variable est initialisée et persistée à `0`, avec huit espaces avant `export`
- **AND** la valeur de l'autre variable et les lignes préexistantes sont conservées sans reformatage

### Requirement: Conservation des valeurs et idempotence

Une variable déjà définie SHALL conserver sa valeur, même vide, et SHALL être
exportée sans écriture de sa déclaration. Un nouveau chargement normal de la
configuration suivi de la génération MUST NOT ajouter de doublon.

#### Scenario: Valeur existante

- **WHEN** une variable est déjà définie à `0`, `1` ou à une valeur vide
- **THEN** sa valeur est conservée et exportée sans réécriture

#### Scenario: Réexécution avec rechargement

- **WHEN** la configuration générée est rechargée puis les déclarations sont exécutées de nouveau
- **THEN** le contenu persistant reste identique, avec une seule ligne pour chaque variable

### Requirement: Erreurs de persistance explicites

Si la création du répertoire ou l'écriture persistante échoue, la déclaration
concernée SHALL retourner un statut non nul et un diagnostic sur stderr.
Elle MUST NOT exporter de nouvelle valeur pour la variable concernée.

#### Scenario: Répertoire impossible à créer

- **WHEN** la création du répertoire de configuration échoue
- **THEN** la déclaration échoue explicitement sans définir la variable absente

#### Scenario: Fichier impossible à écrire

- **WHEN** la persistance dans le fichier de configuration échoue
- **THEN** la déclaration échoue explicitement sans définir la variable absente

### Requirement: Désactivation déclarative limitée

Une déclaration dont `state` vaut `DISABLE` SHALL retirer sa variable de
l'environnement et supprimer uniquement sa ligne `export NOM=` exacte du
fichier persistant, avec ou sans espaces ou tabulations initiaux.
Un échec de suppression SHALL produire un statut non nul et un diagnostic
stderr.

#### Scenario: Retrait d'une déclaration désactivée

- **WHEN** la déclaration d'une variable est désactivée
- **THEN** cette variable et sa ligne persistante sont retirées, que le retrait initial soit absent, composé d'espaces ou de tabulations
- **AND** l'autre variable et les noms voisins sont conservés

### Requirement: Absence d'activation des environnements de test

L'ajout de ces déclarations MUST NOT lancer Docker, LXC ou des tests dans ces
environnements, ni modifier leur installation ou leur configuration.

#### Scenario: Génération seule

- **WHEN** les deux indicateurs sont initialisés
- **THEN** seules leurs valeurs de configuration sont générées et exportées
- **AND** aucune commande Docker ou LXC n'est exécutée
