# Design

## Dispatch et aides

Le parcours de publication générique est retiré du dispatch de
`root-install-debian.sh`. Ses lignes sont supprimées des aides de premier
niveau, du contexte `projects` et de la documentation détaillée. Les entrées
`gitpdiu` et `gitpdi` restent présentes.

## Publication multi-fournisseur

Le corps de l'ancien orchestrateur est conservé sous une fonction interne
`git_push_provider <ID PROJECT> <PROVIDER>`. Le paramètre `PROVIDER` est
obligatoire et vaut `forgejo`, `gitlab` ou `github`. Les fonctions publiques
`forgejo_push`, `gitlab_push` et `github_push` l'appellent directement avec
leur fournisseur respectif ; aucun parcours dédié ne lit un sélecteur distant
global.

Les flux CI/CD qui utilisaient le parcours historique appellent le parcours
Forgejo explicite. Les fonctions d'authentification, de vérification de remote,
de commit, de release et de mise à jour ne sont pas refactorées au-delà de ce
branchement nécessaire.

## Configuration distante

Les usages applicatifs des variables génériques sont remplacés par :

| Ancienne variable | Variable Forgejo |
|---|---|
| `REMOTE_BASE_URL` | `REMOTE_FORGEJO_BASE_URL` |
| `REMOTE_OWNER` | `REMOTE_FORGEJO_OWNER` |
| `REMOTE_REPOSITORY` | `REMOTE_FORGEJO_REPOSITORY` |
| `REMOTE_NAME` | `REMOTE_FORGEJO_NAME` |
| `REMOTE_DEFAULT_BRANCH` | `REMOTE_FORGEJO_BRANCH` |

`git_update` utilise les valeurs historiques présentes comme valeurs de
transition, puis génère seulement les variables Forgejo. Il ne demande plus
ni ne persiste de sélecteur générique. Le mode `gitlab` continue de générer
uniquement les variables GitLab. Les variables GitLab, GitHub et Clone sont
conservées telles quelles.

`publish_release_diu`, `git_push_docker_image`, `git_init_clone` et les
fonctions de lecture de configuration utilisent la configuration Forgejo
explicite pour leurs opérations Forgejo. Les anciennes lignes de configuration
distante sont retirées de la sortie générée par `git_update`.
