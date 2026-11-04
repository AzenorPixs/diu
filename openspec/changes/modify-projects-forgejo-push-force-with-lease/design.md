## Context

`forgejo_push()` délègue la publication à `git_push_provider()`. Pour un
fournisseur Forgejo explicite, ce parcours appelle
`forgejo_git_push_named()` pour publier la branche locale vers la branche
distante configurée, puis publie séparément le tag éventuel.

`--force-with-lease` s'appuie sur la référence locale de suivi du remote. Un
fetch authentifié du remote nommé est donc nécessaire avant le push vers un
dépôt existant. Pour un dépôt absent, le change
`restore-forgejo-push-to-create` prévoit un premier push sans fetch ni
création API. Les deux deltas de publication Forgejo conservent le même
contrat cumulatif afin que leur ordre de synchronisation ne retire aucune
de ces garanties.

## Goals / Non-Goals

**Goals:**

- Protéger la mise à jour de la branche distante Forgejo avec
  `--force-with-lease`.
- Synchroniser les références du remote Forgejo existant avant de vérifier le
  suivi et de publier la branche ; omettre le fetch pour un dépôt absent.
- Supprimer la confirmation interactive du push Forgejo, GitLab et GitHub,
  conformément à la proposition et aux deltas associés.
- Préserver les protections GitHub déjà spécifiées : fetch authentifié,
  arrêt sur échec et `--force-with-lease` sur la branche.
- Conserver l'authentification, le suivi de branche et la destination
  explicite existants.

**Non-Goals:**

- Forcer ou modifier la publication des tags.
- Modifier les autres comportements des parcours GitLab ou GitHub.
- Ajouter une configuration ou une interaction utilisateur.

## Decisions

- Ajouter l'option uniquement à l'invocation qui publie la branche. Un tag
  constitue une référence distincte et ne doit pas être réécrit implicitement.
- Conserver l'appel au provider `forgejo_git_push_named()` afin de préserver
  l'authentification HTTPS temporaire existante.
- Ajouter `forgejo_git_fetch_named()` et conserver `forgejo_git_fetch()` comme
  compatibilité pour le remote historique `origin`.
- Retirer la confirmation supplémentaire du push pour les trois fournisseurs,
  en conservant les contrôles de configuration et d'identifiants existants.
- Vérifier l'existence du dépôt avant le fetch Forgejo et conserver le premier
  push sans fetch pour un dépôt absent, selon
  `restore-forgejo-push-to-create`.

## Risks / Trade-offs

- Un push est refusé lorsqu'une branche distante a changé sans que l'état
  local de suivi ne le reflète. Ce refus est le mécanisme de protection
  attendu ; aucun contournement automatique n'est prévu.
- La récupération peut échouer avant le push ; le push est alors arrêté afin
  de ne pas utiliser une information de bail périmée.
- Une commande Forgejo valide déclenche immédiatement la publication après les
  vérifications de configuration et d'identifiants existantes.

## Migration Plan

La modification ne nécessite aucune migration de configuration. Un éventuel
retour arrière doit distinguer la protection de branche Forgejo, les
confirmations de push et la création par premier push. Il doit préserver les
protections GitHub préexistantes et fait l'objet d'une validation distincte.
