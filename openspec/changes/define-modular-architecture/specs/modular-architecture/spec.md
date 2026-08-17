# Specification: modular-architecture

Architecture cible modulaire du DIU.

## Purpose

Définir la structure de répertoires cible du DIU et le rôle général de ses
composants, afin de guider progressivement la séparation fonctionnelle du projet.

## Architecture Cible

L'architecture cible du projet DIU est la suivante :

    /workspace/
    ├── config/
    ├── deb/
    ├── lib/
    │   ├── logging.sh
    │   ├── filesystem.sh
    │   ├── network.sh
    │   ├── packages.sh
    │   └── utils.sh
    ├── modules/
    │   ├── desktop/
    │   ├── environments/
    │   ├── projects/
    │   ├── softwares/
    │   └── system/
    ├── root-install-debian.sh
    └── variables.sh

L'organisation cible du répertoire `modules/` est :

    modules/
    ├── desktop/
    │   ├── gnome.sh
    │   └── applications.sh
    ├── environments/
    │   ├── docker.sh
    │   ├── devops.sh
    │   └── proxmox.sh
    ├── projects/
    │   ├── bash.sh
    │   ├── git.sh
    │   ├── forgejo.sh
    │   ├── opencode.sh
    │   └── openspec.sh
    ├── softwares/
    │   ├── vscode.sh
    │   ├── geany.sh
    │   └── syncthing.sh
    └── system/
        ├── apt.sh
        ├── locale.sh
        ├── users.sh
        ├── network.sh
        └── security.sh

## ADDED Requirements

### Requirement: Point d'entrée principal

Le fichier `root-install-debian.sh` SHALL rester le point d'entrée principal du DIU.

#### Scenario: Exécution du DIU

WHEN le DIU est exécuté
THEN `root-install-debian.sh` est le script invoqué

### Requirement: Emplacement de variables.sh

Le fichier `variables.sh` SHALL rester à la racine du projet tant qu'une évolution
ultérieure ne spécifie pas explicitement son déplacement ou sa réorganisation.

#### Scenario: Variables de configuration

WHEN le DIU est exécuté
THEN `variables.sh` est situé à la racine du projet

### Requirement: Rôle du répertoire lib/

Le répertoire `lib/` SHALL contenir les fonctions génériques et réutilisables
communes aux différents domaines du DIU.

Les fichiers présents dans `lib/` sont :

- `logging.sh` : fonctions de journalisation et d'affichage
- `filesystem.sh` : fonctions de manipulation de fichiers et répertoires
- `network.sh` : fonctions réseau génériques
- `packages.sh` : fonctions de gestion de paquets
- `utils.sh` : fonctions utilitaires transverses

#### Scenario: Fonctions communes

WHEN une fonction générique est utilisée par plusieurs domaines
THEN elle est placée dans le fichier `lib/` correspondant à sa responsabilité

### Requirement: Rôle du répertoire modules/

Le répertoire `modules/` SHALL contenir les principaux domaines fonctionnels du DIU,
organisés par sous-répertoire.

Les domaines fonctionnels sont :

- `desktop/` : environnement de bureau (gnome, applications)
- `environments/` : environnements d'exécution (docker, devops, proxmox)
- `projects/` : gestion de projets (bash, git, forgejo, opencode, openspec)
- `softwares/` : installation de logiciels (vscode, geany, syncthing)
- `system/` : configuration système (apt, locale, utilisateurs, réseau, sécurité)

#### Scenario: Domaines fonctionnels

WHEN une fonctionnalité du DIU est associée à un domaine fonctionnel
THEN elle est placée dans le sous-répertoire `modules/` correspondant

### Requirement: Caractère progressif de la migration

La migration vers l'architecture cible SHALL être réalisée progressivement, par
changements limités et cohérents.

Chaque étape de migration SHALL faire l'objet d'un changement OpenSpec limité et
explicitement validé par le développeur. Une étape peut concerner une partie
seulement d'un futur module.

#### Scenario: Changements limités et cohérents

WHEN une étape de migration est planifiée
THEN un changement OpenSpec distinct est créé pour cette étape
AND le changement est limité à un ensemble cohérent de modifications
AND le changement est validé par le développeur avant implémentation

### Requirement: Préservation du comportement existant

Aucune migration SHALL modifier le comportement fonctionnel du DIU.

Les commandes existantes (`rid <classe> <action> <variable>`) SHALL conserver
un comportement identique après chaque migration.

Les commits réalisés pendant chaque étape de migration SHALL rester atomiques
et respecter les règles définies dans `AGENTS.md`.

#### Scenario: Compatibilité fonctionnelle

WHEN une étape de migration vers l'architecture cible est réalisée
THEN le comportement fonctionnel du DIU est préservé
AND les commandes existantes produisent le même résultat

### Requirement: Architecture imposée

L'architecture cible définie dans cette spécification est une décision du développeur.

Les répertoires et fichiers explicitement présents dans cette architecture SHALL NOT
être remplacés par une architecture alternative.

Aucun répertoire ou fichier supplémentaire ne SHALL être ajouté en dehors de cette
architecture cible sans validation explicite du développeur.

#### Scenario: Respect de l'architecture

WHEN un refactoring est planifié
THEN il respecte l'architecture cible définie dans cette spécification
AND aucun élément supplémentaire n'est ajouté sans validation
