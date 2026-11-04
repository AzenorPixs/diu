## MODIFIED Requirements

### Requirement: Clonage GitHub d'un projet

Le système MUST fournir `rid projects github clone <ID PROJECT>`. Il MUST
créer le projet, appeler `github_update`, cloner le dépôt GitHub configuré
sous `ENV_DEVOPS_USER`, puis fusionner son contenu sans métadonnée Git.

#### Scenario: Fusion prioritaire et sûre

- **WHEN** le dépôt distant est cloné avec succès
- **THEN** ses fichiers, y compris cachés, remplacent les chemins homonymes
- **AND** les fichiers du modèle absents du dépôt sont conservés
- **AND** aucun fichier ou répertoire `.git` n'est présent dans le projet
