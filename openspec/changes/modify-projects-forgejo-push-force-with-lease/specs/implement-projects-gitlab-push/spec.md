## MODIFIED Requirements

### Requirement: commande de publication GitLab

Le système MUST exposer la commande `diu projects gitlab push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- **GIVEN** le dépôt local du projet `diu`
- **WHEN** l'utilisateur exécute `diu projects gitlab push diu`
- **THEN** le dépôt local est poussé vers le dépôt GitLab distant configuré
- **AND** la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitLab

- **GIVEN** que le projet possède déjà une configuration Forgejo
- **WHEN** l'utilisateur exécute `diu projects gitlab push <ID PROJECT>`
- **THEN** la commande sélectionne explicitement le fournisseur GitLab
- **AND** elle utilise ou initialise les variables `REMOTE_GITLAB_*`

#### Scenario: publication GitLab sans confirmation

- **GIVEN** une configuration GitLab et des identifiants valides
- **WHEN** l'utilisateur exécute `diu projects gitlab push <ID PROJECT>`
- **THEN** le parcours GitLab ne demande pas de confirmation avant le push
- **AND** le push démarre après les vérifications existantes
