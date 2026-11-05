# diu-help Specification

## Purpose
Définir une aide hiérarchique et sûre pour les commandes publiques `diu`, ainsi
qu'un diagnostic contextuel pour les chemins de commande inconnus.

## Requirements

### Requirement: Aide racine et contextuelle

DIU SHALL accepter `diu help`, `diu ?`, `diu <contexte> help` et
`diu <contexte> ?`. L'aide SHALL être disponible avant le chargement de la
configuration de production. Elle SHALL afficher les commandes immédiatement
disponibles au contexte demandé, chacune avec une description concise, et
SHALL utiliser un alignement lisible des descriptions.

#### Scenario: Aide d'un contexte intermédiaire

- **WHEN** l'utilisateur exécute `diu softwares help`
- **THEN** DIU affiche les commandes disponibles sous `diu softwares`, dont
  les commandes `install`, `remove`, `update` et `apt`
- **AND THEN** aucune configuration de production ni opération système n'est
  chargée ou exécutée

#### Scenario: Aide d'un contexte terminal

- **WHEN** l'utilisateur exécute `diu projects github push help`
- **THEN** DIU affiche la commande terminale correspondante et sa description
- **AND THEN** aucune opération de publication n'est exécutée

### Requirement: Erreur de routage contextuelle

Lorsqu'un chemin de commande contient un élément inconnu, DIU SHALL échouer
avec un code de retour non nul avant toute opération métier. Le diagnostic
SHALL identifier l'élément inconnu et proposer la commande `help` du dernier
contexte de routage reconnu. DIU SHALL NOT corriger ni exécuter implicitement
une autre commande.

#### Scenario: Élément inconnu à un niveau intermédiaire

- **WHEN** l'utilisateur exécute `diu softwares inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `diu softwares help`

#### Scenario: Élément inconnu à la racine

- **WHEN** l'utilisateur exécute `diu inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `diu help`

### Requirement: Retrait de l'usage global historique

DIU SHALL remplacer `display_usage()` par l'aide contextuelle. Aucun chemin de
routage ne SHALL appeler l'ancienne fonction d'usage global.

#### Scenario: Erreur de routage après migration

- **WHEN** une commande non reconnue atteint un gestionnaire de domaine
- **THEN** DIU affiche une aide contextuelle plutôt que l'usage global

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

#### Scenario: Commandes et descriptions des aides Git et projets

- **WHEN** une aide des opérations Git ou projets visées par cette exigence est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

L'aide `diu projects help` SHALL présenter
`diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`,
`diu projects git init <ID PROJECT>`, `diu projects git commit all`,
`diu projects forgejo push all`, `diu projects sync <ID PROJECT>`,
`diu projects sync all` et `diu projects git analyse <ID PROJECTS>`. L'aide
`diu projects clone help` SHALL présenter la commande de clonage avec une
description concise. L'aide `diu projects git commit help` SHALL présenter
`diu projects git commit all` avec une description. L'aide
`diu projects sync help` SHALL présenter les syntaxes unitaire et groupée
avec une description concise. L'aide `diu projects forgejo help` SHALL
présenter `push all` en complément des commandes unitaires. L'aide
`diu projects forgejo push help` SHALL présenter les syntaxes unitaire et
groupée. L'aide `diu projects git help` SHALL présenter les sous-commandes
`analyse`, `init` et `update`. Aucune de ces aides SHALL présenter
`diu projects giti <ID PROJECT>`, `diu projects gitu <ID PROJECT>` ni
`diu projects gita <ID PROJECT>`.

### Requirement: Aide de la commande de commit Git des projets

L'aide `diu projects help` SHALL présenter
`diu projects git commit <ID PROJECT> [COMMIT]` et ne SHALL pas présenter
`diu projects gitc <ID PROJECT> [COMMIT]`. L'aide `diu projects git help`
SHALL présenter la sous-commande `commit`. L'aide
`diu projects git commit help` SHALL présenter la commande terminale
correspondante avec sa description.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `diu projects help`
- **THEN** l'aide affiche `diu projects git commit <ID PROJECT> [COMMIT]`
- **AND THEN** l'aide n'affiche pas `diu projects gitc <ID PROJECT> [COMMIT]`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `diu projects git help`
- **THEN** l'aide affiche `diu projects git commit <ID PROJECT> [COMMIT]`

