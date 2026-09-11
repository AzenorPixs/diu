## ADDED Requirements

### Requirement: vérification du dépôt GitHub avant publication

Avant de configurer le remote local, le système MUST vérifier par une requête
GitHub authentifiée l'existence du dépôt défini par `REMOTE_GITHUB_OWNER` et
`REMOTE_GITHUB_REPOSITORY`.

#### Scenario: dépôt distant existant

- **WHEN** l'utilisateur exécute `rid projects github push <ID PROJECT>` pour un dépôt GitHub accessible
- **THEN** le système conserve le dépôt distant et poursuit la validation du remote puis le push existants

#### Scenario: vérification inaccessible

- **WHEN** l'API GitHub retourne un statut autre que `200` ou `404`
- **THEN** la commande échoue explicitement sans créer ni modifier de remote local

### Requirement: création confirmée d'un dépôt GitHub absent

Lorsque la vérification GitHub retourne `404`, le système MUST demander une
confirmation explicite avant toute création. Après confirmation, il DOIT
demander une visibilité `private` ou `public`, avec `private` comme valeur par
défaut, puis créer le dépôt sans contenu initial.

#### Scenario: création acceptée

- **WHEN** un dépôt GitHub absent est confirmé avec une visibilité valide
- **THEN** le système crée le dépôt pour le propriétaire configuré et poursuit le flux de publication existant

#### Scenario: création refusée

- **WHEN** l'utilisateur refuse la création d'un dépôt GitHub absent
- **THEN** la commande s'arrête explicitement sans créer ni modifier de remote local

#### Scenario: visibilité invalide

- **WHEN** l'utilisateur confirme la création et saisit une visibilité autre que `private` ou `public`
- **THEN** le système redemande une visibilité valide avant d'envoyer une requête de création

### Requirement: protection du token GitHub pour les appels API

Les appels GitHub nécessaires à la vérification et à la création MUST
utiliser le token sans l'inclure dans une URL, des arguments de commande ou des
journaux. Tout fichier temporaire contenant le token DOIT être en permissions
`600` et supprimé après usage.

#### Scenario: appel API authentifié

- **WHEN** la publication GitHub vérifie ou crée un dépôt
- **THEN** le token est transmis par un mécanisme temporaire protégé et n'apparaît pas dans la sortie de la commande
