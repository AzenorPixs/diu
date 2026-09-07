# Proposal: Retrait du parcours Git distant générique

Le projet DIU conserve un parcours historique de publication générique et un
orchestrateur `git_push()` qui sélectionne le fournisseur distant à partir de
variables génériques. Ce parcours est devenu redondant avec `forgejo_push`,
`gitlab_push` et `github_push` et entretient une configuration distante
ambiguë.

Le changement supprime la commande et la fonction historiques. Le traitement
commun nécessaire aux trois fournisseurs est conservé sous un nom interne et
appelé avec un fournisseur explicitement sélectionné par chaque parcours
dédié. `gitpdiu`, les releases et les publications d'images Docker restent
des parcours distincts.

La configuration historique du dépôt distant est migrée lors de `git_update`:
les cinq variables génériques sont reprises dans leurs équivalents Forgejo,
le discriminant générique est abandonné, et aucune des anciennes variables
n'est réécrite dans `project.env`.

## Périmètre

- retirer l'ancien parcours de publication générique du dispatch et de toutes
  les aides ;
- supprimer la fonction publique `git_push()` et conserver les parcours
  `forgejo_push`, `gitlab_push` et `github_push` ;
- remplacer les usages actifs des variables génériques par les variables
  Forgejo correspondantes ;
- faire nettoyer et migrer les anciennes variables par `git_update` ;
- préserver les parcours commit, init, release, update, GitLab, GitHub et
  Forgejo, ainsi que `gitpdiu` et `gitpdi`.

## Hors périmètre

- modification des mécanismes d'authentification des fournisseurs ;
- modification des variables `REMOTE_GITLAB_*`, `REMOTE_GITHUB_*` ou des
  variables `REMOTE_CLONE_*` ;
- conservation des commandes distinctes `gitpdiu` et `gitpdi` ;
- commit, création de branche ou push Git.
