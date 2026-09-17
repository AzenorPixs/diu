## MODIFIED Requirements

### Requirement: complément GitLab ciblé

`gitlab_update()` MUST demander et enregistrer uniquement les variables
suivantes :

```bash
REMOTE_GITLAB_BASE_URL=
REMOTE_GITLAB_REGISTRY=
REMOTE_GITLAB_OWNER=
REMOTE_GITLAB_REPOSITORY="<ID PROJECT>"
REMOTE_GITLAB_NAME="origin"
REMOTE_GITLAB_BRANCH="main"
```

`REMOTE_GITLAB_REGISTRY` MUST contenir l'adresse explicite du registre Docker,
avec son port lorsqu'il est requis. La fonction DOIT préserver toutes les autres
lignes de `project.env`, notamment les variables générales et Forgejo.

#### Scenario: configuration GitLab absente

- **GIVEN** que la configuration générale est conforme
- **AND** que les variables GitLab sont absentes ou incomplètes
- **WHEN** un push GitLab est demandé
- **THEN** seules les valeurs GitLab manquantes sont demandées avec leurs
  valeurs par défaut
- **AND** `REMOTE_GITLAB_REGISTRY` est demandée et enregistrée comme registre
  Docker explicite
- **AND** les variables GitLab sont ajoutées ou remplacées sans réécrire le
  reste de `project.env`
