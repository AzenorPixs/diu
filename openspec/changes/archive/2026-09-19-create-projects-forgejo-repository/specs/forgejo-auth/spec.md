# Spec Delta

## ADDED Requirements

### Requirement: Création du dépôt Forgejo absent

Le provider Forgejo SHALL vérifier l'existence du dépôt distant avant toute
récupération de références. Lorsqu'il est absent, il SHALL créer un dépôt vide
par l'API Forgejo authentifiée si le propriétaire est l'utilisateur
authentifié ou une organisation accessible avec le token. Il SHALL refuser
explicitement la création sous un autre compte utilisateur, sans utiliser une
API d'administration.

#### Scenario: Dépôt utilisateur absent

- **WHEN** le dépôt distant est absent et son propriétaire est l'utilisateur
  authentifié
- **THEN** le provider crée un dépôt vide sous ce compte
- **THEN** le dépôt créé devient accessible avant toute opération Git

#### Scenario: Dépôt d'organisation absent

- **WHEN** le dépôt distant est absent et son propriétaire est une
  organisation accessible avec le token
- **THEN** le provider crée un dépôt vide dans cette organisation
- **THEN** le dépôt créé devient accessible avant toute opération Git

#### Scenario: Compte utilisateur distinct

- **WHEN** le dépôt distant est absent et son propriétaire est un compte
  utilisateur différent de l'utilisateur authentifié
- **THEN** le provider retourne une erreur explicite
- **THEN** aucun dépôt n'est créé

#### Scenario: Création refusée

- **WHEN** Forgejo refuse la création du dépôt absent
- **THEN** le provider retourne une erreur explicite sans exposer le token
- **THEN** aucune opération Git n'est tentée
