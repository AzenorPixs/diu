## Why

Le DIU permet de créer un commit Git pour un projet, mais ne propose pas
d'opération équivalente pour les projets configurés du répertoire de travail
DevOps. La gestion de plusieurs projets impose aujourd'hui de répéter la même
commande manuellement.

## What Changes

- Ajouter la commande `rid projects commit all`.
- Ajouter `git_commit_all()` afin de sélectionner les projets configurés et
  de déléguer chaque commit à `git_commit()`.
- Ignorer explicitement les répertoires sans `project.env` ou dont la
  configuration Git locale est incomplète.
- Mettre à jour l'aide publique et ses tests ciblés.

## Capabilities

### New Capabilities

- `projects-git-commit-all`: commit local groupé des projets configurés.

### Modified Capabilities

- `rid-help`: exposition de la commande de commit groupé dans l'aide des
  projets.

## Impact

Le routage des projets, le module Git des projets, l'aide `rid` et les tests
d'aide ciblés sont concernés. Aucune dépendance ni opération réseau n'est
ajoutée.
