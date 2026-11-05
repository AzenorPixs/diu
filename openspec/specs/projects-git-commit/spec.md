# projects-git-commit Specification

## Purpose
Définir la commande publique canonique permettant de créer un commit dans le
dépôt Git local d'un projet géré par DIU.

## Requirements

### Requirement: Commit Git sous le sous-contexte projects git

DIU MUST exposer le commit d'un dépôt Git local par la commande
`diu projects git commit <ID PROJECT> [COMMIT]`. Lorsque le message facultatif
est absent, DIU MUST conserver la génération existante d'un nom et d'un tag de
commit par défaut. La commande historique `diu projects gitc <ID PROJECT>
[COMMIT]` MUST NOT être reconnue comme une commande publique valide.

#### Scenario: Commit avec la commande canonique

- **WHEN** l'utilisateur exécute `diu projects git commit diu publication`
- **THEN** DIU transmet le projet `diu` et le message `publication` à
  l'opération de commit Git locale

#### Scenario: Commit sans message explicite

- **WHEN** l'utilisateur exécute `diu projects git commit diu`
- **THEN** DIU crée les valeurs par défaut de nom et de tag de commit selon le
  comportement existant

#### Scenario: Rejet de la commande historique

- **WHEN** l'utilisateur exécute `diu projects gitc diu publication`
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune opération de commit Git n'est exécutée
