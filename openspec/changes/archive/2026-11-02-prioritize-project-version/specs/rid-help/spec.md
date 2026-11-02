## ADDED Requirements

### Requirement: Aide de la version prioritaire
Les aides de commit, push, CICD et builds Debian/Docker SHALL décrire PROJECT_VERSION, son format x.y.z, sa priorité et la conservation des mécanismes antérieurs en absence de clé. Elles SHALL rester disponibles avant bootstrap.

#### Scenario: Aide sans configuration
- **WHEN** une aide des opérations concernées est demandée
- **THEN** elle présente le contrat de version sans lire project.env ni lancer d'opération
