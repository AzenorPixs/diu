# Tasks: Extraire les fonctions de journalisation vers lib/logging.sh

## 1. Création du répertoire lib/

- [x] 1.1 Créer le répertoire `lib/` à la racine du projet, conformément à l'architecture cible définie dans `define-modular-architecture`

## 2. Création de lib/logging.sh

- [x] 2.1 Créer le fichier `lib/logging.sh` contenant les 4 fonctions extraites de `root-install-debian.sh` : `print_title`, `print_info`, `print_success`, `print_error`. Les fonctions doivent être copiées exactement, sans modification de leur comportement.

## 3. Modification de root-install-debian.sh

- [x] 3.1 Ajouter le sourcing de `lib/logging.sh` après le sourcing de `variables.sh` : `. "$BASH_SCRIPT_PATH/lib/logging.sh"`
- [x] 3.2 Supprimer les 4 fonctions de leurs emplacements actuels dans `root-install-debian.sh`

## 4. Vérifications

- [x] 4.1 Validation syntaxique : exécuter `bash -n` sur `root-install-debian.sh` et `lib/logging.sh`, aucune erreur ne doit être signalée
- [x] 4.2 Vérifier que les 4 fonctions (`print_title`, `print_info`, `print_success`, `print_error`) sont présentes dans `lib/logging.sh`
- [x] 4.3 Vérifier que les 4 fonctions sont absentes de `root-install-debian.sh` et que seule la ligne de sourcing est ajoutée
- [x] 4.4 Vérifier que `root-install-debian.sh` contient `. \"$BASH_SCRIPT_PATH/lib/logging.sh\"` placé après le sourcing de `variables.sh` et avant tout appel aux quatre fonctions
- [x] 4.5 Vérifier qu'aucune autre modification n'a été introduite dans `root-install-debian.sh` (pas de reformatage, pas de suppression de commentaires, pas de modification de variables). Utiliser `git diff` comme référence.
- [x] 4.6 Vérification de non-régression : comparer la sortie des 4 fonctions avant et après extraction pour confirmer que le comportement reste strictement identique (stdout et stderr)
