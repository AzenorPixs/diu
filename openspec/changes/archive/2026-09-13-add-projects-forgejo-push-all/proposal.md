## Why

Le DIU sait publier un dépôt local vers Forgejo projet par projet, mais ne
propose pas d'opération groupée pour les projets déjà configurés. L'utilisateur
doit aujourd'hui répéter la commande pour chaque dépôt.

## What Changes

- Ajouter la commande `rid projects forgejo push all`.
- Ajouter `forgejo_push_all()` afin de sélectionner les projets dont la
  configuration Forgejo est complète, puis de déléguer chaque publication à
  `forgejo_push()`.
- Ignorer explicitement les répertoires sans `project.env` ou dont la
  configuration nécessaire au push Forgejo est incomplète.
- Mettre à jour l'aide publique et les tests ciblés.

## Capabilities

### New Capabilities

- `projects-forgejo-push-all`: publication groupée des dépôts configurés vers
  Forgejo.

### Modified Capabilities

- `implement-projects-forgejo-push`: exposition de la commande groupée.
- `rid-help`: exposition de la commande groupée dans l'aide des projets.

## Impact

Le routage des projets, le module Git des projets, l'aide `rid` et les tests
ciblés sont concernés. La commande réutilise la publication Forgejo existante
et n'ajoute aucune dépendance.
