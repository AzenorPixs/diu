# Specification: modular-architecture

## Purpose

Définir la structure de répertoires cible du DIU et le rôle général de ses
composants, afin de guider progressivement la séparation fonctionnelle du projet.

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
communes aux différents domaines du DIU. Sa composition évolue selon les
changements OpenSpec validés et reste cohérente avec le cadrage technique.

#### Scenario: Fonctions communes

WHEN une fonction générique est utilisée par plusieurs domaines
THEN elle est placée dans le fichier `lib/` correspondant à sa responsabilité

### Requirement: Rôle du répertoire modules/

Le répertoire `modules/` SHALL contenir les domaines fonctionnels du DIU,
organisés par sous-répertoire. Les domaines et fichiers effectivement présents
restent ceux documentés par le cadrage technique et les changements OpenSpec
validés.

#### Scenario: Domaines fonctionnels

WHEN une fonctionnalité du DIU est associée à un domaine fonctionnel
THEN elle est placée dans le sous-répertoire `modules/` correspondant

### Requirement: Caractère progressif de la migration

La migration vers l'architecture cible SHALL être réalisée progressivement, par
changements limités et cohérents.

Chaque étape de migration SHALL faire l'objet d'un changement OpenSpec limité et
explicitement validé par le développeur. Une étape MAY concerner une partie
seulement d'un futur module. Les commits réalisés pendant chaque étape SHALL
rester atomiques et respecter les règles définies dans `AGENTS.md`.

#### Scenario: Changements limités et cohérents

WHEN une étape de migration est planifiée
THEN un changement OpenSpec distinct est créé pour cette étape
AND le changement est limité à un ensemble cohérent de modifications
AND le changement est validé par le développeur avant implémentation

### Requirement: Préservation du comportement existant

Aucune migration SHALL modifier le comportement fonctionnel du DIU.

Les commandes existantes (`diu <classe> <action> <variable>`) SHALL conserver
un comportement identique après chaque migration.

Les commits réalisés pendant chaque étape de migration SHALL rester atomiques
et respecter les règles définies dans `AGENTS.md`.

#### Scenario: Compatibilité fonctionnelle

WHEN une étape de migration vers l'architecture cible est réalisée
THEN le comportement fonctionnel du DIU est préservé
AND les commandes existantes produisent le même résultat

### Requirement: Évolution de l'architecture

L'architecture modulaire est une décision du développeur. Toute évolution de
son arborescence SHALL être définie par un changement OpenSpec limité, validé
par le développeur et cohérent avec le cadrage technique.

#### Scenario: Respect de l'architecture

WHEN un refactoring est planifié
THEN il respecte les rôles définis par cette spécification et le cadrage technique
AND son arborescence est validée par le développeur
