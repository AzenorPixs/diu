## Context

L'évolution `add-projects-sync` définit la synchronisation unitaire d'un
projet et le modèle autoritaire situé dans
`/home/${DEVOPS_USER}/datas/template`. La nouvelle commande doit parcourir
les projets directs du même répertoire sans confondre la source avec une
destination. Le routeur et l'aide restent respectivement dans
`root-install-debian.sh` et `lib/rid-help.sh`.

## Goals / Non-Goals

**Goals:**

- Exposer la synchronisation groupée sous `rid projects sync all`.
- Réutiliser une synchronisation unitaire pour chaque projet éligible.
- Écarter les répertoires non configurés et le modèle sans les modifier.
- Conserver le traitement des autres projets lorsqu'un projet échoue.

**Non-Goals:**

- Modifier les règles de copie, d'écrasement ou de personnalisation de la
  synchronisation unitaire.
- Créer, réparer ou compléter un `project.env` invalide.
- Modifier le modèle, les répertoires non sélectionnés ou Git.
- Parcourir récursivement les sous-répertoires de données.

## Decisions

- Le routeur distingue `all` comme une commande groupée ; toute autre valeur
  est transmise à la synchronisation unitaire. `help` et `?` conservent le
  comportement d'aide contextuelle.
- La sélection examine exclusivement les répertoires directs. Elle charge
  chaque `project.env` dans un environnement isolé afin de contrôler
  `PROJECT_ID` et `PROJECT_NAME` sans réutiliser l'état d'un projet précédent.
- Le répertoire `template` est exclu explicitement par son nom ; il ne peut
  donc pas être synchronisé sur lui-même.
- Le modèle est prévalidé une fois avant de démarrer le parcours. Ensuite,
  chaque projet retenu est confié à la synchronisation unitaire : les règles
  de contenu restent centralisées et identiques.
- Les échecs par projet sont mémorisés et signalés après le parcours, mais ne
  bloquent pas les autres projets. En l'absence de candidat, l'opération est
  une absence de travail explicite et réussie.

## Risks / Trade-offs

- [Un `project.env` peut contenir du code exécuté au chargement] → la
  sélection s'appuie sur les conventions existantes et limite les variables
  retenues aux métadonnées nécessaires ; l'implémentation ne doit pas
  réutiliser l'environnement entre projets.
- [Un projet devient indisponible pendant le parcours] → l'échec est
  diagnostiqué et comptabilisé, tandis que les projets suivants restent
  traités.
- [Le modèle devient incomplet après sa validation] → chaque synchronisation
  unitaire conserve ses propres contrôles avant mutation.

## Migration Plan

1. Implémenter la sélection et le routage groupés après la synchronisation
   unitaire.
2. Ajouter les tests des sélections, des échecs et de l'aide.
3. Vérifier la syntaxe Bash, ShellCheck, les tests ciblés et OpenSpec.

Le repli consiste à ne plus utiliser `rid projects sync all` ; la commande
unitaire demeure inchangée.
