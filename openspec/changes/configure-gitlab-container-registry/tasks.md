## 1. Configuration GitLab

- [x] 1.1 Ajouter `REMOTE_GITLAB_REGISTRY` au chargement, au prompt et à la
  persistance de `gitlab_update()` ; vérifier que seuls les paramètres GitLab
  sont réécrits dans `project.env`.
- [x] 1.2 Faire reconnaître l'absence de ce paramètre par la release GitLab et
  relancer `gitlab_update()` ; vérifier le rechargement de la configuration
  avant toute publication Docker.
- [x] 1.3 Rejeter une adresse de registre contenant un protocole ou un chemin ;
  vérifier qu'elle relance la configuration avant tout tag Docker.

## 2. Publication Docker

- [x] 2.1 Construire le login et les références Docker à partir du registre
  explicite, sans dérivation de l'URL GitLab ; vérifier qu'un port est
  préservé dans les arguments Docker.
- [x] 2.2 Réessayer uniquement les `docker push` GitLab qui échouent avec
  `blob unknown to registry`, au plus trois fois avec une attente progressive.

## 3. Tests et validation

- [x] 3.1 Ajouter des tests isolés couvrant le registre avec port et la
  reconfiguration d'une variable absente ; vérifier leur réussite sans réseau.
- [x] 3.2 Exécuter la syntaxe Bash, les tests ciblés et la validation stricte
  du change OpenSpec ; vérifier qu'ils réussissent avant l'archivage.
- [x] 3.3 Ajouter des tests isolés couvrant la reprise transitoire et l'échec
  immédiat d'un diagnostic de publication différent.

## CGP du 2026-10-16 — lot L8 : réconciliation et synchronisation

Le développeur a validé le maintien du comportement actuel : correction
séparée des blocs incomplets par update_projects et gitlab_update,
rechargement et contrôle après chaque correction, registre explicite avec
port conservé, sans protocole ni chemin. Le registre reste requis pour toute
release GitLab, y compris uniquement Debian. La reprise limitée à
blob unknown to registry reste inchangée.

Les trois capacités principales add-projects-gitlab-update,
refine-projects-gitlab-push-config et implement-projects-gitlab-release
portent désormais les exigences du registre. Le delta de release est
réconcilié avec l'initialisation conditionnelle et le cas Debian seul.
TECHNICAL.md décrit ces choix et conserve le change actif.

| Contrôle exécuté | Résultat observé |
| --- | --- |
| Validation OpenSpec standard et stricte de chacune des trois capacités principales | Six commandes réussies, code 0, aucun diagnostic |
| Validation OpenSpec standard et stricte de configure-gitlab-container-registry | Deux commandes réussies, code 0, aucun diagnostic |
| tests/test_projects.py, Python DevOps avec -B et TMPDIR=/tmp | 26 tests réussis ; résultats communs avec L10 réutilisés, sources et tests inchangés |
| Comparaison des trois exigences de release entre delta et contrat principal | Textes et scénarios identiques |
| Revue du périmètre et UTF-8/LF | Limitée aux six fichiers autorisés ; aucun code ni test modifié |

Les scénarios d'initialisation par bloc et de release Debian sans registre
ont été rapprochés statiquement des conditions de projects_gitlab_release.
Les tests existants sont conservés ; aucun test supplémentaire n'a été créé.
La réussite de ces tests isolés ne vaut pas qualification d'un registre
GitLab réel ni preuve d'une publication distante.

État du lot L8 : réconciliation réalisée, validations ciblées réussies.
Le change reste actif et non archivé. Aucun déploiement, build, publication,
modification de configuration réelle ou opération Git sur le dépôt du projet
n'a été effectué. Aucun rapport statistique d'archive n'est requis pour ce lot.
