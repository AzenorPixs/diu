# rid-help Specification

## Purpose
Définir une aide hiérarchique et sûre pour les commandes publiques `rid`, ainsi
qu'un diagnostic contextuel pour les chemins de commande inconnus.

## Requirements

### Requirement: Aide racine et contextuelle

DIU SHALL accepter `rid help`, `rid ?`, `rid <contexte> help` et
`rid <contexte> ?`. L'aide SHALL être disponible avant le chargement de la
configuration de production. Elle SHALL afficher les commandes immédiatement
disponibles au contexte demandé, chacune avec une description concise, et
SHALL utiliser un alignement lisible des descriptions.

#### Scenario: Aide d'un contexte intermédiaire

- **WHEN** l'utilisateur exécute `rid softwares help`
- **THEN** DIU affiche les commandes disponibles sous `rid softwares`, dont
  les commandes `install`, `remove`, `update` et `apt`
- **AND THEN** aucune configuration de production ni opération système n'est
  chargée ou exécutée

#### Scenario: Aide d'un contexte terminal

- **WHEN** l'utilisateur exécute `rid projects github push help`
- **THEN** DIU affiche la commande terminale correspondante et sa description
- **AND THEN** aucune opération de publication n'est exécutée

### Requirement: Erreur de routage contextuelle

Lorsqu'un chemin de commande contient un élément inconnu, DIU SHALL échouer
avec un code de retour non nul avant toute opération métier. Le diagnostic
SHALL identifier l'élément inconnu et proposer la commande `help` du dernier
contexte de routage reconnu. DIU SHALL NOT corriger ni exécuter implicitement
une autre commande.

#### Scenario: Élément inconnu à un niveau intermédiaire

- **WHEN** l'utilisateur exécute `rid softwares inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `rid softwares help`

#### Scenario: Élément inconnu à la racine

- **WHEN** l'utilisateur exécute `rid inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `rid help`

### Requirement: Retrait de l'usage global historique

DIU SHALL remplacer `display_usage()` par l'aide contextuelle. Aucun chemin de
routage ne SHALL appeler l'ancienne fonction d'usage global.

#### Scenario: Erreur de routage après migration

- **WHEN** une commande non reconnue atteint un gestionnaire de domaine
- **THEN** DIU affiche une aide contextuelle plutôt que l'usage global

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

### Requirement: Aide des informations de modules

L'aide racine et contextuelle SHALL présenter rid infos, les commandes rid
<module> infos pour desktop, diu, environnements, ia, projects, softwares et
system, ainsi que rid system info network et rid system info debian. Elle
SHALL rester disponible avant tout chargement de configuration de production.

#### Scenario: Aide terminale
- **WHEN** une nouvelle commande infos ou system info est suivie de help ou ?
- **THEN** la syntaxe concernée et une description sont affichées sans opération métier

#### Scenario: Aide intermédiaire
- **WHEN** rid system help ou rid system info help est appelée
- **THEN** les commandes d'information accessibles sont affichées
