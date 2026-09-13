## MODIFIED Requirements

### Requirement: Aide de l'initialisation Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git init <ID PROJECT>`, `rid projects commit all`,
`rid projects forgejo push all` et `rid projects sync <ID PROJECT>`. L'aide
`rid projects sync help` SHALL présenter la commande de synchronisation avec
une description concise. L'aide `rid projects forgejo help` SHALL présenter
`push all` en complément des commandes unitaires. L'aide
`rid projects forgejo push help` SHALL présenter les syntaxes unitaire et
groupée. L'aide `rid projects git help` SHALL présenter les sous-commandes
`init` et `update`. Aucune de ces aides SHALL présenter
`rid projects giti <ID PROJECT>` ni `rid projects gitu <ID PROJECT>`.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects giti <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`
- **AND THEN** l'aide n'affiche pas `rid projects gitu <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects forgejo push all`
- **AND THEN** l'aide affiche `rid projects sync <ID PROJECT>`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git init <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects git update <ID PROJECT>`

#### Scenario: aide de publication Forgejo groupée

- **WHEN** l'utilisateur exécute `rid projects forgejo push help`
- **THEN** l'aide affiche `rid projects forgejo push <ID PROJECT>`
- **AND THEN** l'aide affiche `rid projects forgejo push all`

#### Scenario: Aide de synchronisation d'un projet

- **WHEN** l'utilisateur exécute `rid projects sync help`
- **THEN** l'aide affiche `rid projects sync <ID PROJECT>`
