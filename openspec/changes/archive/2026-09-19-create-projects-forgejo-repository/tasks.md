# Tasks

## 1. Spécification

- [x] 1.1 Définir la création API d'un dépôt Forgejo absent et vérifier les scénarios utilisateur, organisation et refus dans les deltas OpenSpec.

## 2. Implémentation

- [x] 2.1 Ajouter l'assurance idempotente du dépôt Forgejo via les helpers API existants et vérifier les réponses HTTP attendues dans les tests ciblés.
- [x] 2.2 Appeler cette assurance avant le fetch Forgejo et vérifier que le fetch précède toujours le push une fois le dépôt accessible.
- [x] 2.3 Ajouter les tests isolés des parcours dépôt existant, utilisateur, organisation et refus, sans appel réseau réel.

## 3. Validation

- [x] 3.1 Exécuter `bash -n`, ShellCheck, les tests Python ciblés et la validation stricte OpenSpec, puis documenter tout diagnostic hors périmètre.
