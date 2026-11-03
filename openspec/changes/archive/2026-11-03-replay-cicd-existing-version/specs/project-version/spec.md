## ADDED Requirements

### Requirement: Rejeu isolé d'une version attribuée
Le CI/CD SHALL poursuivre le rejeu d'une version attribuée à partir du commit du tag, sans créer de commit vide ni modifier le tag ou les modifications locales en attente.

#### Scenario: Version existante et arbre modifié
- **WHEN** la version est déjà attribuée et des modifications locales sont présentes
- **THEN** les étapes de construction et de publication utilisent le commit du tag dans un contexte isolé
- **AND THEN** les modifications locales restent disponibles et ne sont pas livrées sous cette version
