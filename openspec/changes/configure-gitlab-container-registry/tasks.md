## 1. Configuration GitLab

- [x] 1.1 Ajouter `REMOTE_GITLAB_REGISTRY` au chargement, au prompt et à la
  persistance de `gitlab_update()` ; vérifier que seuls les paramètres GitLab
  sont réécrits dans `project.env`.
- [x] 1.2 Faire reconnaître l'absence de ce paramètre par la release GitLab et
  relancer `gitlab_update()` ; vérifier le rechargement de la configuration
  avant toute publication Docker.

## 2. Publication Docker

- [x] 2.1 Construire le login et les références Docker à partir du registre
  explicite, sans dérivation de l'URL GitLab ; vérifier qu'un port est
  préservé dans les arguments Docker.

## 3. Tests et validation

- [x] 3.1 Ajouter des tests isolés couvrant le registre avec port et la
  reconfiguration d'une variable absente ; vérifier leur réussite sans réseau.
- [x] 3.2 Exécuter la syntaxe Bash, les tests ciblés et la validation stricte
  du change OpenSpec ; vérifier qu'ils réussissent avant l'archivage.
