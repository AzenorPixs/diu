## Why

Les commandes de commit échouent actuellement lorsqu'un projet configuré ne
possède pas encore de dépôt Git local. Elles doivent pouvoir réutiliser le
parcours d'initialisation existant avant de créer le commit demandé, sans
attendre de saisie humaine ni afficher les fichiers ajoutés au premier commit.

## What Changes

- Initialiser le dépôt local avec `git_init()` lorsque `git_commit()` détecte
  son absence, puis vérifier de nouveau que le dépôt est disponible.
- Rendre l'initialisation et la création du premier commit locales,
  non interactives et silencieuses lorsqu'elles réussissent.
- Appliquer ce comportement au commit individuel et, par délégation de
  `git_commit_all()`, au commit groupé des projets configurés.
- Conserver l'arrêt du commit concerné si l'initialisation échoue.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `projects-git-commit`: Initialisation du dépôt local absent avant le commit.
- `projects-git-commit-all`: Initialisation des dépôts locaux absents des
  projets sélectionnés avant leur commit.
- `projects-git-init`: Initialisation locale non interactive et silencieuse.

## Impact

- `modules/projects/git.sh` pour le parcours commun de commit local.
- `tests/test_rid_help.py` pour les scénarios ciblés sans dépôt local.
