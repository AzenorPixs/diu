## ADDED Requirements

### Requirement: Aide de tous les modèles pour tous les projets

Les aides projects et projects template SHALL présenter
`rid projects template all all`. Les contextes projects template all et
projects template all all SHALL fonctionner avec help et ? avant tout
chargement de configuration et sans traitement. L'aide SHALL expliquer
les deux all, les cinq variables requises, OpenSpec puis DevOps en dernier
pour chaque projet, la poursuite sur les autres projets après échec et le
bilan. Elle SHALL préciser qu'un échec OpenSpec empêche DevOps sur ce projet.
Les cibles individuelles après all et arguments supplémentaires SHALL être
rejetés avec une aide contextuelle. Les aides existantes SHALL être conservées.

#### Scenario: Découverte

- **WHEN** help ou ? suit projects ou projects template
- **THEN** l'aide présente la commande all all sans charger de configuration

#### Scenario: Aide du traitement complet

- **WHEN** help ou ? suit projects template all ou projects template all all
- **THEN** l'aide présente les sélecteurs, les critères et l'ordre par projet sans traitement

#### Scenario: Aide invalide

- **WHEN** un projet individuel suit all ou un argument supplémentaire suit all all avant help
- **THEN** l'aide rend un code non nul avec le contexte template all sans charger de configuration
