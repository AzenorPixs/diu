# projects-git-status Specification

## Purpose
Fournir une commande publique cohérente pour afficher le statut Git local
d'un projet depuis le sous-contexte des opérations Git.

## Requirements

### Requirement: Statut Git d'un projet

DIU SHALL accepter `rid projects git status <ID PROJECTS>` pour afficher le
statut Git local du projet désigné. DIU SHALL NOT accepter
`rid projects gits <ID PROJECTS>` comme alias de cette commande.

#### Scenario: Statut Git sous le contexte Git

- **WHEN** l'utilisateur exécute
  `rid projects git status <ID PROJECTS>`
- **THEN** DIU exécute l'affichage du statut Git local du projet désigné

#### Scenario: Ancienne commande retirée

- **WHEN** l'utilisateur exécute `rid projects gits <ID PROJECTS>`
- **THEN** DIU ne l'interprète pas comme une commande de statut Git
