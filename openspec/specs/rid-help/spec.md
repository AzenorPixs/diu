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
system, ainsi que rid system infos debian, rid system infos drivers et rid system infos network. Elle
SHALL rester disponible avant tout chargement de configuration de production.

#### Scenario: Aide terminale
- **WHEN** une nouvelle commande infos ou system infos est suivie de help ou ?
- **THEN** la syntaxe concernée et une description sont affichées sans opération métier

#### Scenario: Aide intermédiaire
- **WHEN** rid system help ou rid system infos help est appelée
- **THEN** les commandes d'information accessibles sont affichées

### Requirement: Aide des pilotes DisplayLink
L'aide SHALL exposer les commandes rid system drivers install displaylink et rid system drivers remove displaylink, à la racine, au niveau system, drivers, install/remove et displaylink, sans charger la configuration ni agir sur le système.

#### Scenario: Aide pilote
- **WHEN** help suit un préfixe valide des commandes DisplayLink
- **THEN** les commandes correspondantes sont affichées sans effet de bord

### Requirement: Aide de génération du modèle DevOps

L'aide rid projects help SHALL présenter rid projects template devops <ID PROJECT>
et rid projects template devops all. Les aides du contexte template, du
sélecteur devops et de la commande terminale SHALL fonctionner avec help et ?,
avant tout chargement de configuration et sans génération. Les arguments
surnuméraires, les chemins, les sélecteurs inconnus et les anciens contextes
par projet sans sélecteur SHALL être rejetés avec une aide contextuelle.
L'aide create SHALL préciser la génération finale de DEVOPS.md.

#### Scenario: Aide intermédiaire ou terminale

- **WHEN** help ou ? suit projects template, projects template devops ou projects template devops application
- **THEN** l'aide présente la nouvelle syntaxe avec l'identifiant de projet sans écriture

#### Scenario: Aide inconnue sous template

- **WHEN** un sélecteur inconnu, une ancienne syntaxe ou des arguments supplémentaires sont suivis de help
- **THEN** l'aide rend un code d'erreur et suggère le contexte template ou devops

#### Scenario: Aide de création

- **WHEN** l'utilisateur exécute rid projects create help
- **THEN** l'aide indique la création depuis le modèle et la génération finale de DEVOPS.md

#### Scenario: Aide du traitement groupé

- **WHEN** help ou ? suit projects template devops all
- **THEN** l'aide présente la génération pour tous les projets configurés avec les cinq variables requises
- **AND THEN** aucune configuration n'est chargée et aucun document n'est généré

#### Scenario: Découverte du traitement groupé

- **WHEN** l'utilisateur demande projects help, projects template help ou projects template devops help
- **THEN** l'aide présente les commandes individuelle et all

### Requirement: Aide du template OpenSpec

Les aides projects et projects template SHALL présenter
`rid projects template openspec <ID PROJECT>` avec le libellé
« Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT> ».
Les aides `projects template openspec` et `projects template openspec <ID PROJECT>`
SHALL fonctionner avec help et ? avant tout chargement de configuration et
sans mutation. L'aide spécifique SHALL expliquer init avec le profil custom,
le choix OPENCODE et update pour un dossier OpenSpec existant. L'aide create
SHALL préciser OpenSpec avant DevOps. Les aides DevOps individuelles et groupées
SHALL suivre `projects template devops <ID PROJECT>` et `projects template devops all` ;
openspec all SHALL décrire seulement le projet nommé all. Les arguments
surnuméraires ou invalides et l'ancienne syntaxe terminale qui ne correspond
pas déjà à une commande valide SHALL être rejetés avec une aide contextuelle.

#### Scenario: Découverte et aide terminale

- **WHEN** help ou ? suit projects, projects template, projects template openspec ou projects template openspec application
- **THEN** l'aide présente la nouvelle commande OpenSpec sans charger la configuration

#### Scenario: Création avec OpenSpec

- **WHEN** l'utilisateur demande projects create help
- **THEN** l'aide indique OpenSpec avant la génération DEVOPS.md

#### Scenario: Arguments invalides

- **WHEN** une aide OpenSpec contient un chemin invalide, un argument supplémentaire ou la syntaxe projects template application openspec help
- **THEN** un code d'erreur et une aide contextuelle sont rendus sans effet de bord
