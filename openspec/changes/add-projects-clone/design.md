## Context

Le module `modules/projects/projects.sh` regroupe les opérations locales sur
les projets, le routage CLI est défini dans `root-install-debian.sh` et l'aide
contextuelle dans `lib/rid-help.sh`. La création depuis modèle exclut déjà le
répertoire Git de son modèle ; le clonage doit fournir le même isolement pour
un projet source complet, sans appeler Git.

## Goals / Non-Goals

**Goals:**

- Copier fidèlement les fichiers et répertoires ordinaires d'un projet source.
- Exclure récursivement tout répertoire nommé `.git` de la copie.
- Produire un `project.env` dont `PROJECT_ID` identifie la destination.
- Refuser les prérequis invalides avant toute écriture destination.
- Exposer la commande et son aide sans modifier les commandes existantes.

**Non-Goals:**

- Initialiser, configurer, supprimer ou utiliser un dépôt Git.
- Modifier le projet source ou fusionner dans une destination existante.
- Modifier les autres variables de `project.env` ou personnaliser les fichiers
  du projet.
- Copier un projet vers un emplacement hors de `DEVOPS_PROJECTS_ROOT`.

## Decisions

- La commande publique `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`
  délègue à `clone_project` avec ces deux arguments. Ses formes `clone help`
  et `clone ?` affichent l'aide sans démarrer de copie.
- Les deux identifiants sont obligatoires et ne peuvent pas désigner un
  chemin. La source est
  `${DEVOPS_PROJECTS_ROOT}/<ID PROJECT SOURCE>` ; elle doit être un répertoire
  contenant un fichier `project.env`. La destination est
  `${DEVOPS_PROJECTS_ROOT}/<ID PROJECT DESTINATION>` et doit être absente. Ces
  contrôles évitent une copie ambiguë ou l'écrasement d'un projet existant.
- La copie est préparée dans un répertoire temporaire puis installée dans la
  destination uniquement lorsqu'elle est complète. La sélection exclut tout
  répertoire `.git` rencontré, ce qui empêche le transfert de métadonnées Git
  racine ou imbriquées tout en conservant les autres fichiers cachés.
- Après la préparation de la copie, `project_env_set_variables` met à jour
  exclusivement `PROJECT_ID` avec l'identifiant destination. Cette fonction
  conserve les lignes non ciblées et assure un échappement compatible Bash.
- La propriété de la destination est attribuée à
  `${DEVOPS_USER}:${DEVOPS_GROUP}`, conformément aux autres opérations du
  module projets. Tout échec est signalé et retourne un code non nul.

## Risks / Trade-offs

- [Une destination existante pourrait être voulue pour une fusion] → la
  commande la refuse afin de ne pas écraser ou mélanger des fichiers ; une
  fusion devra être spécifiée séparément.
- [La copie échoue après sa création] → le travail est préparé hors de la
  destination et tout répertoire destination partiel est supprimé avant le
  retour d'erreur.
- [Un projet source contient un `.git` imbriqué légitime] → il est exclu par
  le contrat explicite de clonage sans métadonnées Git.

## Migration Plan

1. Ajouter les deltas OpenSpec et les tests ciblés.
2. Ajouter le routage, le clonage local et l'aide.
3. Vérifier la syntaxe Bash, ShellCheck, les tests ciblés et OpenSpec.

Le repli consiste à ne plus utiliser la nouvelle commande ; elle ne modifie
pas le projet source ni les commandes existantes.
