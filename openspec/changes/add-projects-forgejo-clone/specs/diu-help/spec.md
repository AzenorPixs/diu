## MODIFIED Requirements

### Requirement: Aide de l'initialisation Git des projets

Les aides des opérations Git et projets SHALL présenter les commandes et descriptions détaillées ci-dessous, conserver les syntaxes groupées et exclure les anciens alias indiqués.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `diu projects help`
- **THEN** l'aide affiche `diu projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide n'affiche pas `diu projects gita <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects git init <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `diu projects giti <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects git update <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `diu projects gitu <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects git commit all`
- **AND THEN** l'aide affiche `diu projects forgejo push all`
- **AND THEN** l'aide affiche `diu projects forgejo clone <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects sync <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects sync all`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `diu projects git help`
- **THEN** l'aide affiche `diu projects git analyse <ID PROJECTS>`
- **AND THEN** l'aide affiche `diu projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects git update <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects git commit all`

#### Scenario: Aide du commit groupé

- **WHEN** l'utilisateur exécute `diu projects git commit help`
- **THEN** l'aide affiche `diu projects git commit all`

#### Scenario: aide de publication Forgejo groupée

- **WHEN** l'utilisateur exécute `diu projects forgejo push help`
- **THEN** l'aide affiche `diu projects forgejo push <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects forgejo push all`

#### Scenario: Aide de synchronisation des projets

- **WHEN** l'utilisateur exécute `diu projects sync help`
- **THEN** l'aide affiche `diu projects sync <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects sync all`

#### Scenario: Aide de synchronisation d'un projet

- **WHEN** l'utilisateur exécute `diu projects sync help`
- **THEN** l'aide affiche `diu projects sync <ID PROJECT>`

#### Scenario: Aide de clonage d'un projet

- **WHEN** l'utilisateur exécute `diu projects clone help`
- **THEN** l'aide affiche
  `diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`

#### Scenario: Aide Forgejo

- **WHEN** l'utilisateur exécute `diu projects forgejo help`
- **THEN** l'aide affiche `diu projects forgejo clone <ID PROJECT>`
- **AND THEN** l'aide affiche `diu projects forgejo push all`

#### Scenario: Aide du clonage Forgejo

- **WHEN** l'utilisateur exécute `diu projects forgejo clone help`
- **THEN** l'aide affiche `diu projects forgejo clone <ID PROJECT>`

#### Scenario: Commandes et descriptions des aides Git et projets

- **WHEN** une aide des opérations Git ou projets visées par cette exigence est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

L'aide `diu projects help` SHALL présenter
`diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`,
`diu projects git init <ID PROJECT>`, `diu projects git commit all`,
`diu projects forgejo clone <ID PROJECT>`,
`diu projects forgejo push all`, `diu projects sync <ID PROJECT>`,
`diu projects sync all` et `diu projects git analyse <ID PROJECTS>`. L'aide
`diu projects clone help` SHALL présenter la commande de clonage avec une
description concise. L'aide `diu projects git commit help` SHALL présenter
`diu projects git commit all` avec une description. L'aide
`diu projects sync help` SHALL présenter les syntaxes unitaire et groupée
avec une description concise. L'aide `diu projects forgejo help` SHALL
présenter `clone` et `push all` en complément des commandes unitaires. L'aide
`diu projects forgejo clone help` SHALL présenter la syntaxe de clonage avec
une description concise. L'aide
`diu projects forgejo push help` SHALL présenter les syntaxes unitaire et
groupée. L'aide `diu projects git help` SHALL présenter les sous-commandes
`analyse`, `init` et `update`. Aucune de ces aides SHALL présenter
`diu projects giti <ID PROJECT>`, `diu projects gitu <ID PROJECT>` ni
`diu projects gita <ID PROJECT>`.

