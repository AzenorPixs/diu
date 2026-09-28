# Design

## Context

La publication GitHub valide déjà le dépôt, le remote et les identifiants,
mais elle pouvait pousser une branche avec une référence distante locale
obsolète. Voir `proposal.md` pour la motivation et le delta de spécification
pour le contrat observable.

## Goals / Non-Goals

**Goals:**

- Actualiser la référence de suivi GitHub avant le push de branche.
- Utiliser une lease calculée à partir de cette référence actualisée.
- Préserver l'authentification temporaire existante et l'arrêt explicite en
  cas d'échec.

**Non-Goals:**

- Résoudre ou fusionner automatiquement des historiques divergents.
- Modifier les règles de publication Forgejo, GitLab ou des tags GitHub.
- Exécuter un push réel dans les tests.

## Decisions

- Ajouter un auxiliaire GitHub authentifié pour `git fetch`, symétrique au
  helper de push existant. Il réutilise la lecture protégée des identifiants et
  `git_with_token`; aucune nouvelle dépendance ni voie de secret n'est créée.
- Exécuter ce fetch après la validation du remote et avant la détermination du
  push GitHub. Une erreur interrompt le flux avant toute publication.
- Ajouter `--force-with-lease` uniquement au refspec de branche GitHub. Cette
  option conserve la protection contre une mise à jour intervenue après le
  fetch, contrairement à `--force`.

L'alternative consistant à utiliser seulement `--force-with-lease` est rejetée
car une référence de suivi locale obsolète ferait échouer le cas de
synchronisation visé. L'alternative `--force` est rejetée car elle pourrait
écraser une mise à jour distante concurrente.

## Risks / Trade-offs

- [Une modification distante intervient après le fetch] → la lease refuse le
  push, sans écrasement distant.
- [La récupération GitHub échoue] → le flux s'arrête explicitement et aucun
  push de branche n'est tenté.
- [Un remote privé requiert une authentification] → le helper réutilise le
  mécanisme temporaire déjà employé pour le push.

## Migration Plan

La modification est rétrocompatible et ne requiert aucune migration de
configuration. Le retour arrière consiste à retirer le helper de fetch et
l'option de lease, ce qui rétablit le comportement antérieur mais n'est pas
recommandé tant que la publication multi-machine reste nécessaire.
