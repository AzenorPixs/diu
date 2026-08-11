# Proposal: Définir l'architecture cible modulaire du DIU

## Problem

Le DIU actuel concentre l'ensemble de ses fonctions dans un script monolithique
(`root-install-debian.sh`, 5000+ lignes) et un fichier de variables (`variables.sh`).
Cette structure ne permet pas une séparation claire des domaines fonctionnels.

## Proposed Change

Formaliser l'architecture cible modulaire du DIU telle qu'elle est décidée par le
développeur, sans modifier le code existant. Ce changement constitue une spécification
de référence qui guidera les futures itérations de refactoring, chacune faisant l'objet
d'un changement limité et explicitement validé.

## Scope

- Formaliser l'architecture cible (répertoires `lib/` et `modules/`)
- Définir le rôle général de chaque répertoire
- Documenter le caractère progressif de la migration
- Documenter la préservation du comportement existant
- Maintenir `root-install-debian.sh` comme point d'entrée principal
- Maintenir `variables.sh` à la racine

## Out of Scope

- Tout refactoring du code existant
- Tout changement fonctionnel
- Toute création physique de l'arborescence cible
- Toute définition détaillée du contenu des fichiers futurs
