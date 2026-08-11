# Proposal: Extraire les fonctions de journalisation vers lib/logging.sh

## Problem

Le script principal `root-install-debian.sh` (12 093 lignes) concentre l'ensemble
des fonctions du DIU, y compris les fonctions génériques d'affichage et de
journalisation (`print_title`, `print_info`, `print_success`, `print_error`).
Ces fonctions sont utilisées par de nombreux appelants dans tout le script et
devraient logiquement résider dans `lib/logging.sh` selon l'architecture cible
définie par le changement `define-modular-architecture`.

## Proposed Change

Extraire les quatre fonctions génériques d'affichage de `root-install-debian.sh`
vers un nouveau fichier `lib/logging.sh`, puis les réintégrer via un appel à
`. "$BASH_SCRIPT_PATH/lib/logging.sh"`. Ce changement constitue la première
étape concrète de migration vers l'architecture modulaire cible.

## Scope

- Créer le répertoire `lib/`
- Créer le fichier `lib/logging.sh` contenant les 4 fonctions
- Supprimer ces fonctions de `root-install-debian.sh`
- Ajouter le sourcing de `lib/logging.sh` dans `root-install-debian.sh`
- Vérifier que le comportement fonctionnel est préservé

## Out of Scope

- Extraction de `error_handler` (reste dans le script principal)
- Extraction de `display_usage`, `display_infos`, `devops_info` (fonctions spécifiques)
- Toute modification fonctionnelle
- Création des autres fichiers `lib/` (`filesystem.sh`, `network.sh`, etc.)
- Création du répertoire `modules/`
