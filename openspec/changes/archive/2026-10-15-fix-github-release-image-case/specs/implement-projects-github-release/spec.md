## MODIFIED Requirements

### Requirement: publication Docker GHCR conditionnelle

`projects_github_release` MUST vérifier que `PROJECT_DOCKERED` vaut `Yes`,
`YES` ou `1`, puis publier l'image locale
`<PROJECT_ID>:latest` vers
`ghcr.io/<REMOTE_GITHUB_OWNER>/<REMOTE_GITHUB_REPOSITORY>` avec un tag dérivé
de l'unique tag Git de `HEAD` et avec `latest`. La fonction MUST échouer si
l'image locale, le tag Git unique ou la configuration GitHub attendue manque.

Les chemins GHCR MUST être construits en minuscules.

La fonction MUST NOT appeler `projects_docker_build`.

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
