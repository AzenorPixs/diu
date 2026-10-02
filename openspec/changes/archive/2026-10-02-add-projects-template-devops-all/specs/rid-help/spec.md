## MODIFIED Requirements

### Requirement: Aide de génération du modèle DevOps

L'aide rid projects help SHALL présenter rid projects template <ID PROJECT>
devops et rid projects template all devops. Les aides du contexte template, du projet ciblé et de la commande
terminale SHALL fonctionner avec help et ?, avant tout chargement de
configuration et sans génération. Les arguments surnuméraires, les chemins
et une opération terminale inconnue SHALL être rejetés avec une aide
contextuelle. L'aide create SHALL préciser la génération finale de DEVOPS.md.

#### Scenario: Aide intermédiaire ou terminale

- **WHEN** help ou ? suit projects template, projects template application ou projects template application devops
- **THEN** l'aide présente la syntaxe avec l'identifiant de projet sans écriture

#### Scenario: Aide inconnue sous template

- **WHEN** une opération inconnue ou des arguments supplémentaires sont suivis de help
- **THEN** l'aide rend un code d'erreur et suggère le contexte template du projet

#### Scenario: Aide de création

- **WHEN** l'utilisateur exécute rid projects create help
- **THEN** l'aide indique la création depuis le modèle et la génération finale de DEVOPS.md

#### Scenario: Aide du traitement groupé

- **WHEN** help ou ? suit projects template all ou projects template all devops
- **THEN** l'aide présente la génération pour tous les projets configurés avec les cinq variables requises
- **AND THEN** aucune configuration n'est chargée et aucun document n'est généré

#### Scenario: Découverte du traitement groupé

- **WHEN** l'utilisateur demande projects help ou projects template help
- **THEN** l'aide présente les commandes individuelle et all

