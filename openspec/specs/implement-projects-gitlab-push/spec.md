# Fonction de publication GitLab des projets DIU

## Purpose

Définir la publication GitLab des projets DIU et sa configuration associée.

## Requirements

### Requirement: commande de publication GitLab

Le système MUST exposer la commande `rid projects gitlab push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `rid projects gitlab push diu`
- ALORS le dépôt local est poussé vers le dépôt GitLab distant configuré
- ET la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitLab

- ÉTANT DONNÉ que le projet possède déjà une configuration Forgejo
- QUAND l'utilisateur exécute `rid projects gitlab push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur GitLab
- ET elle utilise ou initialise les variables `REMOTE_GITLAB_*`

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

- ÉTANT DONNÉ que la configuration GitLab est absente ou incomplète
- QUAND l'utilisateur lance `rid projects gitlab push <ID PROJECT>`
- ALORS la fonction d'initialisation de configuration est exécutée de manière interactive
- ET les variables GitLab sont demandées puis enregistrées dans `project.env`
- ET le push ne commence qu'après une configuration complète

### Requirement: identifiants GitLab

Le système MUST initialiser et utiliser `config/gitlab.username` et `config/gitlab.token` selon la philosophie Forgejo.

Les deux fichiers DOIVENT être limités aux permissions `600`, ne DOIVENT jamais être affichés dans les journaux, et le token DOIT être transmis à Git uniquement par le mécanisme temporaire existant `git_with_token`.

#### Scenario: identifiants absents

- ÉTANT DONNÉ que les identifiants GitLab n'existent pas
- QUAND un premier push GitLab est demandé
- ALORS l'utilisateur est invité à saisir le nom d'utilisateur et le token GitLab
- ET le token est saisi sans affichage puis confirmé
- ET les fichiers d'identifiants sont créés avec les permissions `600`

#### Scenario: identifiants invalides

- ÉTANT DONNÉ qu'un fichier d'identifiant existe avec des permissions incorrectes ou une valeur vide
- QUAND un push GitLab est demandé
- ALORS la commande échoue explicitement
- ET le contenu de l'identifiant n'est jamais affiché

### Requirement: remote GitLab HTTPS

Le fournisseur GitLab MUST utiliser le remote défini par `REMOTE_GITLAB_NAME`
en HTTPS et refuser un remote ne respectant pas le format
`https://hôte/propriétaire/dépôt.git`.

Le push MUST utiliser le nom du remote et la branche définis dans la configuration GitLab, sans modifier la configuration Git du dépôt en dehors des opérations déjà prévues par la commande de publication.

#### Scenario: remote GitLab conforme

- ÉTANT DONNÉ que le remote GitLab configuré est une URL HTTPS valide
- QUAND un push GitLab est exécuté
- ALORS le push utilise ce remote et la branche configurée
- ET aucune autre configuration Git n'est modifiée

### Requirement: aide CLI

Les niveaux d'aide suivants MUST être disponibles et cohérents :

- `rid help` affiche les commandes de premier niveau et leur description succincte ;
- `rid projects help` affiche les commandes du niveau `projects` et leur description succincte ;
- `rid projects gitlab help` affiche les commandes GitLab et leur description succincte ;
- `rid projects gitlab push help` décrit la publication du dépôt local vers GitLab et rappelle la syntaxe `rid projects gitlab push <ID PROJECT>`.

#### Scenario: aide de publication GitLab

- ÉTANT DONNÉ que l'utilisateur demande l'aide de publication GitLab
- QUAND l'aide est affichée
- ALORS la syntaxe `rid projects gitlab push <ID PROJECT>` est décrite

### Requirement: compatibilité Forgejo

L'ajout de GitLab MUST préserver les variables, le parcours d'initialisation et le comportement existants de la publication Forgejo.

#### Scenario: publication Forgejo préservée

- ÉTANT DONNÉ qu'un projet utilise une configuration Forgejo existante
- QUAND les commandes GitLab sont disponibles
- ALORS le parcours de publication Forgejo reste inchangé
