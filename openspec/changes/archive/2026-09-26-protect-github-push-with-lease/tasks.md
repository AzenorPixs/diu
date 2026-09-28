# Tasks

## 1. Publication GitHub protégée

- [x] 1.1 Récupérer les références GitHub authentifiées avant le push de branche et vérifier que l'échec du fetch interrompt le flux.
- [x] 1.2 Employer `--force-with-lease` pour la branche GitHub et vérifier que le push de tags ainsi que les fournisseurs Forgejo et GitLab restent inchangés.

## 2. Validation

- [x] 2.1 Exécuter `bash -n`, ShellCheck et les tests ciblés de publication GitHub avec succès.
- [x] 2.2 Valider le change OpenSpec en mode strict et archiver le change après confirmation de tous les critères.
