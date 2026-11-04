# Réintroduire Forgejo en secours pour la mise à jour DIU

## Why

La mise à jour DIU dépend exclusivement de GitHub. Le développeur souhaite un secours Forgejo tout en conservant une priorité stricte à GitHub.

## What Changes

- Interroger GitHub en premier et retenir son meilleur paquet admissible, même si Forgejo peut en proposer un plus récent.
- Consulter Forgejo seulement si GitHub est absent, inaccessible, retourne une réponse invalide ou ne fournit aucun paquet admissible.
- Ne jamais tenter le secours après une erreur de téléchargement, de validation du paquet ou d'installation ; conserver GitLab hors périmètre.
- Incrémenter la version locale du projet à 1.1.2 ; préserver les publications existantes.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `diu-package-update`: réintroduire Forgejo comme fournisseur de secours strictement secondaire.

## Impact

Module de mise à jour DIU, tests, aides, documentation et spécification. Le secours utilise uniquement les releases Forgejo publiques ; aucune comparaison inter-fournisseurs.
