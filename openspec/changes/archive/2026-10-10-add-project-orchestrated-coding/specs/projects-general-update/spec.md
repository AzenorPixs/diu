## MODIFIED Requirements

### Requirement: Préservation de la mise à jour ciblée

La CLI SHALL transmettre l'identifiant de rid projects update <ID PROJECT>
à update_projects. Le questionnaire SHALL ajouter PROJECT_ORCHESTRATED_CODING
selon implement-projects-update et préserver les autres variables et effets.
all SHALL rester un identifiant ciblé ; un identifiant vide ou des arguments
supplémentaires SHALL être rejetés avant mise à jour. Sans identifiant, DIU
SHALL conserver la délégation aux modèles, sans questionnement ni migration.

#### Scenario: Projet ciblé

- **WHEN** l'utilisateur exécute rid projects update application ou rid projects update all
- **THEN** update_projects reçoit le seul identifiant et aucun traitement groupé n'est appelé

#### Scenario: Arguments CLI invalides

- **WHEN** un identifiant vide est fourni explicitement ou un argument supplémentaire suit l'identifiant
- **THEN** la CLI rend un code non nul et une aide contextuelle avant traitement

#### Scenario: Mise à jour générale sans question de mode

- **WHEN** rid projects update est exécuté sans identifiant
- **THEN** le traitement des modèles reste inchangé et ne demande pas PROJECT_ORCHESTRATED_CODING
