## ADDED Requirements

### Requirement: Messages cohérents des publications
Les publications Debian SHALL identifier le fournisseur et le tag dans leurs messages. Les vérifications effectivement réalisées SHALL être annoncées sans exposer de secret ni attribuer à un fournisseur un contrôle non exécuté. Les informations de projet SHALL être visuellement alignées.

#### Scenario: Paquet déjà publié
- **WHEN** un paquet existe déjà sur un fournisseur
- **THEN** le message mentionne le fournisseur et le tag concerné

#### Scenario: Vérification réussie
- **WHEN** une authentification, synchronisation ou vérification de tag est réellement réussie
- **THEN** le résultat est indiqué pour le fournisseur concerné

#### Scenario: Vérification non effectuée
- **WHEN** un fournisseur ne réalise pas une vérification
- **THEN** aucun message ne prétend qu'elle a réussi

#### Scenario: Répertoire de rejeu
- **WHEN** une publication utilise un contexte de rejeu isolé
- **THEN** le répertoire affiché est identifié comme isolé
