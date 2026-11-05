## MODIFIED Requirements

### Requirement: Copie d'un modèle sans dépôt Git

DIU MUST copier `/home/${ENV_DEVOPS_USER}/datas/template` en excluant `project.env`, le répertoire `.git` racine, `ORCHESTRATED_CODING.md`, et `pyproject.toml` racine sauf type `PYTHON` selon projects-template-devops. Un projet Python MAY conserver ce manifeste copié. DIU MUST NOT créer, initialiser ou configurer de dépôt Git pendant cette copie.

#### Scenario: Modèle contenant un dépôt Git

- **WHEN** le modèle contient un répertoire `.git` à sa racine
- **THEN** le nouveau projet ne contient ni `.git` ni `ORCHESTRATED_CODING.md`
- **AND THEN** les autres fichiers sont copiés sous réserve du type pour `pyproject.toml`

#### Scenario: Modèle sans dépôt Git

- **WHEN** le modèle ne contient pas de répertoire `.git`
- **THEN** les autres éléments sont copiés sous réserve du type pour `pyproject.toml` et de l'exclusion de `ORCHESTRATED_CODING.md`
- **AND THEN** aucun dépôt Git n'est créé dans le nouveau projet

#### Scenario: Projet non Python depuis un modèle Python

- **WHEN** le modèle contient un `pyproject.toml` racine et PROJECT_TYPE est absent ou différent de PYTHON
- **THEN** ce manifeste n'est pas copié et `.git` et `ORCHESTRATED_CODING.md` sont exclus

#### Scenario: Projet Python depuis un modèle Python

- **WHEN** le modèle contient un `pyproject.toml` racine et PROJECT_TYPE vaut PYTHON
- **THEN** ce manifeste peut être copié sans modification et `.git` et `ORCHESTRATED_CODING.md` sont exclus
