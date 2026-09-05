# Aide contextuelle rid

### Requirement: Raccourci racine

Le DIU SHALL accepter `rid ?` comme aide racine et SHALL présenter les
premières classes de commande disponibles avec une description concise.

#### Scenario: Aide racine

- **WHEN** l'utilisateur exécute `rid ?`
- **THEN** le DIU affiche les classes `devops`, `docker`, `ia`, `os`, `proj`,
  `install`, `remove`, `update`, `system` et `version`

### Requirement: Aide contextuelle

Le DIU SHALL accepter `rid <commande> ?` et `rid <commande> <sous-commande> ?`
et SHALL afficher uniquement les sous-commandes valides du contexte demandé.

#### Scenario: Aide system

- **WHEN** l'utilisateur exécute `rid system ?`
- **THEN** le DIU affiche les actions `install`, `remove`, `update` et `apt`

#### Scenario: Aide imbriquée

- **WHEN** l'utilisateur exécute `rid system install ?`
- **THEN** le DIU affiche la sous-commande `apt` et son paramètre dépôt

### Requirement: Compatibilité et concision

`rid help`, `rid --help` et `rid -h` SHALL rester acceptés comme alias de
l'aide racine. Chaque description d'entrée SHALL tenir sur une demi-ligne.

### Requirement: Extension

Toute nouvelle commande SHALL ajouter son entrée aux niveaux d'aide
correspondants.

