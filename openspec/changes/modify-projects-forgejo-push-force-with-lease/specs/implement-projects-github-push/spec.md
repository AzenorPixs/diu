## MODIFIED Requirements

### Requirement: commande de publication GitHub

Le système MUST exposer `rid projects github push <ID PROJECT>`. Avant le
push de branche, il MUST récupérer les références GitHub avec
l'authentification existante et MUST arrêter si le fetch échoue, sauf
indisponibilité reconnue selon `git-provider-availability`. Le push de branche
MUST utiliser `--force-with-lease`, préserver le push de tags et conserver les
parcours Forgejo et GitLab.

#### Scenario: publication du dépôt local

- **WHEN** l'utilisateur exécute `rid projects github push diu`
- **THEN** le dépôt local est poussé vers le dépôt GitHub distant configuré
- **THEN** la branche distante configurée reçoit la branche locale publiée

#### Scenario: références GitHub récupérées avant publication

- **WHEN** l'utilisateur exécute `rid projects github push <ID PROJECT>`
- **THEN** le système récupère les références du remote GitHub configuré avant
  de publier la branche
- **THEN** le push de branche utilise `--force-with-lease`

#### Scenario: récupération GitHub en échec

- **WHEN** la récupération des références du remote GitHub échoue hors indisponibilité reconnue
- **THEN** la commande échoue explicitement
- **THEN** aucune branche GitHub n'est poussée

#### Scenario: sélection explicite de GitHub

- **WHEN** le projet possède déjà une configuration Forgejo ou GitLab
- **THEN** l'utilisateur exécute `rid projects github push <ID PROJECT>`
- **THEN** la commande sélectionne explicitement le fournisseur GitHub
- **THEN** elle utilise ou initialise les variables `REMOTE_GITHUB_*`
- **THEN** elle ne remplace pas la configuration des autres fournisseurs

#### Scenario: publication GitHub sans confirmation

- ÉTANT DONNÉ une configuration GitHub et des identifiants valides
- QUAND l'utilisateur exécute `rid projects github push <ID PROJECT>`
- ALORS le parcours GitHub ne demande pas de confirmation avant le push
- ET le push démarre après les vérifications existantes
