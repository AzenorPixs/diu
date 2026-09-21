## Why

La publication Docker GitLab dérive actuellement son registre de l'URL Git du
projet. Cette dérivation perd un port de registre dédié, tel que
`git.ec-nantes.fr:5050`, et dirige alors les publications vers un endpoint
incorrect.

## What Changes

- Ajouter une variable GitLab dédiée `REMOTE_GITLAB_REGISTRY` pour identifier
  explicitement le registre Docker d'un projet.
- Demander et enregistrer cette variable dans `gitlab_update()` sans modifier
  les variables hors GitLab de `project.env`.
- Lors d'une release Docker GitLab, relancer `gitlab_update()` si la variable
  est absente, puis utiliser le registre configuré pour l'authentification, le
  marquage et la publication Docker.
- Ajouter des tests isolés pour le registre avec port et la reconfiguration
  d'une configuration existante incomplète.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `add-projects-gitlab-update`: la configuration GitLab comprend le registre
  Docker explicite.
- `refine-projects-gitlab-push-config`: le différentiel GitLab persiste la
  variable de registre sans toucher aux autres domaines de configuration.
- `implement-projects-gitlab-release`: une release Docker utilise le registre
  configuré et reconfigure un projet Dockerisé si cette variable manque.

## Impact

- `modules/projects/git.sh`: configuration GitLab et publication Docker.
- `tests/test_projects.py`: tests sans réseau de la publication GitLab.
- Les projets Dockerisés GitLab existants seront invités à renseigner le
  registre lors de leur première release après la mise à jour.
