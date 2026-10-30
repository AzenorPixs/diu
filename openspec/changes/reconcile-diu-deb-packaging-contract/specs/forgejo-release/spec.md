## ADDED Requirements

### Requirement: Sélection cohérente de la version de release

La release SHALL appliquer la même sélection des versions de tags de HEAD que le builder. Sans tag, elle SHALL conserver la version du paquet, sans nouvel horodatage. La version retenue SHALL égaler celle du paquet ; sinon la publication SHALL être refusée. Le tag de release SHALL être v<VERSION>.

#### Scenario: Release et paquet concordants

- **WHEN** une release est préparée
- **THEN** une version ambiguë, invalide ou différente du paquet arrête la publication ; aucun tag existant n’est déplacé

