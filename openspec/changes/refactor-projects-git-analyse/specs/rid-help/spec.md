# rid-help Specification (delta)

## MODIFIED Requirements

### Requirement: Aide de l'initialisation Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git init <ID PROJECT>` comme commande d'initialisation Git et
`rid projects git analyse <ID PROJECTS>` comme commande d'analyse Git.
L'aide `rid projects git help` SHALL présenter les sous-commandes `analyse`,
`init` et `update`. Aucune de ces aides SHALL présenter
`rid projects giti <ID PROJECT>` ni `rid projects gita <ID PROJECT>`.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide n'affiche pas `rid projects gita <ID PROJECT>`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
