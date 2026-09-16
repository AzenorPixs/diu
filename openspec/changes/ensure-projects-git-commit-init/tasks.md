## 1. Initialisation avant commit

- [x] 1.1 Appeler `git_init()` depuis `git_commit()` lorsqu'aucun dépôt local
  n'est détecté, puis vérifier de nouveau le dépôt avant le commit ; vérifier
  le comportement avec des tests ciblés.

## 2. Validation

- [x] 2.1 Ajouter des scénarios de test pour l'initialisation réussie et
  annulée ou échouée ; vérifier que le commit n'est pas exécuté lorsque le
  dépôt reste absent.
- [ ] 2.2 Exécuter `bash -n`, `shellcheck`, les tests Python ciblés et la
  validation stricte OpenSpec ; vérifier que tous réussissent.
