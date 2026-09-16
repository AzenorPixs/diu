## ADDED Requirements

### Requirement: Aide de la commande de commit Git des projets

L'aide `rid projects help` SHALL présenter
`rid projects git commit <ID PROJECT> [COMMIT]` et ne SHALL pas présenter
`rid projects gitc <ID PROJECT> [COMMIT]`. L'aide `rid projects git help`
SHALL présenter la sous-commande `commit`. L'aide
`rid projects git commit help` SHALL présenter la commande terminale
correspondante avec sa description.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `rid projects help`
- **THEN** l'aide affiche `rid projects git commit <ID PROJECT> [COMMIT]`
- **AND THEN** l'aide n'affiche pas `rid projects gitc <ID PROJECT> [COMMIT]`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `rid projects git help`
- **THEN** l'aide affiche `rid projects git commit <ID PROJECT> [COMMIT]`

#### Scenario: Aide de la commande de commit

- **WHEN** l'utilisateur exécute `rid projects git commit help`
- **THEN** l'aide affiche `rid projects git commit <ID PROJECT> [COMMIT]`
