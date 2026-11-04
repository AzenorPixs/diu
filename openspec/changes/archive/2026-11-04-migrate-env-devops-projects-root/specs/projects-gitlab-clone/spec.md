## MODIFIED Requirements

### Requirement: Clonage GitLab d'un projet

Le système MUST fournir `rid projects gitlab clone <ID PROJECT>`. Il MUST
créer le projet, appeler `gitlab_update`, cloner le dépôt GitLab configuré
sous `ENV_DEVOPS_USER`, puis fusionner son contenu sans métadonnée Git.

#### Scenario: Fusion prioritaire et sûre

- **WHEN** le dépôt distant est cloné avec succès
- **THEN** ses fichiers, y compris cachés, remplacent les chemins homonymes
- **AND** les fichiers du modèle absents du dépôt sont conservés
- **AND** aucun répertoire `.git` n'est présent dans le projet résultant
