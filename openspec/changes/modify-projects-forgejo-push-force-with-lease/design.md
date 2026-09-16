## Context

`forgejo_push()` délègue la publication à `git_push_provider()`. Pour un
fournisseur Forgejo explicite, ce parcours appelle
`forgejo_git_push_named()` pour publier la branche locale vers la branche
distante configurée, puis publie séparément le tag éventuel.

## Goals / Non-Goals

**Goals:**

- Protéger la mise à jour de la branche distante Forgejo avec
  `--force-with-lease`.
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

## Risks / Trade-offs

- Un push est refusé lorsqu'une branche distante a changé sans que l'état
  local de suivi ne le reflète. Ce refus est le mécanisme de protection
  attendu ; aucun contournement automatique n'est prévu.

## Migration Plan

La modification est rétrocompatible et ne nécessite aucune migration. Son
annulation consiste à retirer l'option du seul push de branche Forgejo.
