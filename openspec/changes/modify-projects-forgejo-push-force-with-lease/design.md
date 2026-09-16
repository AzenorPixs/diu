## Context

`forgejo_push()` délègue la publication à `git_push_provider()`. Pour un
fournisseur Forgejo explicite, ce parcours appelle
`forgejo_git_push_named()` pour publier la branche locale vers la branche
distante configurée, puis publie séparément le tag éventuel.

`--force-with-lease` s'appuie sur la référence locale de suivi du remote. Un
fetch authentifié du remote nommé est donc nécessaire avant le push afin de
permettre un premier push vers une branche distante existante.

## Goals / Non-Goals

**Goals:**

- Protéger la mise à jour de la branche distante Forgejo avec
  `--force-with-lease`.
- Synchroniser les références du remote Forgejo avant de vérifier le suivi et
  de publier la branche.
- Supprimer la confirmation interactive propre au push Forgejo.
- Conserver l'authentification, le suivi de branche et la destination
  explicite existants.

**Non-Goals:**

- Forcer ou modifier la publication des tags.
- Modifier les parcours GitLab ou GitHub.
- Ajouter une configuration ou une interaction utilisateur.

## Decisions

- Ajouter l'option uniquement à l'invocation qui publie la branche. Un tag
  constitue une référence distincte et ne doit pas être réécrit implicitement.
- Conserver l'appel au provider `forgejo_git_push_named()` afin de préserver
  l'authentification HTTPS temporaire existante.
- Ajouter `forgejo_git_fetch_named()` et conserver `forgejo_git_fetch()` comme
  compatibilité pour le remote historique `origin`.
- Conditionner la confirmation existante aux fournisseurs non Forgejo afin de
  préserver les parcours GitLab et GitHub.

## Risks / Trade-offs

- Un push est refusé lorsqu'une branche distante a changé sans que l'état
  local de suivi ne le reflète. Ce refus est le mécanisme de protection
  attendu ; aucun contournement automatique n'est prévu.
- La récupération peut échouer avant le push ; le push est alors arrêté afin
  de ne pas utiliser une information de bail périmée.
- Une commande Forgejo valide déclenche immédiatement la publication après les
  vérifications de configuration et d'identifiants existantes.

## Migration Plan

La modification est rétrocompatible et ne nécessite aucune migration. Son
annulation consiste à retirer l'option du seul push de branche Forgejo.
