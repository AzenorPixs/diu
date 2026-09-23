# implement-projects-github-release Specification

## Purpose
Définir la publication Docker d'un projet DIU vers GitHub Container Registry.

## Requirements

### Requirement: commande de release GitHub

Le système MUST exposer `rid projects github release <ID PROJECT>`, qui appelle
`projects_github_release <ID PROJECT>`.

#### Scenario: aide GitHub

- **WHEN** l'utilisateur demande `rid projects github help`
- **THEN** l'aide présente `release <ID PROJECT>`

### Requirement: publication Docker GHCR conditionnelle

`projects_github_release` MUST vérifier que `PROJECT_DOCKERED` vaut `Yes`,
`YES` ou `1`, puis publier l'image locale
`<PROJECT_ID>:latest` vers
`ghcr.io/<REMOTE_GITHUB_OWNER>/<REMOTE_GITHUB_REPOSITORY>` avec un tag dérivé
de l'unique tag Git de `HEAD` et avec `latest`. La fonction MUST échouer si
l'image locale, le tag Git unique ou la configuration GitHub attendue manque.

La fonction MUST NOT appeler `projects_docker_build`.

#### Scenario: image Docker préalablement construite

- **WHEN** le projet est Dockerisé, l'image locale et la configuration GitHub
  sont disponibles
- **THEN** les références versionnée et `latest` sont publiées vers GHCR
- **AND THEN** aucune construction Docker n'est déclenchée

### Requirement: authentification GitHub Container Registry

La release MUST utiliser les identifiants GitHub locaux existants et un
`DOCKER_CONFIG` temporaire sécurisé pour `docker login ghcr.io`, sans afficher
le token.

#### Scenario: publication authentifiée

- **WHEN** les identifiants GitHub locaux sont valides
- **THEN** le token est transmis à Docker par l'entrée standard
- **AND THEN** aucun token n'apparaît dans la sortie
