# Tasks: Extraire les fonctions de journalisation vers lib/logging.sh

## Tâche 1 : Créer le répertoire lib/

Créer le répertoire `lib/` à la racine du projet, conformément à l'architecture
cible définie dans `define-modular-architecture`.

- Créer `/workspace/lib/`

**Livrable :** Répertoire `lib/` existant

## Tâche 2 : Créer lib/logging.sh

Créer le fichier `lib/logging.sh` contenant les 4 fonctions extraites de
`root-install-debian.sh` :

- `print_title` — titre de section (5 lignes : vide, 58 `=`, titre, 58 `=`, vide)
- `print_info` — message d'information avec préfixe `ℹ️` + deux espaces
- `print_success` — message de succès avec préfixe `✅` + un espace
- `print_error` — message d'erreur sur stderr avec préfixe `❌` + un espace

Les fonctions doivent être copiées exactement, sans modification de leur
comportement.

**Livrable :** Fichier `lib/logging.sh` contenant les 4 fonctions

## Tâche 3 : Modifier root-install-debian.sh

Modifier `root-install-debian.sh` pour :

1. Ajouter le sourcing de `lib/logging.sh` après le sourcing de `variables.sh` :
   ```bash
   . "$BASH_SCRIPT_PATH/lib/logging.sh"
   ```

2. Supprimer les 4 fonctions de leurs emplacements actuels

**Livrable :** `root-install-debian.sh` modifié avec sourcing et suppression

## Tâche 4 : Vérifications

### 4.1 Validation syntaxique

Exécuter `bash -n` sur les deux fichiers modifiés :

- `bash -n root-install-debian.sh`
- `bash -n lib/logging.sh`

Aucune erreur de syntaxe ne doit être signalée.

### 4.2 Vérification de présence dans lib/logging.sh

Vérifier que les 4 fonctions sont présentes dans `lib/logging.sh` :

- `print_title`
- `print_info`
- `print_success`
- `print_error`

### 4.3 Vérification d'absence dans root-install-debian.sh

Vérifier que les 4 fonctions sont absentes de `root-install-debian.sh` et que
seule la ligne de sourcing est ajoutée.

### 4.4 Vérification du sourcing

Vérifier que `root-install-debian.sh` contient la ligne :

```bash
. "$BASH_SCRIPT_PATH/lib/logging.sh"
```

placée après le sourcing de `variables.sh` et avant tout appel aux quatre
fonctions.

### 4.5 Vérification d'absence de modifications hors périmètre

Vérifier qu'aucune autre modification n'a été introduite dans
`root-install-debian.sh` (pas de reformatage, pas de suppression de commentaires,
pas de modification de variables, pas de changement d'ordre des instructions).

Utiliser `git diff` comme référence de l'état précédent le refactoring.
Seules les suppressions des quatre fonctions et l'ajout de la ligne de sourcing
sont attendus.

### 4.6 Vérification de non-régression du comportement

Comparer la sortie des 4 fonctions avant et après extraction :

1. Capturer la sortie de chaque fonction avec des arguments de test avant
   modification (référence Git)
2. Appliquer les modifications
3. Capturer la sortie de chaque fonction avec les mêmes arguments après
   extraction
4. Vérifier que les sorties sont strictement identiques (stdout et stderr)

Cette vérification confirme que le comportement des quatre fonctions après
extraction reste strictement identique à leur comportement avant extraction.

**Livrable :** Toutes les vérifications passées avec succès
