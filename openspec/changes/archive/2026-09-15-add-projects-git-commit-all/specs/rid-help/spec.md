## MODIFIED Requirements

### Requirement: Aide de l'initialisation Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git init <ID PROJECT>` comme commande d'initialisation Git et
`rid projects git commit all` comme commande de commit local groupé. L'aide
`rid projects git commit help` SHALL présenter `rid projects git commit all` avec une
description. L'aide `rid projects git help` SHALL présenter les sous-commandes
`init` et `update`. Aucune de ces aides SHALL présenter
`rid projects giti <ID PROJECT>` ni `rid projects gitu <ID PROJECT>`.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects giti <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects gitu <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git commit all`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git commit all`

#### Scenario: Aide du commit groupé

- **WHEN** l'utilisateur exécute `rid projects git commit help`
- **THEN** l'aide affiche `rid projects git commit all`

#### Scenario: aide de publication Forgejo groupée

- **WHEN** l'utilisateur exécute `rid projects forgejo push help`
- **THEN** l'aide affiche `rid projects forgejo push <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects forgejo push all`
