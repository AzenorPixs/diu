# Specification: project-bash

Création d'un projet Bash via la commande DIU `rid proj bash`.

## Purpose

La commande `rid proj bash <project_id> <project_name>` crée un projet sous le
répertoire racine des projets DevOps (`$DEVOPS_PROJECTS_ROOT`), initialisé avec
l'arborescence OpenCode et OpenSpec, un fichier AGENTS.md personnalisé, une licence,
et un fichier README.md personalisé.

## Requirements

### Requirement: Refus de création sur projet existant

Le DIU SHALL refuser de créer un projet si son chemin cible existe déjà.

Le DIU SHALL informer l'utilisateur sans effectuer aucune modification.

#### Scenario: Le projet existe déjà

WHEN le DIU crée un projet dont le chemin cible existe déjà
THEN le DIU affiche un message d'erreur
AND le DIU ne crée aucun fichier ni répertoire
AND le DIU se termine avec le code 1

### Requirement: Vérification des prérequis utilisateur

Le DIU SHALL vérifier que l'utilisateur système et le groupe cible existent
avant de procéder à la création du projet. En cas d'absence, le DIU SHALL
refuser la création.

#### Scenario: L'utilisateur DevOps n'existe pas

WHEN l'utilisateur système cible n'existe pas
THEN le DIU affiche un message d'erreur
AND le DIU se termine avec le code 1

#### Scenario: Le groupe DevOps n'existe pas

WHEN le groupe cible n'existe pas
THEN le DIU affiche un message d'erreur
AND le DIU se termine avec le code 1

### Requirement: Création de l'arborescence du projet

Le DIU SHALL créer les répertoires et fichiers suivants lors de la création
d'un projet :

- les répertoires de cache, configuration, partage, état et compétences d'OpenCode ;
- les répertoires de spécifications et de changements OpenSpec ;
- le fichier de configuration d'OpenCode (`opencode.json`) ;
- les fichiers d'état initiaux d'OpenCode ;
- les fichiers `.gitignore` (racine et `.opencode/`) ;
- le fichier `AGENTS.md` personnalisé avec le nom et le chemin du projet ;
- le fichier `LICENSE` ;
- le fichier `README.md` contenant le nom du projet.

#### Scenario: Arborescence créée avec succès

WHEN le DIU crée un projet dont le chemin n'existe pas
THEN un répertoire racine du projet est créé
AND l'arborescence OpenCode est présente (cache, config, share, state, skills, commands)
AND l'arborescence OpenSpec est présente (openspec/)
AND le fichier .opencode/config/opencode.json existe
AND le fichier .opencode/state/kv.json existe
AND le fichier .gitignore existe à la racine
AND le fichier AGENTS.md existe à la racine
AND le fichier LICENSE existe à la racine
AND le fichier README.md existe à la racine

### Requirement: Authentification OpenRouter

Lorsque la variable `API_OPENROUTER_KEY` est définie et différente de `"NONE"`,
le DIU SHALL créer un fichier d'authentification OpenCode contenant cette clé.

#### Scenario: Clé API définie

WHEN la variable API_OPENROUTER_KEY est définie et différente de "NONE"
THEN un fichier d'authentification OpenCode est créé
AND le fichier contient la clé API OpenRouter

#### Scenario: Clé API à NONE

WHEN la variable API_OPENROUTER_KEY vaut "NONE"
THEN aucun fichier d'authentification n'est créé

### Requirement: Cas spécial projet DIU

Lorsque le nom du projet contient la chaîne `"DIU"`, le DIU SHALL recopier les
fichiers de référence de l'installeur dans le projet et créer un répertoire
`deb/`.

#### Scenario: Projet DIU

WHEN le nom du projet contient "DIU"
THEN le fichier root-install-debian.sh est copié dans le projet
AND le fichier variables.sh est copié dans le projet
AND le répertoire deb/ est créé dans le projet

#### Scenario: Projet non-DIU

WHEN le nom du projet ne contient pas "DIU"
THEN aucun fichier n'est copié depuis la racine du DIU
AND le répertoire deb/ n'est pas créé

### Requirement: Initialisation OpenSpec

Le DIU SHALL initialiser OpenSpec dans le projet.

Si la commande `openspec` n'est pas disponible pour l'utilisateur cible, le
DIU SHALL refuser la création du projet.

#### Scenario: OpenSpec initialisé avec succès

WHEN le DIU initialise OpenSpec
THEN la commande openspec init est exécutée dans le projet
AND le répertoire openspec/changes/archive/ est créé
AND le répertoire openspec/specs/ est créé

#### Scenario: OpenSpec non installé

WHEN la commande openspec n'est pas disponible pour l'utilisateur cible
THEN le DIU affiche un message d'erreur
AND le DIU se termine avec le code 1

### Requirement: Propriété du projet

Le DIU SHALL affecter l'ensemble des fichiers et répertoires du projet à
l'utilisateur et au groupe cibles.

#### Scenario: Propriétaire appliqué

WHEN la création du projet est terminée
THEN tous les fichiers et répertoires du projet sont possédés par l'utilisateur et le groupe cibles

### Requirement: Finalisation de la création

Le DIU SHALL afficher un message de succès et l'arborescence du projet après
une création réussie.

Le DIU SHALL se terminer sans poursuivre l'installation Debian linéaire.

#### Scenario: Création réussie

WHEN la création du projet est terminée sans erreur
THEN le DIU affiche un message de succès avec le nom du projet
AND le DIU affiche l'arborescence du projet
AND le DIU se termine avec le code 0
AND le DIU ne poursuit pas l'installation Debian linéaire

### Requirement: Personnalisation de l'AGENTS.md

Le DIU SHALL générer un fichier AGENTS.md contenant le nom et le chemin du
projet interpolés dans les sections d'en-tête.

#### Scenario: AGENTS.md personnalisé

WHEN le fichier AGENTS.md est généré
THEN il contient le nom du projet dans son en-tête
AND il contient le chemin absolu du projet dans la section Emplacement
