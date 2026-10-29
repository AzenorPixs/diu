# GIT01 — Authentification Git HTTPS par jeton

## Why

Lors d'une publication Forgejo (`rid proj rel`), la fonction `publish_release()`
exécute `git fetch origin` avant de lire le token Forgejo. Git demande alors de
manière interactive un identifiant et un mot de passe HTTPS, ce qui bloque
l'exécution automatisée.

Le même problème se pose pour `git_push()` qui n'utilise aucun mécanisme
d'authentification HTTPS et dépend uniquement de la saisie interactive.

Par ailleurs, le token Forgejo persistant (`config/forgejo.token`) existe déjà
pour les appels API REST mais n'est pas réutilisé pour les opérations Git.
Chaque fonction Git devra potentiellement authentifier ses opérations distantes,
ce qui appelle une factorisation générique et extensible.

## What Changes

- Création d'un module générique `lib/git-auth.sh` fournissant une primitive
  d'exécution de commandes Git authentifiées via un token temporaire, sans
  modification du remote ni stockage persistant de credentials.
- Création d'un module provider `lib/forgejo-auth.sh` encapsulant la
  résolution Forgejo (déduction du host, lecture du token, validation des
  permissions, transmission au cœur générique).
- Intégration dans `publish_release()` : le `git fetch origin` sera exécuté via
  le mécanisme d'authentification token lorsque `config/forgejo.token` est
  disponible.
- Intégration dans `git_push()` : le push sera exécuté via le même mécanisme.
- Ajout du sourcing des nouveaux modules dans `root-install-debian.sh`.

## Capabilities

### New Capabilities

- `git-auth`: Primitive générique d'authentification Git HTTPS par token.
  Fournit un mécanisme agnostique du fournisseur pour exécuter `git fetch`,
  `git push` et d'autres commandes Git authentifiées via un token temporaire,
  sans exposer le secret.
- `forgejo-auth`: Provider Forgejo pour l'authentification Git HTTPS. Gère la
  résolution du host Forgejo depuis le remote, la lecture et la validation du
  token, et la transmission au cœur générique `git-auth`.

### Modified Capabilities

- `forgejo-release`: La fonction `publish_release()` sera modifiée pour utiliser
  le mécanisme `git-auth`/`forgejo-auth` au lieu d'exécuter `git fetch origin`
  directement. Le bootstrap automatique du token reste préservé.

## Impact

- **Fichiers créés** : `lib/git-auth.sh`, `lib/forgejo-auth.sh`
- **Fichiers modifiés** : `root-install-debian.sh` (ajout des sourcing),
  `modules/projects/forgejo-release.sh` (intégration de l'authentification pour
  `git fetch`), fonction `git_push()` dans `root-install-debian.sh`
- **Dépendances** : aucune nouvelle dépendance externe (utilise `git`, `runuser`,
  `mktemp` déjà disponibles)
- **Compatibilité** : le comportement en absence de token sera défini
  explicitement par contexte — `publish_release()` conserve son bootstrap Forgejo
  existant ; `git_push()` devra adopter un comportement fail-closed ou
  explicitement spécifié dans la spec. Aucun fallback silencieux vers une
  authentification interactive n'est prévu.
- **Sécurité** : suppression de l'exposition interactive des credentials,
  utilisation exclusive de mécanismes temporaires non persistants
