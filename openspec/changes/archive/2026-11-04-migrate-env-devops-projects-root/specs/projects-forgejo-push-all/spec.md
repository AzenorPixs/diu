## MODIFIED Requirements

### Requirement: publication Forgejo de tous les projets configurés

DIU MUST exposer `rid projects forgejo push all`. La commande MUST parcourir
les sous-répertoires directs de `${ENV_DEVOPS_PROJECTS_ROOT}`, dont la valeur
attendue est `/home/${ENV_DEVOPS_USER}/datas`, et appeler `forgejo_push()` une
fois pour chaque projet sélectionné.

#### Scenario: plusieurs projets Forgejo configurés

- **WHEN** l'utilisateur exécute `rid projects forgejo push all`
- **THEN** DIU parcourt les sous-répertoires directs de
  `${ENV_DEVOPS_PROJECTS_ROOT}`
- **AND THEN** il appelle `forgejo_push()` une fois pour chaque projet
  sélectionné
