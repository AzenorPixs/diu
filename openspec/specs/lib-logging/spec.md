# Specification: lib-logging

Extraction des fonctions génériques de journalisation vers lib/logging.sh.

## Purpose

Définir les exigences relatives au fichier `lib/logging.sh` qui contiendra les
fonctions génériques d'affichage et de journalisation du DIU, conformément à
l'architecture cible définie dans `modular-architecture`.

## Requirements

### Requirement: Emplacement du fichier

Le fichier `lib/logging.sh` SHALL exister à la racine du répertoire `lib/`
du projet DIU.

#### Scenario: Fichier présent

WHEN le DIU est exécuté
THEN le fichier `lib/logging.sh` existe dans le répertoire `lib/`

### Requirement: Fonction print_title

Le fichier `lib/logging.sh` SHALL contenir la fonction `print_title`.

La fonction SHALL déclarer une variable locale `title` initialisée avec `$1`.

La fonction SHALL afficher les lignes suivantes sur la sortie standard, dans
cet ordre :

1. Une ligne vide (`echo ""`)
2. La chaîne `==========================================================` (58 caractères `=`)
3. Un espace suivi de la valeur de `${title}`
4. La chaîne `==========================================================` (58 caractères `=`)
5. Une ligne vide (`echo ""`)

#### Scenario: Affichage d'un titre

WHEN `print_title` est appelée avec un argument
THEN cinq lignes sont affichées sur la sortie standard
AND la première et la dernière lignes sont vides
AND les deuxième et quatrième lignes contiennent exactement 58 caractères `=`
AND la troisième ligne contient un espace suivi du titre

### Requirement: Fonction print_info

Le fichier `lib/logging.sh` SHALL contenir la fonction `print_info`.

La fonction SHALL afficher sur la sortie standard la chaîne `ℹ️` suivie de
deux espaces puis de la concaténation de tous les arguments positionnels (`$*`).

#### Scenario: Affichage d'un message d'information

WHEN `print_info` est appelée avec un ou plusieurs arguments
THEN une seule ligne est affichée sur la sortie standard
AND la ligne commence par `ℹ️` suivi de deux espaces
AND la ligne se termine par la concaténation des arguments

### Requirement: Fonction print_success

Le fichier `lib/logging.sh` SHALL contenir la fonction `print_success`.

La fonction SHALL afficher sur la sortie standard la chaîne `✅` suivie d'un
espace puis de la concaténation de tous les arguments positionnels (`$*`).

#### Scenario: Affichage d'un message de succès

WHEN `print_success` est appelée avec un ou plusieurs arguments
THEN une seule ligne est affichée sur la sortie standard
AND la ligne commence par `✅` suivi d'un espace
AND la ligne se termine par la concaténation des arguments

### Requirement: Fonction print_error

Le fichier `lib/logging.sh` SHALL contenir la fonction `print_error`.

La fonction SHALL afficher sur la sortie d'erreur (`stderr`) la chaîne `❌`
suivie d'un espace puis de la concaténation de tous les arguments positionnels
(`$*`).

#### Scenario: Affichage d'un message d'erreur

WHEN `print_error` est appelée avec un ou plusieurs arguments
THEN une seule ligne est affichée sur la sortie d'erreur
AND la ligne commence par `❌` suivi d'un espace
AND la ligne se termine par la concaténation des arguments

### Requirement: Sourcing du fichier

Le fichier `root-install-debian.sh` SHALL sourcer `lib/logging.sh` via la
ligne `. "$BASH_SCRIPT_PATH/lib/logging.sh"`.

Ce sourcing SHALL être réalisé après le sourcing de `variables.sh` et avant
tout appel aux fonctions `print_title`, `print_info`, `print_success` ou
`print_error`.

#### Scenario: Ordre de sourcing

WHEN `root-install-debian.sh` est exécuté
THEN `variables.sh` est sourcé avant `lib/logging.sh`
AND `lib/logging.sh` est sourcé avant tout appel aux quatre fonctions

### Requirement: Compatibilité des appelants

Tous les appelants existants de `print_title`, `print_info`, `print_success`
et `print_error` dans `root-install-debian.sh` SHALL continuer à fonctionner
de manière identique après l'extraction.

#### Scenario: Appelants préservés

WHEN les fonctions sont extraites vers `lib/logging.sh` et sourcées depuis
`root-install-debian.sh`
THEN tous les appelants existants produisent le même résultat
AND aucun message d'erreur n'est généré

### Requirement: Non-régression du comportement

Le comportement des quatre fonctions après extraction SHALL être strictement
identique à leur comportement avant extraction.

#### Scenario: Identité fonctionnelle

WHEN les fonctions sont appelées après extraction
THEN chaque fonction produit une sortie identique à la sortie produite avant
extraction, caractère pour caractère
