## Purpose

Garantir qu'un projet créé depuis le modèle local démarre sans les métadonnées
Git du modèle, tout en conservant les fichiers de travail attendus.

## ADDED Requirements

### Requirement: Copie d'un modèle sans dépôt Git

DIU MUST copier `/home/${DEVOPS_USER}/datas/template` en excluant `project.env`,
le répertoire `.git` racine, `ancien protocole local` sauf mode `Yes` selon
implement-projects-update, et `pyproject.toml` racine sauf type `PYTHON` selon
projects-template-devops. Un projet Python MAY conserver ce manifeste copié.
DIU MUST NOT créer, initialiser ou configurer de dépôt Git pendant cette copie.

#### Scenario: Modèle contenant un dépôt Git

- **WHEN** le modèle contient un répertoire `.git` à sa racine
- **THEN** le nouveau projet ne contient pas de répertoire `.git`
- **AND THEN** les autres fichiers du modèle sont copiés sous réserve des conditions de type pour pyproject.toml et de mode pour ancien protocole local

#### Scenario: Modèle sans dépôt Git

- **WHEN** le modèle ne contient pas de répertoire `.git`
- **THEN** la création conserve la copie des autres éléments sous réserve des conditions de type pour pyproject.toml et de mode pour ancien protocole local
- **AND THEN** aucun dépôt Git n'est créé dans le nouveau projet

#### Scenario: Projet non Python depuis un modèle Python

- **WHEN** le modèle contient un pyproject.toml racine et PROJECT_TYPE est absent ou différent de PYTHON
- **THEN** ce manifeste n'est pas copié dans le nouveau projet
- **AND THEN** l'exclusion de .git et la copie conditionnelle de ancien protocole local sont conservées

#### Scenario: Projet Python depuis un modèle Python

- **WHEN** le modèle contient un pyproject.toml racine et PROJECT_TYPE vaut PYTHON
- **THEN** ce manifeste peut être copié sans modification
- **AND THEN** l'exclusion de .git et la copie conditionnelle de ancien protocole local sont conservées
