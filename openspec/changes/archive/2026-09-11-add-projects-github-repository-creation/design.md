## Context

Le flux GitHub valide ou ajoute actuellement le remote local avant
l'initialisation des identifiants et avant le push. `lib/github-auth.sh`
protège déjà le token pour Git, mais ne fournit pas d'appel API.

## Goals / Non-Goals

**Goals:**

- Vérifier le dépôt GitHub avant toute mutation du remote local.
- Créer explicitement un dépôt absent sous le compte ou l'organisation cible.
- Conserver la confidentialité du token durant les appels HTTP.

**Non-Goals:**

- Créer, modifier ou supprimer des dépôts sans confirmation.
- Modifier les flux Forgejo et GitLab.
- Ajouter un paramètre de création non interactif.

## Decisions

- Ajouter les helpers API dans `lib/github-auth.sh`, à côté de la gestion des
  identifiants GitHub, pour conserver une responsabilité unique.
- Utiliser un fichier de configuration `curl` temporaire en permissions 600
  plutôt qu'un en-tête passé en argument, afin que le token n'apparaisse pas
  dans la liste des processus.
- Interroger `GET /repos/<owner>/<repository>` ; traiter uniquement `200` et
  `404` comme réponses attendues. Tout autre statut bloque le push.
- Demander la création et la visibilité uniquement après un `404`. La valeur
  par défaut est `private` pour privilégier la sécurité.
- Créer via `POST /user/repos` pour le compte authentifié et
  `POST /orgs/<owner>/repos` pour un propriétaire distinct. L'API identifie le
  compte authentifié au lieu de supposer que le nom d'utilisateur local est le
  login GitHub.

## Risks / Trade-offs

- [Token sans permission Administration] → l'API retourne une erreur explicite
  et le remote local reste inchangé.
- [Un `404` peut masquer un accès insuffisant] → la création n'est tentée
  qu'après confirmation ; GitHub retourne alors son erreur sans écraser de
  dépôt existant.
- [GitHub Enterprise] → l'API est dérivée de `REMOTE_GITHUB_BASE_URL`, avec
  `https://api.github.com` pour github.com et `/api/v3` pour les autres hôtes.

## Migration Plan

La fonctionnalité est additive. En cas de régression, supprimer l'appel de
vérification rétablit le flux GitHub existant sans modification de
configuration persistante.
