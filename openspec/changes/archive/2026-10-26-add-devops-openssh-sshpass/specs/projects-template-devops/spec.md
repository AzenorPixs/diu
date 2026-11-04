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
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Structure de l'inventaire matériel TPM

La rubrique Matériel SHALL contenir une sous-rubrique TPM avec six puces
dans cet ordre : Chemin, Version, Fabricant, Identifiant fournisseur,
Révision de spécification, Registres PCR. Le rendu SHALL être commun aux
générations individuelle, groupée et finale de création.

#### Scenario: Rendu matériel commun

- **WHEN** un des trois parcours génère le document
- **THEN** Matériel et TPM apparaissent une seule fois après l'OS et avant les rubriques de conteneurs activées, ou avant OpenSSH & SSHPASS si elles sont omises
- **AND THEN** les six champs sont présents dans l'ordre prévu

### Requirement: Rubrique LXC documentaire conditionnelle

Le rendu commun SHALL générer `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH`
uniquement si ENV_DEVOPS_TESTS_LXC vaut exactement `1`, indépendamment de Docker.
Une valeur absente, vide ou différente SHALL omettre cette rubrique.
LXC SHALL suivre Docker s'il est présent, sinon Matériel, et SHALL précéder OpenSSH & SSHPASS, puis Docker-Compose.
Le format SHALL rester `0.7` et les trois parcours SHALL partager ce comportement.

#### Scenario: Deux conteneurs activés

- **WHEN** les deux indicateurs valent exactement `1`
- **THEN** les rubriques sont Matériel, Conteneur Docker, Conteneur LXC, OpenSSH & SSHPASS, Docker-Compose

#### Scenario: LXC seul

- **WHEN** seul ENV_DEVOPS_TESTS_LXC vaut exactement `1`
- **THEN** LXC suit Matériel et précède OpenSSH & SSHPASS puis Docker-Compose sans rubrique ni sonde Docker

#### Scenario: LXC désactivé

- **WHEN** ENV_DEVOPS_TESTS_LXC est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique LXC et ses cinq puces sont omises indépendamment de Docker

## ADDED Requirements

### Requirement: Rubrique locale OpenSSH et SSHPASS

Le rendu commun SHALL émettre une seule rubrique `OpenSSH & SSHPASS` après les rubriques de conteneurs présentes et avant Docker-Compose, indépendamment des indicateurs Docker et LXC. Elle SHALL contenir exactement quatre puces : version OpenSSH, chemin hôte de ssh, version sshpass, chemin hôte de sshpass. Le format SHALL rester 0.7.

#### Scenario: Rubrique dans tous les parcours

- **WHEN** un document est généré individuellement, en groupe ou en fin de création
- **THEN** la rubrique apparaît une seule fois avec ses quatre puces, après LXC s’il est actif et immédiatement avant Docker-Compose
- **AND** les conditions et contenus des autres rubriques restent préservés

#### Scenario: Conteneurs désactivés

- **WHEN** Docker et LXC sont omis
- **THEN** OpenSSH & SSHPASS suit Matériel et précède Docker-Compose

### Requirement: Sondes locales de version SSH

DIU SHALL résoudre ssh et sshpass dans le PATH système contrôlé et appeler chaque binaire une fois avec le seul argument -V, avec une borne de 15 secondes. DIU SHALL extraire uniquement la version de la première ligne OpenSSH_ ou sshpass, y compris OpenSSH sur stderr. DIU MUST NOT établir de connexion, lire d’identifiants, installer d’outil ni modifier les droits pour ces sondes.

#### Scenario: Versions observées et actualisées

- **WHEN** les binaires retournent OpenSSH_10.0p2 suivi d’informations Debian/OpenSSL et sshpass 1.10 suivi de sa licence
- **THEN** seules les versions 10.0p2 et 1.10 apparaissent avec leurs chemins respectifs
- **AND** une génération ultérieure utilise les nouvelles versions retournées, sans valeur codée en dur

#### Scenario: Outil indisponible ou sortie invalide

- **WHEN** un outil est absent, non exécutable, échoue, expire ou ne retourne pas le préfixe et une version reconnus
- **THEN** sa puce de version porte un diagnostic explicite sans sortie brute, ancienne version ni repli vers la version OpenSSL
- **AND** le chemin détecté, ou une absence explicite de binaire, reste indiqué et les autres rubriques sont générées
