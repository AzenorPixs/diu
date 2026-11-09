# projects-template-creation Specification

## Purpose
Garantir qu'un projet créé depuis le modèle local démarre sans les métadonnées
Git du modèle, tout en conservant les fichiers de travail attendus.

## Requirements

### Requirement: Copie d'un modèle sans dépôt Git

DIU MUST copier le modèle en excluant les entrées racine `project.env`, `.git`, `.worktrees`, `config`, `output`, `.cab-tests` et `openspec`. DIU MUST exclure `pyproject.toml` sauf pour le type PYTHON. Aucun traitement particulier ne vise l'ancien document de protocole. La copie MUST NOT initialiser ni configurer de dépôt Git.

#### Scenario: Modèle contenant un dépôt Git

- **WHEN** le modèle contient un répertoire `.git` à sa racine
- **THEN** le nouveau projet ne contient pas ce dépôt Git

#### Scenario: Modèle sans dépôt Git

- **WHEN** le modèle ne contient pas de répertoire `.git`
- **THEN** les éléments non exclus sont copiés et aucun dépôt Git n'est créé

#### Scenario: Projet non Python depuis un modèle Python

- **WHEN** le type du projet diffère de PYTHON
- **THEN** `pyproject.toml` n'est pas copié

#### Scenario: Projet Python depuis un modèle Python

- **WHEN** le type du projet est PYTHON
- **THEN** le manifeste `pyproject.toml` peut être copié

### Requirement: Dossiers locaux vierges et initialisation OpenSpec

DIU MUST créer `config`, `output` et `.cab-tests` vides dans le nouveau projet, indépendamment de leur présence dans le modèle. DIU MUST initialiser OpenSpec après la copie sans reprendre le répertoire OpenSpec du modèle. Une erreur de création MUST être signalée et retourner un code non nul.

#### Scenario: Modèle avec données locales

- **WHEN** les dossiers locaux du modèle contiennent des fichiers
- **THEN** le projet reçoit les trois dossiers vides sans les fichiers du modèle

#### Scenario: Modèle OpenSpec existant

- **WHEN** le modèle contient un dossier OpenSpec avec des données
- **THEN** ces données ne sont pas copiées et l'initialisation OpenSpec reste appelée

#### Scenario: Échec de création

- **WHEN** la création d'un dossier local échoue
- **THEN** DIU signale l'échec et ne déclare pas le projet créé
