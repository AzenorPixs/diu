## ADDED Requirements

### Requirement: Aide des exceptions système Git

L'aide des commandes `rid projects git init`, `update` et `status` MUST
mentionner respectivement l'enregistrement de l'exception système et
l'affichage de son état. Les signatures des commandes MUST rester inchangées.

#### Scenario: Consultation de l'aide Git

- **WHEN** l'aide projects, projects git ou projects git status est demandée
- **THEN** les descriptions concernées mentionnent safe.directory système
- **AND** les commandes conservent leurs arguments publics existants
