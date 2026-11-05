## RENAMED Requirements

- FROM: `### Requirement: Exécution sous DEVOPS_USER`
- TO: `### Requirement: Exécution sous ENV_DEVOPS_USER`

## MODIFIED Requirements

### Requirement: Exécution sous ENV_DEVOPS_USER

Toute commande Git authentifiée SHALL être exécutée sous l'utilisateur
système `ENV_DEVOPS_USER` via `runuser`.

Le processus Git enfant SHALL appartenir à `ENV_DEVOPS_USER`.

#### Scenario: Exécution sous le bon utilisateur

WHEN une commande Git authentifiée est exécutée
THEN le processus Git s'exécute sous l'identité de ENV_DEVOPS_USER
AND les fichiers créés dans le dépôt appartiennent à ENV_DEVOPS_USER
