## ADDED Requirements

### Requirement: Aide de la mise à jour générale des projets

L'aide projects SHALL présenter rid projects update et conserver rid projects
update <ID PROJECT>. Les contextes projects update et projects update
<ID PROJECT> SHALL fonctionner avec help et ? avant tout chargement de
configuration et sans opération. L'aide générale SHALL indiquer tous les
modèles de tous les projets configurés, OpenSpec puis DevOps en dernier.
L'aide ciblée SHALL expliquer la mise à jour des variables du seul projet.
L'aide rid update SHALL indiquer l'inclusion de la mise à jour générale des
projets. Les arguments d'aide supplémentaires SHALL être refusés avec un
diagnostic contextuel et les aides existantes SHALL être préservées.

#### Scenario: Découverte et contexte général

- **WHEN** help ou ? suit projects ou projects update
- **THEN** l'aide présente les deux usages sans charger la configuration

#### Scenario: Aide ciblée

- **WHEN** help ou ? suit projects update application ou projects update all
- **THEN** l'aide décrit la modification des variables du projet ciblé sans appeler de modèle

#### Scenario: Aide globale

- **WHEN** l'utilisateur demande rid update help ou rid update ?
- **THEN** l'aide indique la mise à jour générale des projets sans opération

#### Scenario: Arguments d'aide supplémentaires

- **WHEN** un argument supplémentaire suit l'identifiant avant help
- **THEN** l'aide rend un code non nul sans configuration ni écriture
