# Spec Delta

## MODIFIED Requirements

### Requirement: Création du dépôt Forgejo absent

Le provider Forgejo SHALL vérifier le dépôt avant récupération : présent
(`200`), il confirme son existence ; absent (`404`), il délègue sa création
au premier push sans création API. Une autre réponse SHALL être une erreur,
qualifiée selon `git-provider-availability` dans le contexte de push tolérant ;
hors contexte, le contrat d'erreur SHALL rester inchangé.

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

- **WHEN** Forgejo refuse la vérification du dépôt pour une cause autre qu'une indisponibilité reconnue
- **THEN** le provider retourne une erreur explicite
- **THEN** aucune opération Git n'est tentée

#### Scenario: Création refusée

- **WHEN** Forgejo refuse le premier push Git vers le dépôt absent pour une cause autre qu'une indisponibilité reconnue
- **THEN** le provider retourne l'erreur du push Git
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Vérification temporairement indisponible dans un push

- **WHEN** la vérification du dépôt rencontre une indisponibilité reconnue dans le contexte de push tolérant
- **THEN** la publication publique suit git-provider-availability sans création ni push
- **AND THEN** les clones et releases directes conservent leur contrat d'erreur hors de ce contexte

