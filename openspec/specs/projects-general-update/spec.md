# projects-general-update Specification

## Purpose
Définir la mise à jour générale des modèles des projets configurés,
son intégration dans rid update et la préservation de la mise à jour
interactive des variables d'un projet ciblé.

## Requirements

### Requirement: Mise à jour générale des modèles des projets

DIU SHALL exposer la mise à jour générale des projets sans identifiant, déléguer une seule fois au traitement des modèles et préserver sa sélection, son ordre, son bilan et son résultat.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Mise à jour générale

- **WHEN** l'utilisateur exécute rid projects update sans identifiant
- **THEN** projects_update appelle projects_template_all_all une seule fois sans argument

#### Scenario: Échec d'un modèle

- **WHEN** le traitement all all échoue
- **THEN** la mise à jour générale rend un code non nul sans annoncer de succès

#### Scenario: Aucun projet éligible

- **WHEN** le traitement all all ne sélectionne aucun projet
- **THEN** le bilan vide est conservé et la mise à jour réussit

#### Scenario: Arguments directs invalides

- **WHEN** projects_update reçoit un argument
- **THEN** elle rend un diagnostic et un code non nul avant appel de modèle

#### Scenario: Délégation de la mise à jour générale des projets

- **WHEN** projects_update ou rid projects update sans identifiant est demandé
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL exposer rid projects update sans identifiant et projects_update
sans argument. La fonction SHALL appeler projects_template_all_all une seule
fois, sans lancer un nouveau processus CLI ni modifier la configuration.
Elle SHALL conserver le traitement all all : mêmes projets éligibles selon
project.env, OpenSpec avant DevOps en dernier pour chaque projet, poursuite
après échec, fichiers conservés et bilan. Elle SHALL transmettre le code de
retour de ce traitement et refuser tout argument avant son appel.
Elle SHALL NOT ajouter synchronisation, configuration Git ou fournisseurs.

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
