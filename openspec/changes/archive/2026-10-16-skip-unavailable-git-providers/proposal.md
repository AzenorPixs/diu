# Fournisseurs Git temporairement indisponibles

## Why

Une connexion impossible à GitLab arrête actuellement le flux CI/CD, même
lorsque les autres fournisseurs restent accessibles.

## What Changes

- Traiter une indisponibilité DNS/TCP, un délai dépassé ou HTTP 502/503/504
  comme une publication non confirmée, sans erreur de commande publique.
- Poursuivre les autres fournisseurs et le build local ; ignorer les releases
  du fournisseur indisponible et afficher un résultat global explicite.
- Préserver les erreurs d'authentification, TLS, configuration et rejet Git.
- Conserver les contrats de clonage et de release lancée directement.

## Capabilities

### New Capabilities

- `git-provider-availability` : classification contextuelle des indisponibilités.

### Modified Capabilities

- `git-auth` : signal réseau distinct dans le contexte de push tolérant.
- `projects-cicd` : poursuite et résumé avec indisponibilités.
- `implement-projects-forgejo-push` : état non bloquant.
- `implement-projects-gitlab-push` : état non bloquant.
- `implement-projects-github-push` : état non bloquant, y compris API/fetch.
- `projects-forgejo-push-all` : agrégation sans faux succès.

## Impact

Module Git, bibliothèques d'authentification nécessaires, tests isolés de
publication/CI/CD, TECHNICAL.md, README.md et CHANGELOG.md. Aucune dépendance,
migration ou nouvelle variable de configuration. Les statuts internes ne sont
pas persistés. Le repli consiste à retirer le contexte tolérant, sans rollback
des publications éventuellement déjà effectuées.

## Validation

Périmètre SCM validé le 16 octobre 2026 : spécification, code, tests, documents,
synchronisation et archivage de ce seul change avec STATISTIQUES.md.
Tests sans réseau réel, syntaxe Bash/Python, ShellCheck et OpenSpec strict.
Aucun commit, push, appel API réel, déploiement ou installation système.
