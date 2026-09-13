# idelete-projects-gitp Specification

## Purpose
Supprimer le parcours Git distant générique du DIU et normaliser la
configuration historique du dépôt distant vers Forgejo, sans régression des
parcours dédiés ni des cycles Git existants.

## Requirements

### Requirement: remplacement du parcours générique

Le système SHALL supprimer l'ancien parcours de publication générique du
dispatch et de toutes les aides CLI, et utiliser `forgejo_push` pour la
publication Forgejo.
La commande `rid projects gitpdiu` DOIT rester disponible.
La commande obsolète `rid projects gitpdi <ID PROJECT>` DOIT être rejetée et
ne DOIT plus être présentée dans les aides CLI.

#### Scenario: parcours générique absent

- ÉTANT DONNÉ que l'utilisateur demande l'ancien parcours de publication
  générique
- QUAND le dispatch traite la demande
- ALORS aucun push Git n'est exécuté par ce parcours
- ET la demande est rejetée comme commande inconnue ou non disponible

#### Scenario: aides avec forgejo_push

- ÉTANT DONNÉ que l'utilisateur demande une aide globale, `projects` ou
  détaillée
- QUAND l'aide est affichée
- ALORS l'entrée du parcours générique est absente
- ET l'entrée `rid projects forgejo push <ID PROJECT>` est disponible
- ET l'entrée `gitpdiu` reste affichée lorsqu'elle est applicable
- ET l'entrée `gitpdi` est absente

#### Scenario: commande gitpdi obsolète

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects gitpdi <ID PROJECT>`
- QUAND le dispatch traite la commande
- ALORS aucune publication n'est exécutée
- ET la commande est rejetée comme indisponible

### Requirement: conservation des publications dédiées

Le système SHALL conserver les fonctions `forgejo_push`, `gitlab_push` et
`github_push`, leurs commandes dédiées et leurs mécanismes d'authentification.
Elles DOIVENT sélectionner explicitement leur fournisseur sans dépendre d'un
sélecteur distant global.

#### Scenario: publications dédiées

- ÉTANT DONNÉ qu'une configuration valide existe pour Forgejo, GitLab ou
  GitHub
- QUAND la commande dédiée correspondante est exécutée
- ALORS le dépôt est publié vers le fournisseur demandé
- ET les configurations des autres fournisseurs restent inchangées

### Requirement: suppression de l'ancienne fonction

Le code actif SHALL ne plus exposer la fonction `git_push()` ni appeler cette
fonction. Le traitement commun indispensable aux publications dédiées PEUT
être conservé sous un nom interne qui reçoit le fournisseur explicitement.

#### Scenario: parcours CI/CD conservé

- ÉTANT DONNÉ qu'un flux CI/CD DIU ou Docker nécessite une publication Git
- QUAND ce flux est exécuté
- ALORS il utilise un parcours de publication explicite compatible avec sa
  cible
- ET le flux Forgejo utilise `forgejo_push`

### Requirement: conservation de la configuration distante

Lors de l'exécution de `git_update`, le système SHALL conserver toutes les
variables de configuration distante, y compris les variables historiques. Les
migrations éventuelles relèvent des fonctions dédiées aux fournisseurs et ne
sont pas réalisées par la mise à jour Git locale.

#### Scenario: mise à jour Git locale

- ÉTANT DONNÉ que `project.env` contient des variables distantes historiques
- QUAND `git_update <ID PROJECT>` termine avec succès
- ALORS ces variables sont conservées
- ET seules les variables Git locales sont modifiées

### Requirement: renommage des consommateurs Forgejo

Les fonctions Forgejo de projet, de publication de release, de publication
d'image et de clonage SHALL utiliser les variables `REMOTE_FORGEJO_*` prévues
pour leur opération. Aucune fonction de ces parcours ne SHALL nécessiter une
variable générique supprimée.

#### Scenario: release Forgejo

- ÉTANT DONNÉ que `project.env` contient une configuration Forgejo valide
- QUAND `publish_release_diu` est exécutée
- ALORS elle utilise l'URL, le remote et la branche Forgejo configurés
- ET la vérification de type par une variable générique n'est pas requise

### Requirement: non-régression des cycles Git

La modification SHALL préserver les commandes et fonctions de commit, init,
release et update de projet. Elle SHALL préserver les variables
`REMOTE_GITLAB_*` et `REMOTE_GITHUB_*` ainsi que leurs parcours dédiés.

#### Scenario: cycles existants

- ÉTANT DONNÉ un projet correctement configuré
- QUAND les commandes commit, init, release ou update sont exécutées
- ALORS elles conservent leur comportement prévu
- ET aucune d'elles ne dépend de l'ancien parcours générique
