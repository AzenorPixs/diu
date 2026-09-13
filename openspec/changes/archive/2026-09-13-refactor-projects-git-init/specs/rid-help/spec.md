## ADDED Requirements

### Requirement: Aide de l'initialisation Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git init <ID PROJECT>` comme commande d'initialisation Git.
L'aide `rid projects git help` SHALL présenter les sous-commandes `init` et
`update`. Aucune de ces aides SHALL présenter
`rid projects giti <ID PROJECT>`.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects giti <ID PROJECT>`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
