## 1. Spécification

- [x] 1.1 Définir la récupération préalable des références et le push de
  branche Forgejo avec `--force-with-lease`, sans forçage du tag.

## 2. Implémentation

- [x] 2.1 Ajouter la récupération Forgejo nommée et `--force-with-lease` au
  push de branche Forgejo.
- [x] 2.2 Ajouter un test ciblé de la récupération et des arguments transmis
  au provider Forgejo.
- [x] 2.3 Supprimer la confirmation du push Forgejo et vérifier qu'il démarre
  sans entrée interactive.

## 3. Validation

- [ ] 3.1 Exécuter `bash -n`, ShellCheck, les tests Python ciblés et la
  validation stricte OpenSpec.
