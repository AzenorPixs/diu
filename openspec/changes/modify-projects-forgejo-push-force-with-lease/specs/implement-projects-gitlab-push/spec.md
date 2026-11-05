## MODIFIED Requirements

### Requirement: commande de publication GitLab

Le système MUST exposer la commande `diu projects gitlab push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `diu projects gitlab push diu`
- ALORS le dépôt local est poussé vers le dépôt GitLab distant configuré
- ET la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitLab

- ÉTANT DONNÉ que le projet possède déjà une configuration Forgejo
- QUAND l'utilisateur exécute `diu projects gitlab push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur GitLab
- ET elle utilise ou initialise les variables `REMOTE_GITLAB_*`

#### Scenario: publication GitLab sans confirmation

- ÉTANT DONNÉ une configuration GitLab et des identifiants valides
- QUAND l'utilisateur exécute `diu projects gitlab push <ID PROJECT>`
- ALORS le parcours GitLab ne demande pas de confirmation avant le push
- ET le push démarre après les vérifications existantes
