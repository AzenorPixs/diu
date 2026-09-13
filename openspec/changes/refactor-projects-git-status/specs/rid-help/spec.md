## ADDED Requirements

### Requirement: Aide de la commande de statut Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git status <ID PROJECTS>` et ne SHALL pas présenter
`rid projects gits <ID PROJECTS>`. L'aide `rid projects git help` SHALL
présenter la sous-commande `status`. L'aide
`rid projects git status help` SHALL présenter la commande terminale
correspondante avec sa description.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git status <ID PROJECTS>`
- **AND THEN** l'aide n'affiche pas `rid projects gits <ID PROJECTS>`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git status <ID PROJECTS>`

#### Scenario: Aide de la commande de statut

- **WHEN** l'utilisateur exécute `rid projects git status help`
- **THEN** l'aide affiche `rid projects git status <ID PROJECTS>`
