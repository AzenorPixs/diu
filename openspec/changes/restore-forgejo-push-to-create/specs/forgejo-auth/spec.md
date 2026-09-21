# Spec Delta

## MODIFIED Requirements

### Requirement: Création du dépôt Forgejo absent

Le provider Forgejo SHALL vérifier l'existence du dépôt distant avant toute
récupération de références. Lorsqu'il est absent, il SHALL indiquer que la
création doit être réalisée par le premier push Git Forgejo et ne SHALL
effectuer aucun appel API de création. Il SHALL retourner une erreur explicite
pour toute réponse autre que `200` ou `404` lors de cette vérification.

#### Scenario: Dépôt absent

- **WHEN** le dépôt distant est absent
- **THEN** le provider n'effectue aucun appel API de création
- **THEN** le parcours de publication peut réaliser le premier push Git

#### Scenario: Dépôt utilisateur absent

- **WHEN** le dépôt distant est absent et son propriétaire est l'utilisateur
  authentifié
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Dépôt d'organisation absent

- **WHEN** le dépôt distant est absent et son propriétaire est une
  organisation accessible avec le token
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Compte utilisateur distinct

- **WHEN** le dépôt distant est absent et son propriétaire est un compte
  utilisateur différent de l'utilisateur authentifié
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Dépôt existant

- **WHEN** le dépôt distant existe
- **THEN** le provider confirme son existence avant la récupération des
  références

#### Scenario: Vérification refusée

- **WHEN** Forgejo refuse la vérification du dépôt
- **THEN** le provider retourne une erreur explicite
- **THEN** aucune opération Git n'est tentée

#### Scenario: Création refusée

- **WHEN** Forgejo refuse le premier push Git vers le dépôt absent
- **THEN** le provider retourne l'erreur du push Git
- **THEN** aucun appel API de création n'est effectué
