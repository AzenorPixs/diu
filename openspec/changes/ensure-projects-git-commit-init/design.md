## Context

`git_commit()` vérifie déjà la présence d'un dépôt Git local avant toute
modification de l'index. `git_init()` réalise l'initialisation configurée et
crée le premier commit local. Voir `proposal.md` pour la motivation.

## Goals / Non-Goals

**Goals:**

- Réutiliser `git_init()` dans le parcours commun de commit lorsque le dépôt
  local est absent.
- Ne poursuivre le commit qu'après une nouvelle vérification positive du
  dépôt.
- Ne demander aucune saisie et ne produire aucune sortie pendant une
  initialisation locale réussie.

**Non-Goals:**

- Modifier la sélection des projets de `git_commit_all()`.
- Ajouter un dépôt distant, un push ou une création de tag supplémentaire.

## Decisions

- Placer l'appel dans `git_commit()` plutôt que dans le routeur CLI ou dans
  `git_commit_all()`. Les deux commandes de commit convergent déjà vers cette
  fonction, ce qui assure un comportement identique sans dupliquer le
  contrôle.
- Après le retour de `git_init()`, répéter `rev-parse --is-inside-work-tree`.
  Cette vérification empêche le commit de continuer si l'initialisation échoue
  sans créer de dépôt.
- Ne conserver que les diagnostics d'erreur dans `git_init()` ; les résumés et
  inspections affichés après une initialisation réussie sont supprimés.
- Conserver le code d'erreur du commit lorsque l'initialisation échoue ou que
  le dépôt reste absent. Pour le mode groupé, `git_commit_all()` poursuit déjà
  les projets suivants et signale l'échec global à la fin.

## Risks / Trade-offs

- [Le premier commit est créé par `git_init()`] → le commit demandé continue
  ensuite selon la logique existante et ne crée un second commit que si des
  modifications restent à enregistrer.

## Migration Plan

La modification est rétrocompatible et ne requiert aucune migration. En cas
de retour arrière, supprimer l'appel et la seconde vérification rétablit le
comportement précédent, où l'absence de dépôt provoque directement l'échec du
commit.