#### Scenario: Aide de la commande de commit

- **WHEN** l'utilisateur exécute `diu projects git commit help`
- **THEN** l'aide affiche `diu projects git commit <ID PROJECT> [COMMIT]`

### Requirement: Aide de la commande de statut Git des projets

L'aide `diu projects help` SHALL présenter
`diu projects git status <ID PROJECTS>` et ne SHALL pas présenter
`diu projects gits <ID PROJECTS>`. L'aide `diu projects git help` SHALL
présenter la sous-commande `status`. L'aide
`diu projects git status help` SHALL présenter la commande terminale
correspondante avec sa description.

#### Scenario: Aide du contexte projects

- **WHEN** l'utilisateur exécute `diu projects help`
- **THEN** l'aide affiche `diu projects git status <ID PROJECTS>`
- **AND THEN** l'aide n'affiche pas `diu projects gits <ID PROJECTS>`

#### Scenario: Aide du sous-contexte Git

- **WHEN** l'utilisateur exécute `diu projects git help`
- **THEN** l'aide affiche `diu projects git status <ID PROJECTS>`

#### Scenario: Aide de la commande de statut

- **WHEN** l'utilisateur exécute `diu projects git status help`
- **THEN** l'aide affiche `diu projects git status <ID PROJECTS>`

### Requirement: Aide des informations de modules

L'aide racine et contextuelle SHALL présenter diu infos, diu infos softwares, les commandes diu
<module> infos pour desktop, diu, environnements, ia, projects, softwares et
system, ainsi que diu system infos debian, diu system infos drivers et diu system infos network. Elle
SHALL rester disponible avant tout chargement de configuration de production.

#### Scenario: Aide terminale
- **WHEN** une nouvelle commande infos ou system infos est suivie de help ou ?
- **THEN** la syntaxe concernée et une description sont affichées sans opération métier

#### Scenario: Aide intermédiaire
- **WHEN** diu system help ou diu system infos help est appelée
- **THEN** les commandes d'information accessibles sont affichées

### Requirement: Aide des pilotes DisplayLink
L'aide SHALL exposer les commandes diu system drivers install displaylink et diu system drivers remove displaylink, à la racine, au niveau system, drivers, install/remove et displaylink, sans charger la configuration ni agir sur le système.

#### Scenario: Aide pilote
- **WHEN** help suit un préfixe valide des commandes DisplayLink
- **THEN** les commandes correspondantes sont affichées sans effet de bord

### Requirement: Aide de génération du modèle DevOps

Les aides template devops SHALL présenter les syntaxes individuelle et groupée, fonctionner avant le bootstrap sans génération et traiter les arguments invalides selon les scénarios.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Aide intermédiaire ou terminale

- **WHEN** help ou ? suit projects template, projects template devops ou projects template devops application
- **THEN** l'aide présente la nouvelle syntaxe avec l'identifiant de projet sans écriture

#### Scenario: Aide inconnue sous template

- **WHEN** un sélecteur inconnu, une ancienne syntaxe ou des arguments supplémentaires sont suivis de help
- **THEN** l'aide rend un code d'erreur et suggère le contexte template ou devops

#### Scenario: Aide de création

- **WHEN** l'utilisateur exécute diu projects create help
- **THEN** l'aide indique la création depuis le modèle et la génération finale de DEVOPS.md

#### Scenario: Aide du traitement groupé

- **WHEN** help ou ? suit projects template devops all
- **THEN** l'aide présente la génération pour tous les projets configurés avec les cinq variables requises
- **AND THEN** aucune configuration n'est chargée et aucun document n'est généré

#### Scenario: Découverte du traitement groupé

- **WHEN** l'utilisateur demande projects help, projects template help ou projects template devops help
- **THEN** l'aide présente les commandes individuelle et all

#### Scenario: Contrat détaillé des aides template devops

- **WHEN** une aide liée à la génération DevOps est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

L'aide diu projects help SHALL présenter diu projects template devops <ID PROJECT>
et diu projects template devops all. Les aides du contexte template, du
sélecteur devops et de la commande terminale SHALL fonctionner avec help et ?,
avant tout chargement de configuration et sans génération. Les arguments
surnuméraires, les chemins, les sélecteurs inconnus et les anciens contextes
par projet sans sélecteur SHALL être rejetés avec une aide contextuelle.
L'aide create SHALL préciser la génération finale de DEVOPS.md.

