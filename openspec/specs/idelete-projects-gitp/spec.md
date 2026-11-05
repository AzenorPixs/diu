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
La commande `diu projects gitpdiu` DOIT rester disponible.
La commande obsolète `diu projects gitpdi <ID PROJECT>` DOIT être rejetée et
ne DOIT plus être présentée dans les aides CLI.

#### Scenario: parcours générique absent

- **GIVEN** que l'utilisateur demande l'ancien parcours de publication
  générique
- **WHEN** le dispatch traite la demande
- **THEN** aucun push Git n'est exécuté par ce parcours
- **AND** la demande est rejetée comme commande inconnue ou non disponible

#### Scenario: aides avec forgejo_push

- **GIVEN** que l'utilisateur demande une aide globale, `projects` ou
  détaillée
- **WHEN** l'aide est affichée
- **THEN** l'entrée du parcours générique est absente
- **AND** l'entrée `diu projects forgejo push <ID PROJECT>` est disponible
- **AND** l'entrée `gitpdiu` reste affichée lorsqu'elle est applicable
- **AND** l'entrée `gitpdi` est absente

#### Scenario: commande gitpdi obsolète

- **GIVEN** que l'utilisateur exécute `diu projects gitpdi <ID PROJECT>`
- **WHEN** le dispatch traite la commande
- **THEN** aucune publication n'est exécutée
- **AND** la commande est rejetée comme indisponible

### Requirement: conservation des publications dédiées

Le système SHALL conserver les fonctions `forgejo_push`, `gitlab_push` et
`github_push`, leurs commandes dédiées et leurs mécanismes d'authentification.
Elles DOIVENT sélectionner explicitement leur fournisseur sans dépendre d'un
sélecteur distant global.

#### Scenario: publications dédiées

- **GIVEN** qu'une configuration valide existe pour Forgejo, GitLab ou
  GitHub
- **WHEN** la commande dédiée correspondante est exécutée
- **THEN** le dépôt est publié vers le fournisseur demandé
- **AND** les configurations des autres fournisseurs restent inchangées

### Requirement: suppression de l'ancienne fonction

Le code actif SHALL ne plus exposer la fonction `git_push()` ni appeler cette
fonction. Le traitement commun indispensable aux publications dédiées PEUT
être conservé sous un nom interne qui reçoit le fournisseur explicitement.

#### Scenario: parcours CI/CD conservé

- **GIVEN** qu'un flux CI/CD DIU ou Docker nécessite une publication Git
- **WHEN** ce flux est exécuté
- **THEN** il utilise un parcours de publication explicite compatible avec sa
  cible
- **AND** le flux Forgejo utilise `forgejo_push`

### Requirement: conservation de la configuration distante

Lors de l'exécution de `git_update`, le système SHALL conserver toutes les
variables de configuration distante, y compris les variables historiques. Les
migrations éventuelles relèvent des fonctions dédiées aux fournisseurs et ne
sont pas réalisées par la mise à jour Git locale.

#### Scenario: mise à jour Git locale

- **GIVEN** que `project.env` contient des variables distantes historiques
- **WHEN** `git_update <ID PROJECT>` termine avec succès
- **THEN** ces variables sont conservées
- **AND** seules les variables Git locales sont modifiées

### Requirement: renommage des consommateurs Forgejo

Les fonctions Forgejo de projet, de publication de release, de publication
d'image et de clonage SHALL utiliser les variables `REMOTE_FORGEJO_*` prévues
pour leur opération. Aucune fonction de ces parcours ne SHALL nécessiter une
variable générique supprimée.

#### Scenario: release Forgejo

- **GIVEN** que `project.env` contient une configuration Forgejo valide
- **WHEN** `publish_release_diu` est exécutée
- **THEN** elle utilise l'URL, le remote et la branche Forgejo configurés
- **AND** la vérification de type par une variable générique n'est pas requise

### Requirement: non-régression des cycles Git

La modification SHALL préserver les commandes et fonctions de commit, init,
release et update de projet. Elle SHALL préserver les variables
`REMOTE_GITLAB_*` et `REMOTE_GITHUB_*` ainsi que leurs parcours dédiés.

#### Scenario: cycles existants

- **GIVEN** un projet correctement configuré
- **WHEN** les commandes commit, init, release ou update sont exécutées
- **THEN** elles conservent leur comportement prévu
- **AND** aucune d'elles ne dépend de l'ancien parcours générique
