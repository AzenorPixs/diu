## ADDED Requirements

### Requirement: Image versionnée optionnelle
Le build Docker SHALL ajouter le tag local PROJECT_VERSION lorsqu’elle est déclarée et valide, tout en conservant latest. Sans cette clé, la commande Docker existante SHALL rester inchangée.

#### Scenario: Version déclarée
- **WHEN** PROJECT_VERSION vaut 1.0.0
- **THEN** le build produit les tags locaux du projet 1.0.0 et latest avec le même contenu
