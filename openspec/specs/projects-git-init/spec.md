# projects-git-init Specification

## Purpose
Définir la commande publique canonique pour initialiser le dépôt Git local
d'un projet sans conserver une abréviation historique ambiguë.

## Requirements

### Requirement: Initialisation Git sous le sous-contexte projects git

DIU MUST exposer l'initialisation d'un dépôt Git local par la commande
`rid projects git init <ID PROJECT>`. Cette commande MUST initialiser le
dépôt du projet désigné. La commande historique
`rid projects giti <ID PROJECT>` MUST NOT être reconnue comme une commande
publique valide.

#### Scenario: Initialisation avec la commande canonique

- **WHEN** l'utilisateur exécute `rid projects git init diu`
- **THEN** DIU initialise le dépôt Git local du projet `diu`

#### Scenario: Rejet de la commande historique

- **WHEN** l'utilisateur exécute `rid projects giti diu`
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune initialisation Git n'est exécutée
