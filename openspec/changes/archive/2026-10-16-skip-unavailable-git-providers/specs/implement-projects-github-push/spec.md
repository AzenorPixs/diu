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

### Requirement: vérification du dépôt GitHub avant publication

Avant de configurer le remote local, le système MUST vérifier par une requête
GitHub authentifiée l'existence du dépôt défini par `REMOTE_GITHUB_OWNER` et
`REMOTE_GITHUB_REPOSITORY`.

#### Scenario: dépôt distant existant

- **WHEN** l'utilisateur exécute `rid projects github push <ID PROJECT>` pour un dépôt GitHub accessible
- **THEN** le système conserve le dépôt distant et poursuit la validation du remote puis le push existants

#### Scenario: vérification inaccessible

- **WHEN** l'API GitHub retourne un statut autre que `200`, `404`, `502`, `503` ou `504`
- **THEN** la commande échoue explicitement sans créer ni modifier de remote local

## ADDED Requirements

### Requirement: serveur GitHub temporairement indisponible

Le push GitHub MUST appliquer `git-provider-availability` à ses appels API,
son fetch et ses pushes de branche et de tag. Une indisponibilité reconnue
MUST retourner zéro avec une publication non confirmée ; les autres échecs
MUST rester bloquants.

#### Scenario: API ou fetch inaccessible

- **WHEN** la vérification API ou le fetch rencontre une indisponibilité reconnue
- **THEN** aucun push n'est tenté et la commande retourne zéro avec le statut indisponible