### Requirement: Aide du template OpenSpec

Les aides template openspec SHALL présenter les commandes et descriptions prévues, fonctionner sans mutation avant le bootstrap et conserver les autres aides et les règles de refus.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Découverte et aide terminale

- **WHEN** help ou ? suit projects, projects template, projects template openspec ou projects template openspec application
- **THEN** l'aide présente la commande OpenSpec appropriée sans charger la configuration

#### Scenario: Création avec OpenSpec

- **WHEN** l'utilisateur demande projects create help
- **THEN** l'aide indique OpenSpec avant la génération DEVOPS.md

#### Scenario: Arguments invalides

- **WHEN** une aide OpenSpec contient un chemin invalide, un argument supplémentaire ou la syntaxe projects template application openspec help
- **THEN** un code d'erreur et une aide contextuelle sont rendus sans effet de bord

#### Scenario: Aide groupée OpenSpec

- **WHEN** help ou ? suit projects template openspec all
- **THEN** l'aide présente les cinq variables requises, la poursuite après échec et le bilan, sans sélection ni génération

#### Scenario: Découverte du traitement OpenSpec groupé

- **WHEN** help ou ? suit projects, projects template ou projects template openspec
- **THEN** l'aide présente la commande openspec all pour tous les projets configurés

#### Scenario: Contrat détaillé des aides template openspec

- **WHEN** une aide liée au template OpenSpec est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Les aides projects et projects template SHALL présenter
`diu projects template openspec <ID PROJECT>` avec le libellé
« Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT> »
et `diu projects template openspec all` pour tous les projets configurés.
Les aides `projects template openspec` et `projects template openspec <ID PROJECT>`
SHALL fonctionner avec help et ? avant tout chargement de configuration et
sans mutation. L'aide spécifique individuelle SHALL expliquer init avec le
profil custom, le choix OPENCODE et update pour un dossier OpenSpec existant.
L'aide create SHALL préciser OpenSpec avant DevOps. Les aides DevOps SHALL
être conservées. Les arguments surnuméraires ou invalides et l'ancienne
syntaxe terminale qui ne correspond pas déjà à une commande valide SHALL
être rejetés avec une aide contextuelle.

### Requirement: Aide de tous les modèles pour tous les projets

Les aides template all all SHALL expliquer le traitement complet et fonctionner sans bootstrap ni mutation, en conservant les autres aides et les refus d’arguments prévus.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Découverte

- **WHEN** help ou ? suit projects ou projects template
- **THEN** l'aide présente la commande all all sans charger de configuration

#### Scenario: Aide du traitement complet

- **WHEN** help ou ? suit projects template all ou projects template all all
- **THEN** l'aide présente les sélecteurs, les critères et l'ordre par projet sans traitement

#### Scenario: Aide invalide

- **WHEN** un projet individuel suit all ou un argument supplémentaire suit all all avant help
- **THEN** l'aide rend un code non nul avec le contexte template all sans charger de configuration

#### Scenario: Contrat détaillé des aides template all all

- **WHEN** une aide du traitement de tous les modèles est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Les aides projects et projects template SHALL présenter
`diu projects template all all`. Les contextes projects template all et
projects template all all SHALL fonctionner avec help et ? avant tout
chargement de configuration et sans traitement. L'aide SHALL expliquer
les deux all, les cinq variables requises, OpenSpec puis DevOps en dernier
pour chaque projet, la poursuite sur les autres projets après échec et le
bilan. Elle SHALL préciser qu'un échec OpenSpec empêche DevOps sur ce projet.
Les cibles individuelles après all et arguments supplémentaires SHALL être
rejetés avec une aide contextuelle. Les aides existantes SHALL être conservées.

### Requirement: Aide de la mise à jour générale des projets

Les aides projects update SHALL distinguer les parcours général et ciblé, fonctionner sans opération avant le bootstrap et préserver les autres aides avec leurs refus d’arguments.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Découverte et contexte général

- **WHEN** help ou ? suit projects ou projects update
- **THEN** l'aide présente les deux usages sans charger la configuration

#### Scenario: Aide ciblée

- **WHEN** help ou ? suit projects update application ou projects update all
- **THEN** l'aide décrit la modification des variables du projet ciblé sans appeler de modèle

