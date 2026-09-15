## MODIFIED Requirements

### Requirement: Identifiants de destination dans la configuration clonée

Après la copie réussie, DIU MUST remplacer l'affectation `PROJECT_ID` du
fichier `project.env` destination par `<ID PROJECT DESTINATION>`. Si elles
sont présentes, DIU MUST aussi remplacer les affectations
`REMOTE_REPOSITORY`, `REMOTE_FORGEJO_REPOSITORY`,
`REMOTE_GITLAB_REPOSITORY`, `REMOTE_GITHUB_REPOSITORY` et `PG_DATABASE` par
`<ID PROJECT DESTINATION>`. DIU MUST préserver les autres variables et les
lignes non ciblées de ce fichier.

#### Scenario: Mise à jour de project.env

- **WHEN** `source/project.env` définit `PROJECT_ID=source`, une ou plusieurs
  variables de dépôt distant, `PG_DATABASE=source` et d'autres variables
- **THEN** `destination/project.env` définit `PROJECT_ID=destination`, les
  variables de dépôt distant présentes et `PG_DATABASE=destination`
- **AND THEN** les autres variables et lignes non ciblées sont conservées

#### Scenario: Absence de configuration PostgreSQL

- **WHEN** `source/project.env` ne définit pas `PG_DATABASE`
- **THEN** `destination/project.env` ne reçoit pas d'affectation `PG_DATABASE`
