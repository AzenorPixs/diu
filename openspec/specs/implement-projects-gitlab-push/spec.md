# Fonction de publication GitLab des projets DIU

## Purpose

Définir la publication GitLab des projets DIU et sa configuration associée.

## Requirements

### Requirement: commande de publication GitLab

Le système MUST exposer la commande `diu projects gitlab push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- **GIVEN** le dépôt local du projet `diu`
- **WHEN** l'utilisateur exécute `diu projects gitlab push diu`
- **THEN** le dépôt local est poussé vers le dépôt GitLab distant configuré
- **AND** la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitLab

- **GIVEN** que le projet possède déjà une configuration Forgejo
- **WHEN** l'utilisateur exécute `diu projects gitlab push <ID PROJECT>`
- **THEN** la commande sélectionne explicitement le fournisseur GitLab
- **AND** elle utilise ou initialise les variables `REMOTE_GITLAB_*`

### Requirement: configuration GitLab du projet

La configuration du projet MUST utiliser les variables suivantes dans `project.env` :

```bash
REMOTE_GITLAB_BASE_URL='https://gitlab.example'
REMOTE_GITLAB_OWNER='owner'
REMOTE_GITLAB_REPOSITORY='diu'
REMOTE_GITLAB_NAME='origin'
REMOTE_GITLAB_BRANCH='main'
```

`REMOTE_GITLAB_REPOSITORY` DOIT prendre par défaut la valeur de l'identifiant du projet. `REMOTE_GITLAB_NAME` DOIT prendre par défaut `origin` et `REMOTE_GITLAB_BRANCH` DOIT prendre par défaut `main`.

#### Scenario: initialisation au premier push

- **GIVEN** que la configuration GitLab est absente ou incomplète
- **WHEN** l'utilisateur lance `diu projects gitlab push <ID PROJECT>`
- **THEN** la fonction d'initialisation de configuration est exécutée de manière interactive
- **AND** les variables GitLab sont demandées puis enregistrées dans `project.env`
- **AND** le push ne commence qu'après une configuration complète

### Requirement: identifiants GitLab

Le système MUST initialiser et utiliser `config/gitlab.username` et `config/gitlab.token` selon la philosophie Forgejo.

Les deux fichiers MUST être limités aux permissions exactes `600` ou `660`, MUST NOT être affichés dans les journaux, et le token MUST être transmis à Git uniquement par le mécanisme temporaire existant `git_with_token`.

#### Scenario: identifiants absents

- **GIVEN** que les identifiants GitLab n'existent pas
- **WHEN** un premier push GitLab est demandé
- **THEN** l'utilisateur est invité à saisir le nom d'utilisateur et le token GitLab
- **AND** le token est saisi sans affichage puis confirmé
- **AND** les fichiers d'identifiants sont créés avec les permissions `600`

#### Scenario: identifiants invalides

- **GIVEN** qu'un fichier d'identifiant existe avec des permissions incorrectes ou une valeur vide
- **WHEN** un push GitLab est demandé
- **THEN** la commande échoue explicitement
- **AND** le contenu de l'identifiant n'est jamais affiché

#### Scenario: Identifiants partagés existants

- **WHEN** `config/gitlab.username` et `config/gitlab.token` sont non vides et ont chacun le mode exact `600` ou `660`
- **THEN** les lecteurs les acceptent dans les parcours Git et API existants
- **AND** leurs contenus et leurs permissions restent inchangés
- **AND** les autres modes sont refusés avant lecture sans affichage des identifiants
- **AND** la protection des secrets temporaires reste inchangée

### Requirement: remote GitLab HTTPS

Le fournisseur GitLab MUST utiliser le remote défini par `REMOTE_GITLAB_NAME`
en HTTPS et refuser un remote ne respectant pas le format
`https://hôte/propriétaire/dépôt.git`.

Le push MUST utiliser le nom du remote et la branche définis dans la configuration GitLab, sans modifier la configuration Git du dépôt en dehors des opérations déjà prévues par la commande de publication.

#### Scenario: remote GitLab conforme

- **GIVEN** que le remote GitLab configuré est une URL HTTPS valide
- **WHEN** un push GitLab est exécuté
- **THEN** le push utilise ce remote et la branche configurée
- **AND** aucune autre configuration Git n'est modifiée

### Requirement: aide CLI

Les niveaux d'aide suivants MUST être disponibles et cohérents :

- `diu help` affiche les commandes de premier niveau et leur description succincte ;
- `diu projects help` affiche les commandes du niveau `projects` et leur description succincte ;
- `diu projects gitlab help` affiche les commandes GitLab et leur description succincte ;
- `diu projects gitlab push help` décrit la publication du dépôt local vers GitLab et rappelle la syntaxe `diu projects gitlab push <ID PROJECT>`.

#### Scenario: aide de publication GitLab

- **GIVEN** que l'utilisateur demande l'aide de publication GitLab
- **WHEN** l'aide est affichée
- **THEN** la syntaxe `diu projects gitlab push <ID PROJECT>` est décrite

### Requirement: compatibilité Forgejo

L'ajout de GitLab MUST préserver les variables, le parcours d'initialisation et le comportement existants de la publication Forgejo.

#### Scenario: publication Forgejo préservée

- **GIVEN** qu'un projet utilise une configuration Forgejo existante
- **WHEN** les commandes GitLab sont disponibles
- **THEN** le parcours de publication Forgejo reste inchangé

### Requirement: serveur temporairement indisponible pendant la publication

La commande publique de push MUST appliquer le contrat de
`git-provider-availability` aux opérations réseau de sa publication. Une
indisponibilité reconnue MUST produire un statut non bloquant, sans être
présentée comme une publication réussie. Les erreurs non qualifiées MUST
conserver leur comportement antérieur.

#### Scenario: fournisseur inaccessible

- **WHEN** une opération réseau du push rencontre une indisponibilité reconnue
- **THEN** la commande affiche une publication non confirmée et retourne zéro

#### Scenario: refus de publication

- **WHEN** Git refuse le push pour une cause autre qu'une indisponibilité reconnue
- **THEN** la commande échoue explicitement
