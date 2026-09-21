# Design

## Context

Le push Forgejo protégé récupère aujourd'hui les références du remote avant la
publication. Un dépôt absent est détecté pendant la validation, mais n'est pas
créé avant cette récupération. Les helpers `forgejo_api_get` et
`forgejo_api_post_json` centralisent déjà les appels API authentifiés et le
respect de `REMOTE_FORGEJO_SSL_VERIFY`.

## Goals / Non-Goals

**Goals:**

- Garantir qu'un dépôt Forgejo absent est créé vide avant le fetch imposé par
  `--force-with-lease`.
- Limiter la création aux propriétaires accessibles sans privilège
  d'administration : utilisateur authentifié ou organisation.
- Préserver les credentials, le remote, la branche et les tags existants.

**Non-Goals:**

- Ne pas créer de compte utilisateur, d'organisation, de branche, de README
  ou de commit initial.
- Ne pas recourir aux API administrateur ni modifier les paramètres Forgejo
  « push to create ».
- Ne pas créer automatiquement de token ou étendre les permissions locales.

## Decisions

### Vérification et création par l'API Forgejo

Le provider interrogera le dépôt configuré. Un `200` conserve le parcours
actuel ; un `404` déclenche l'identification du propriétaire puis la création
API d'un dépôt vide. Les autres réponses restent des erreurs explicites.

Cette solution est retenue plutôt que le « push to create » : ce mécanisme
Forgejo dépend d'options serveur, alors que l'API permet un comportement
déterministe pour les permissions effectivement accordées au token.

### Identification du propriétaire sans administration

Si le propriétaire correspond à l'utilisateur authentifié, la création passe
par `POST /user/repos`. Sinon, le provider vérifie s'il s'agit d'une
organisation puis utilise `POST /orgs/<owner>/repos`. Un propriétaire qui est
un autre utilisateur provoque un échec explicite ; utiliser
`/admin/users/<user>/repos` étendrait les privilèges requis.

### Ordonnancement dans le parcours de publication

`git_push_provider` appelle l'assurance du dépôt Forgejo après validation des
credentials et avant `forgejo_git_fetch_named`. Ainsi, le fetch et le
`--force-with-lease` restent inchangés pour les dépôts existants et deviennent
possibles lors du premier push.

## Risks / Trade-offs

- [Le token ne permet pas de créer dans l'organisation] → l'API renvoie une
  erreur explicite et aucun fetch ou push n'est tenté.
- [Une création concurrente survient] → un conflit de création est signalé ;
  l'utilisateur peut relancer le push, qui constatera alors le dépôt existant.
- [L'instance Forgejo applique une politique de création particulière] → le
  code propage le statut API sans repli privilégié ni modification serveur.

## Migration Plan

La modification ne crée aucun état local persistant. Le repli consiste à
revenir au comportement existant, qui exigeait un dépôt distant déjà créé ;
aucune suppression de dépôt distant n'est automatisée.
