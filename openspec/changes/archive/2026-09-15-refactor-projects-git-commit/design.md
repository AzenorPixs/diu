## Context

Le dispatch `projects` est centralisé dans `root-install-debian.sh`. Les
sous-commandes Git `init` et `update` sont déjà regroupées sous l'action
`git`, tandis que le commit utilise encore l'action historique `gitc`.
L'aide contextuelle est fournie par `lib/rid-help.sh`. Voir `proposal.md` pour
la motivation et les deltas de spécification pour le comportement public.

## Goals / Non-Goals

**Goals:**

- Regrouper le commit avec les autres sous-commandes Git publiques.
- Préserver le calcul existant des valeurs par défaut du commit.
- Rendre l'aide cohérente aux niveaux `projects`, `projects git` et terminal.

**Non-Goals:**

- Modifier `git_commit` ou le comportement Git sous-jacent.
- Conserver un alias de compatibilité pour `gitc`.
- Modifier les autres commandes Git, les fournisseurs distants ou le flux
  CI/CD.

## Decisions

- Le dispatch place `commit` dans le `case` déjà utilisé par `git`. Cette
  approche conserve une structure cohérente avec `init` et `update`; conserver
  `gitc` comme alias aurait contredit le retrait explicite de la commande
  historique.
- Les indices d'arguments sont décalés d'une position : le projet est le
  troisième argument transmis à `manage_project_action`, le message le
  quatrième et le tag le cinquième. Cette décision préserve la sémantique des
  valeurs par défaut sans modifier l'interface de `git_commit`.
- L'aide de premier niveau expose la syntaxe canonique, l'aide `projects git`
  liste la sous-commande et l'aide terminale la répète. Une aide seulement au
  sous-contexte Git laisserait l'aide générale incomplète.

## Risks / Trade-offs

- [Les scripts locaux utilisant `gitc` échouent après la mise à jour] → le
  changement est explicitement incompatible et les aides indiquent la syntaxe
  de remplacement.
- [Une erreur d'indice d'argument change le message ou le tag] → des tests
  ciblés couvrent la syntaxe affichée et une revue du routage confirme les
  valeurs transmises.

## Migration Plan

1. Mettre à jour les spécifications et le dispatch.
2. Mettre à jour les aides et les tests ciblés.
3. Vérifier la syntaxe, ShellCheck, les tests et OpenSpec.

Le repli consiste à restaurer la version précédant ce changement ; aucun état
de données ni migration n'est créé.
