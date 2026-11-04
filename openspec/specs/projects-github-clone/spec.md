# projects-github-clone Specification

## Purpose
Créer et fusionner de manière sûre un projet depuis un dépôt GitHub distant.

## Requirements

### Requirement: Clonage GitHub d'un projet

Le système MUST fournir `rid projects github clone <ID PROJECT>`. Il MUST
créer le projet, appeler `github_update`, cloner le dépôt GitHub configuré
sous `ENV_DEVOPS_USER`, puis fusionner son contenu sans métadonnée Git.

#### Scenario: Fusion prioritaire et sûre

- **WHEN** le dépôt distant est cloné avec succès
- **THEN** ses fichiers, y compris cachés, remplacent les chemins homonymes
- **AND** les fichiers du modèle absents du dépôt sont conservés
- **AND** aucun fichier ou répertoire `.git` n'est présent dans le projet

### Requirement: Aide sans effet

Les formes `help` et `?` de la commande GitHub clone MUST afficher l'aide
sans créer de projet ni lancer de clonage.

#### Scenario: Consultation de l'aide

- **WHEN** l'utilisateur exécute `rid projects github clone help` ou `?`
- **THEN** l'aide de la commande est affichée
- **AND** aucune création ou opération Git n'est exécutée
