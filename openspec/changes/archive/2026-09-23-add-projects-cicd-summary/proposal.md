## Why

Le flux `rid projects cicd <ID PROJECT>` affiche les détails de chaque étape,
mais ne fournit pas de bilan final compact permettant d'identifier rapidement
le commit, les forges publiées, l'image construite et les releases créées.

## What Changes

- Ajouter un résumé console final au flux CI/CD d'un projet.
- Indiquer les opérations effectivement réalisées, les opérations ignorées et
  leurs cibles configurées.
- Afficher un bilan partiel avant le retour lors de l'échec d'une opération
  effectivement appelée.

## Capabilities

### Modified Capabilities

- `projects-cicd`: bilan final des opérations CI/CD.

## Impact

- `modules/projects/git.sh` et les tests ciblés de projets.
