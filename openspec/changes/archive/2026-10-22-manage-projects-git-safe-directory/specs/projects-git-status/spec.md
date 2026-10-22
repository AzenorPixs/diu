## ADDED Requirements

### Requirement: Diagnostic de l'exception système en lecture seule

`rid projects git status <ID PROJECTS>` MUST afficher la présence ou
l'absence de l'exception `safe.directory` système exacte et le chemin
canonique concerné avant les opérations sur le dépôt. Le diagnostic MUST
identifier la portée système et MUST NOT présenter une règle large comme
une entrée exacte. Les autres informations du statut Git MUST être conservées.

#### Scenario: Exception présente ou absente

- **WHEN** le statut Git d'un projet est demandé
- **THEN** la présence ou l'absence de l'entrée système exacte est affichée
- **AND** le chemin canonique et la portée système sont identifiés
- **AND** la configuration safe.directory est conservée

### Requirement: Préservation de la configuration de confiance par status

Cette commande MUST NOT modifier safe.directory, y compris via ses replis
de configuration locale. Une erreur de lecture MUST être distinguée d'une
absence et MUST provoquer un échec explicite.

#### Scenario: Configuration projet incomplète

- **GIVEN** un repli de configuration locale nécessaire au statut
- **WHEN** le statut complète la configuration du projet
- **THEN** aucun ajout safe.directory n'est effectué

#### Scenario: Lecture système en erreur

- **WHEN** la configuration Git système ne peut pas être lue correctement
- **THEN** un diagnostic d'erreur est affiché et la commande échoue
- **AND** aucune absence d'exception n'est annoncée comme un résultat valide
