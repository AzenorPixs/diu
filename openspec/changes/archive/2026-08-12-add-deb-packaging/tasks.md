## 1. Prérequis de configuration

- [x] 1.1 Déterminer la source du champ `Maintainer` : constante codée en
  dur dans `build_deb()` : `Anthony DEMARD <postmaster@pixs.fr>`

- [x] 1.2 Analyser les scripts de production du DIU (`root-install-debian.sh`,
  `lib/`, `modules/`) pour déterminer les éventuelles dépendances runtime
  à déclarer dans le champ `Depends:` du fichier `control`. L'analyse doit
  aboutir explicitement à l'une des deux conclusions :
  - un champ `Depends:` est nécessaire, avec la liste déterminée ;
  - aucun champ `Depends:` n'est nécessaire, avec justification.

## 2. Module packaging.sh

- [x] 2.1 Créer le répertoire `modules/projects/` s'il n'existe pas

- [x] 2.2 Créer le fichier `modules/projects/packaging.sh` avec l'en-tête
  Bash conformément à la convention du projet (`#!/usr/bin/env bash` suivi
  d'un commentaire descriptif)

- [x] 2.3 Implémenter la fonction `build_deb()` recevant `project_id` en
  paramètre et dérivant le chemin du projet via
  `$DEVOPS_PROJECTS_ROOT/$project_id`

- [x] 2.4 Implémenter la validation des prérequis de construction :
  - vérifier que `dpkg-deb` est disponible
  - vérifier que l'option `--root-owner-group` est supportée
  - en cas d'absence, afficher un message d'erreur clair et sortir avec
    le code 1

- [x] 2.5 Implémenter la validation du projet cible :
  - vérifier que le répertoire du projet existe
  - vérifier la présence de `root-install-debian.sh`
  - vérifier la présence de `lib/`
  - vérifier la présence de `modules/`
  - en cas d'absence, afficher un message identifiant les éléments
    manquants et sortir avec le code 1

- [x] 2.6 Implémenter la génération automatique de la version au format
  `YYYY.MM.DD.HH.MM` à partir de l'heure locale

- [x] 2.7 Garantir l'existence du répertoire `<project_path>/dist/` avant la
  construction. Le créer à la demande s'il n'existe pas.

- [x] 2.8 Implémenter la création du répertoire temporaire de staging
  (`$(mktemp -d)`) et la copie de la liste blanche :
  - `root-install-debian.sh`
  - `config/` (si présent et nécessaire à la production)
  - `lib/`
  - `modules/`
  Aucune copie globale du projet ne doit être utilisée.
  `variables.sh` n'est pas copié dans le paquet.

- [x] 2.9 Implémenter la génération du fichier `DEBIAN/control` avec les
  champs `Package`, `Version`, `Architecture`, `Maintainer`, `Description`
  et éventuellement `Depends`

- [x] 2.10 Implémenter l'appel à `dpkg-deb --build --root-owner-group` et
  le dépôt du paquet dans `<project_path>/dist/` avec la convention
  `diu_<version>_all.deb`

- [x] 2.11 Implémenter le nettoyage du répertoire temporaire de staging
  dans tous les cas : après succès ET après échec de la construction

## 3. Dispatch dans root-install-debian.sh

- [x] 3.1 Ajouter le sourcing de `modules/projects/packaging.sh` dans
  `root-install-debian.sh`

- [x] 3.2 Ajouter le cas `deb` dans la fonction `manage_project_action`,
  appelant `build_deb "$project_id"`

## 5. Mise à jour de l'aide

- [x] 5.1 Ajouter la documentation de la commande `rid proj deb <project_id>`
  dans la fonction `display_usage`

## 6. Vérifications

- [x] 6.1 Vérifier la syntaxe Bash avec `bash -n` sur tous les fichiers
  modifiés

- [x] 6.2 Vérifier que le paquet produit porte le nom attendu
  `diu_<version>_all.deb`

- [x] 6.3 Vérifier les métadonnées du paquet : `Package`, `Version`,
  `Architecture`, `Maintainer` et éventuellement `Depends`

- [x] 6.4 Vérifier que la valeur de `Version` du paquet est au format
  `YYYY.MM.DD.HH.MM`

- [x] 6.5 Vérifier que `build_deb()` ne source pas `variables.sh` et ne
  dépend d'aucune variable d'environnement pour déterminer la version
  du paquet

- [x] 6.7 Vérifier que le champ `Maintainer` du paquet correspond à
  `Anthony DEMARD <postmaster@pixs.fr>`

- [x] 6.8 Vérifier que seuls les éléments de la liste blanche sont présents
  dans le paquet

- [x] 6.9 Vérifier explicitement l'absence de `.git/`, `.opencode/`,
  `openspec/`, `deb/`, `dist/`, caches, journaux, secrets et fichiers
  temporaires dans le paquet

- [x] 6.10 Vérifier que `config/` est inclus dans le paquet lorsqu'il existe
  dans le projet source et doit être distribué

- [x] 6.11 Vérifier que `softwares/` et `system/` ne sont jamais présents à
  la racine de `/root/diu/` mais uniquement sous `modules/` lorsqu'ils
  existent

- [x] 6.12 Vérifier que le répertoire temporaire de staging est supprimé
  après succès ET après échec de la construction

- [x] 6.13 Vérifier que, après installation du paquet, le contenu de
  production est bien déployé sous `/root/diu/`

- [x] 6.14 Tester l'échec d'un projet inexistant

- [x] 6.15 Tester l'échec d'un projet ne contenant pas les éléments requis

- [x] 6.16 Tester l'échec en l'absence de `dpkg-deb` ou de
  `--root-owner-group`

- [x] 6.18 Vérifier que `variables.sh` n'est pas présent dans le paquet
  produit

- [x] 6.19 Vérifier que la liste blanche distribuée est limitée à
  `root-install-debian.sh`, `config/` si applicable, `lib/` et `modules/`

- [x] 6.20 Lors du test d'installation, vérifier qu'un éventuel
  `/root/diu/variables.sh` préexistant n'est pas remplacé par
  l'installation du paquet
