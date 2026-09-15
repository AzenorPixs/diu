# rid-help Specification (delta)

## MODIFIED Requirements

### Requirement: Aide de l'initialisation Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`,
`rid projects git init <ID PROJECT>`, `rid projects git commit all`,
`rid projects forgejo push all`, `rid projects sync <ID PROJECT>`,
`rid projects sync all` et `rid projects git analyse <ID PROJECTS>`. L'aide
`rid projects clone help` SHALL présenter la commande de clonage avec une
description concise. L'aide `rid projects git commit help` SHALL présenter
`rid projects git commit all` avec une description. L'aide
`rid projects sync help` SHALL présenter les syntaxes unitaire et groupée
avec une description concise. L'aide `rid projects forgejo help` SHALL
présenter `push all` en complément des commandes unitaires. L'aide
`rid projects forgejo push help` SHALL présenter les syntaxes unitaire et
groupée. L'aide `rid projects git help` SHALL présenter les sous-commandes
`analyse`, `init` et `update`. Aucune de ces aides SHALL présenter
`rid projects giti <ID PROJECT>`, `rid projects gitu <ID PROJECT>` ni
`rid projects gita <ID PROJECT>`.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide n'affiche pas `rid projects gita <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects giti <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects gitu <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git commit all`
- **AND THEN** l'aide affiche `rid projects forgejo push all`
- **AND THEN** l'aide affiche `rid projects sync <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects sync all`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git commit all`

#### Scenario: Aide du commit groupé

- **WHEN** l'utilisateur exécute `rid projects git commit help`
- **THEN** l'aide affiche `rid projects git commit all`

#### Scenario: aide de publication Forgejo groupée

- **WHEN** l'utilisateur exécute `rid projects forgejo push help`
- **THEN** l'aide affiche `rid projects forgejo push <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects forgejo push all`

#### Scenario: Aide de synchronisation des projets

- **WHEN** l'utilisateur exécute `rid projects sync help`
- **THEN** l'aide affiche `rid projects sync <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects sync all`

#### Scenario: Aide de synchronisation d'un projet

- **WHEN** l'utilisateur exécute `rid projects sync help`
- **THEN** l'aide affiche `rid projects sync <ID PROJECT>`

#### Scenario: Aide de clonage d'un projet

- **WHEN** l'utilisateur exécute `rid projects clone help`
- **THEN** l'aide affiche
  `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`
