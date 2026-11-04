## ADDED Requirements

### Requirement: poursuite après indisponibilité pendant une release

Dans `rid projects cicd <ID PROJECT> [VERSION]`, une indisponibilité réseau reconnue pendant une release Forgejo, GitLab ou GitHub MUST être signalée comme publication non confirmée et MUST permettre de poursuivre les autres fournisseurs éligibles. Sans autre erreur, le bilan MUST indiquer les indisponibilités et le retour MUST être zéro. Toute publication déjà effectuée MUST être conservée et sa possible partialité signalée. Les statuts MUST être isolés entre appels et fournisseurs.

#### Scenario: release interrompue par une panne reconnue

- **WHEN** une release rencontre une indisponibilité réseau reconnue et les autres opérations éligibles réussissent
- **THEN** les fournisseurs suivants sont traités et le bilan indique la publication non confirmée
- **AND THEN** le code de retour est zéro

#### Scenario: panne après publication partielle

- **WHEN** un artefact ou une référence a pu être publié avant l’indisponibilité
- **THEN** le bilan indique que la publication peut être partielle et qu’une reprise est nécessaire
- **AND THEN** aucun rollback ni succès complet n’est annoncé

#### Scenario: erreur non qualifiée

- **WHEN** une release échoue pour un refus d’authentification, une erreur TLS ou de configuration, un rejet ou une autre cause non reconnue comme indisponibilité
- **THEN** l’erreur reste bloquante et le retour est non nul

#### Scenario: commandes directes et rejeu

- **WHEN** la release est appelée directement hors CI/CD ou le flux rejoue une version existante
- **THEN** le contrat des releases directes et les restrictions du rejeu restent inchangés