#### Scenario: Aide globale

- **WHEN** l'utilisateur demande diu update help ou diu update ?
- **THEN** l'aide indique la mise à jour générale des projets sans opération

#### Scenario: Arguments d'aide supplémentaires

- **WHEN** un argument supplémentaire suit l'identifiant avant help
- **THEN** l'aide rend un code non nul sans configuration ni écriture

#### Scenario: Contrat détaillé des aides projects update

- **WHEN** une aide de mise à jour des projets est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

L'aide projects SHALL présenter diu projects update et conserver diu projects
update <ID PROJECT>. Les contextes projects update et projects update
<ID PROJECT> SHALL fonctionner avec help et ? avant tout chargement de
configuration et sans opération. L'aide générale SHALL indiquer tous les
modèles de tous les projets configurés, OpenSpec puis DevOps en dernier.
L'aide ciblée SHALL expliquer la mise à jour des variables du seul projet.
L'aide diu update SHALL indiquer l'inclusion de la mise à jour générale des
projets. Les arguments d'aide supplémentaires SHALL être refusés avec un
diagnostic contextuel et les aides existantes SHALL être préservées.

### Requirement: Aide des exceptions système Git

L'aide des commandes `diu projects git init`, `update` et `status` MUST
mentionner respectivement l'enregistrement de l'exception système et
l'affichage de son état. Les signatures des commandes MUST rester inchangées.

#### Scenario: Consultation de l'aide Git

- **WHEN** l'aide projects, projects git ou projects git status est demandée
- **THEN** les descriptions concernées mentionnent safe.directory système
- **AND** les commandes conservent leurs arguments publics existants

### Requirement: Aide du packaging Debian DIU

Les aides SHALL présenter diu projects deb [ID PROJECT] et diu proj deb <ID PROJECT>, le défaut diu et la nature DIU des sources. help et ? SHALL fonctionner avant le bootstrap, sans construction ni configuration.

#### Scenario: Aide packaging sans effet

- **WHEN** une aide des deux syntaxes est demandée
- **THEN** elle explique la source et le défaut sans appeler le builder

### Requirement: Aide du build Debian générique

Les aides SHALL présenter diu projects build debian <ID PROJECT> et l'alias deb,
PROJECT_DEBIAN_PACKAGE avec Yes/YES/1 et la recette build/debian-package.json.
Les aides build, build debian et build deb, avec ou sans projet, SHALL rester
disponibles avant bootstrap sans construction ni lecture de configuration.

#### Scenario: Aide contextuelle
- **WHEN** l'aide de projects build, projects build deb ou projects build deb diu est demandée
- **THEN** elle présente les syntaxes et le contrat sans construction ni chargement de configuration

#### Scenario: aides des deux syntaxes
- **WHEN** help ou ? est demandé pour build, build debian ou build deb
- **THEN** la syntaxe canonique et l'alias sont expliqués sans effet de bord

### Requirement: Aide de la version prioritaire
Les aides de commit, push, CICD et builds Debian/Docker SHALL décrire PROJECT_VERSION, son format x.y.z, sa priorité et la conservation des mécanismes antérieurs en absence de clé. Elles SHALL rester disponibles avant bootstrap.

#### Scenario: Aide sans configuration
- **WHEN** une aide des opérations concernées est demandée
- **THEN** elle présente le contrat de version sans lire project.env ni lancer d'opération

### Requirement: Aide des publications GitHub Docker et Debian
Les aides GitHub release et CI/CD SHALL décrire Docker seul, Debian seul et le parcours mixte, les indicateurs Yes/YES/1 et la publication de paquets déjà construits selon les conditions Forgejo, sans exécuter le flux.

#### Scenario: Aide avant bootstrap
- **WHEN** help ou ? est demandé pour projects github ou projects github release
- **THEN** les deux types d'artefacts et leur activation sont présentés sans lecture de configuration

### Requirement: Aide de la séparation des mises à jour
Les aides SHALL indiquer que `diu update` ne lance pas `diu softwares update` et SHALL présenter cette dernière commande comme disponible séparément.

#### Scenario: Aide de mise à jour
- **WHEN** l'utilisateur demande l'aide de `diu update` ou de `diu softwares update`
- **THEN** l'aide décrit la séparation et la commande directe sans exécuter de mise à jour
