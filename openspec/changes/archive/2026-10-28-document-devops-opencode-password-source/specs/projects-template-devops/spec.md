## ADDED Requirements

### Requirement: Source documentaire du mot de passe API OpenCode

La rubrique OpenCode MUST ajouter une seule puce statique `La variable OPENCODE_PASSWORD pour l'API est chargée depuis project.env` immédiatement après le chemin du binaire, avant les dépendances éventuelles. Cet ajout MUST NOT lire project.env ou consulter la variable. Le rendu commun MUST conserver les sondes et le format 0.7.

#### Scenario: Génération avec ou sans configuration API

- **WHEN** le rendu commun génère la rubrique OpenCode, que la variable soit présente ou absente
- **THEN** la puce exacte apparaît une seule fois immédiatement après le chemin du binaire
- **AND THEN** aucun mot de passe n'est lu ou affiché pour produire cette indication

#### Scenario: Dépendances OpenCode déclarées

- **WHEN** le projet possède des dépendances OpenCode affichables
- **THEN** la puce de provenance précède leur sous-section
- **AND THEN** les versions, chemins, inventaires et autres rubriques conservent leur comportement

#### Scenario: Parcours de génération

- **WHEN** la génération est individuelle, groupée ou finale lors d'une création
- **THEN** le rendu commun conserve la version 0.7 et l'ordre des autres rubriques
