## MODIFIED Requirements

### Requirement: commande de publication GitHub

Le système MUST exposer la commande `rid projects github push <ID PROJECT>`.

Le système DOIT exposer la commande `rid projects github push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `rid projects github push diu`
- ALORS le dépôt local est poussé vers le dépôt GitHub distant configuré
- ET la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitHub

- ÉTANT DONNÉ que le projet possède déjà une configuration Forgejo ou GitLab
- QUAND l'utilisateur exécute `rid projects github push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur GitHub
- ET elle utilise ou initialise les variables `REMOTE_GITHUB_*`
- ET elle ne remplace pas la configuration des autres fournisseurs

#### Scenario: publication GitHub sans confirmation

- ÉTANT DONNÉ une configuration GitHub et des identifiants valides
- QUAND l'utilisateur exécute `rid projects github push <ID PROJECT>`
- ALORS le parcours GitHub ne demande pas de confirmation avant le push
- ET le push démarre après les vérifications existantes
