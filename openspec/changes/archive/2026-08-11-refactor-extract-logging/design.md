# Design: Extraction des fonctions de journalisation

## Context

Le DIU actuel est un script monolithique (`root-install-debian.sh`, 12 093 lignes).
L'architecture cible définie dans `define-modular-architecture` prévoit un
répertoire `lib/` contenant les fonctions génériques, dont `logging.sh` pour la
journalisation et l'affichage.

Ce changement constitue la première étape concrète de migration vers cette
architecture, limitée à l'extraction des 4 fonctions d'affichage génériques.

## Fonctions concernées

| Fonction | Rôle |
|---|---|
| `print_title` | Affiche un titre de section sous forme de cinq lignes (vide, séparateur de 58 `=`, titre avec espace préfixe, séparateur, vide) |
| `print_info` | Affiche un message d'information sur stdout avec préfixe `ℹ️` suivi de deux espaces |
| `print_success` | Affiche un message de succès sur stdout avec préfixe `✅` suivi d'un espace |
| `print_error` | Affiche un message d'erreur sur stderr avec préfixe `❌` suivi d'un espace |

## Approche

### 1. Création du répertoire `lib/`

Créer `/workspace/lib/` conformément à l'architecture cible.

### 2. Création de `lib/logging.sh`

Déplacer les 4 fonctions dans `lib/logging.sh` en conservant exactement leur
implémentation actuelle. Aucune modification fonctionnelle.

Le fichier commencera par un en-tête identifiant sa responsabilité.

### 3. Sourcing depuis `root-install-debian.sh`

Ajouter la ligne suivante après le sourcing de `variables.sh` :

```bash
. "$BASH_SCRIPT_PATH/lib/logging.sh"
```

### 4. Suppression des fonctions dans `root-install-debian.sh`

Supprimer les 4 fonctions de `root-install-debian.sh`.

## Contraintes respectées

- `root-install-debian.sh` reste le point d'entrée principal
- `variables.sh` reste à la racine
- Aucune modification fonctionnelle
- Les commits restent atomiques
- L'architecture cible est respectée
- `error_handler` reste dans `root-install-debian.sh` (hors périmètre)

## Risques et mitigations

| Risque | Mitigation |
|---|---|
| Ordre de sourcing incorrect | Le sourcing de `lib/logging.sh` est placé après `variables.sh` et avant tout appel aux fonctions |
| Fonctions manquantes après extraction | Vérification que les 4 fonctions sont bien présentes dans `lib/logging.sh` |
| Appelants cassés | Aucun changement dans la signature des fonctions ; vérification par `bash -n` et test de non-régression |

## Fichiers modifiés

- `root-install-debian.sh` : suppression des 4 fonctions + ajout du sourcing
- `lib/logging.sh` : nouveau fichier contenant les 4 fonctions
