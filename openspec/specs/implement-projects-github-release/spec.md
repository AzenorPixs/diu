# implement-projects-github-release Specification

## Purpose
Définir la sélection et la publication des artefacts Docker et Debian d'un projet
vers GitHub Container Registry et GitHub Releases.

## Requirements

### Requirement: commande de release GitHub

Le système MUST exposer `diu projects github release <ID PROJECT>`, qui appelle
`projects_github_release <ID PROJECT>`. Selon les indicateurs Yes/YES/1, la
commande MUST publier Docker seul, Debian seul ou les deux ; sans artefact actif,
elle MUST terminer sans publication. Elle MUST NOT lancer de build.

#### Scenario: aide GitHub

- **WHEN** l'utilisateur demande `diu projects github help`
- **THEN** l'aide présente `release <ID PROJECT>`

#### Scenario: Debian seul
- **WHEN** seul PROJECT_DEBIAN_PACKAGE est actif
- **THEN** le paquet est publié dans GitHub Releases sans appel de Docker

#### Scenario: Deux artefacts
- **WHEN** les deux indicateurs sont actifs et les artefacts requis sont présents
- **THEN** Docker est publié sur GHCR puis le paquet dans GitHub Releases

#### Scenario: Aucun artefact
- **WHEN** aucun indicateur n'est actif
- **THEN** la commande informe qu'aucun artefact n'est à publier et réussit

### Requirement: publication Docker GHCR conditionnelle

Si PROJECT_DOCKERED vaut Yes/YES/1, le sélecteur MUST appeler projects_github_release_docker. Ce helper MUST publier l'image locale selon project-version vers GHCR avec VERSION et latest, et les chemins propriétaire/dépôt en minuscules. Sans PROJECT_VERSION, VERSION MUST venir de l'unique tag de HEAD. Configuration, image ou tag invalide MUST provoquer un échec. Il MUST NOT appeler projects_docker_build.

#### Scenario: image Docker préalablement construite

- **WHEN** le projet est Dockerisé, l'image locale et la configuration GitHub sont disponibles
- **THEN** les références versionnée et `latest` sont publiées vers GHCR
- **AND THEN** aucune construction Docker n'est déclenchée

#### Scenario: propriétaire ou dépôt avec majuscules

- **WHEN** le propriétaire vaut `AzenorPixs` ou le dépôt vaut `PKeycloak`
- **THEN** les chemins GHCR sont construits avec le propriétaire et le dépôt en minuscules
- **AND THEN** Docker reçoit ces chemins normalisés pour les tags et les pushes
- **AND THEN** le résumé CI/CD affiche les mêmes chemins

#### Scenario: configuration déjà en minuscules

- **WHEN** le propriétaire et le dépôt sont déjà en minuscules
- **THEN** les références GHCR restent identiques au comportement antérieur

#### Scenario: conservation de la configuration et de la version

- **WHEN** la release utilise une configuration avec majuscules et le tag Git `v1.2.3-RC1`
- **THEN** le tag Docker versionné est `1.2.3-RC1`
- **AND THEN** les valeurs des variables GitHub chargées et le fichier `project.env` conservent leur casse originale
- **AND THEN** l'authentification et l'image locale restent inchangées

### Requirement: authentification GitHub Container Registry

La release MUST utiliser les identifiants GitHub locaux existants et un
`DOCKER_CONFIG` temporaire sécurisé pour `docker login ghcr.io`, sans afficher
le token.

#### Scenario: publication authentifiée

- **WHEN** les identifiants GitHub locaux sont valides
- **THEN** le token est transmis à Docker par l'entrée standard
- **AND THEN** aucun token n'apparaît dans la sortie
