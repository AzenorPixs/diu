## MODIFIED Requirements

### Requirement: Sélection cohérente de la version de release

La release SHALL appliquer PROJECT_VERSION en priorité lorsqu’elle est déclarée, sinon la sélection historique commune avec le builder. Sans clé ni tag, elle SHALL conserver la version du paquet sans nouvel horodatage. La version retenue SHALL égaler celle du paquet et le tag SHALL être v<VERSION>, sans déplacement d’un tag existant.

#### Scenario: Release et paquet concordants

- **GIVEN** PROJECT_VERSION est absente de project.env

- **WHEN** une release est préparée
- **THEN** une version ambiguë, invalide ou différente du paquet arrête la publication ; aucun tag existant n’est déplacé

