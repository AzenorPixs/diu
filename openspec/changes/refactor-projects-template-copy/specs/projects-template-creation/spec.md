## Purpose

Garantir qu'un projet créé depuis le modèle local démarre sans les métadonnées
Git du modèle, tout en conservant les fichiers de travail attendus.

## ADDED Requirements

### Requirement: Copie d'un modèle sans dépôt Git

Lors de la création d'un projet depuis
`/home/${DEVOPS_USER}/datas/template`, DIU MUST copier les éléments du modèle à
l'exception de `project.env` et du répertoire `.git` situé à la racine du
modèle, et de `ORCHESTRATED_CODING.md` lorsque le mode du projet destination
ne vaut pas `Yes`, selon la lecture contrôlée spécifiée par
implement-projects-update. DIU MUST NOT créer, initialiser ou configurer un dépôt Git pendant
cette opération.

#### Scenario: Modèle contenant un dépôt Git

- **WHEN** le modèle contient un répertoire `.git` à sa racine
- **THEN** le nouveau projet ne contient pas de répertoire `.git`
- **AND THEN** les autres fichiers du modèle sont copiés sous réserve du mode requis pour ORCHESTRATED_CODING.md

#### Scenario: Modèle sans dépôt Git

- **WHEN** le modèle ne contient pas de répertoire `.git`
- **THEN** la création conserve la copie des autres éléments sous réserve du mode requis pour ORCHESTRATED_CODING.md
- **AND THEN** aucun dépôt Git n'est créé dans le nouveau projet
