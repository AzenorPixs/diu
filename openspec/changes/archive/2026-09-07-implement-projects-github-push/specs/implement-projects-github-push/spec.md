# Fonction de publication GitHub des projets DIU

## ADDED Requirements

### Requirement: commande de publication GitHub

Le système MUST exposer la commande `rid projects github push <ID PROJECT>`.

Le système DOIT exposer la commande `rid projects github push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `rid projects github push diu`
- ALORS le dépôt local est poussé vers le dépôt GitHub distant configuré
- ET la branche distante configurée reçoit la branche locale publiée

#### Scenario: sélection explicite de GitHub

- ÉTANT DONNÉ que le projet possède déjà une configuration Forgejo ou GitLab
- QUAND l'utilisateur exécute `rid projects github push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur GitHub
- ET elle utilise ou initialise les variables `REMOTE_GITHUB_*`
- ET elle ne remplace pas la configuration des autres fournisseurs

### Requirement: configuration GitHub du projet

La configuration GitHub MUST utiliser les variables `REMOTE_GITHUB_*` dans
`project.env`.

La configuration GitHub DOIT utiliser les variables suivantes dans
`project.env` :

```bash
REMOTE_GITHUB_BASE_URL=
REMOTE_GITHUB_OWNER=
REMOTE_GITHUB_REPOSITORY="<ID PROJECT>"
REMOTE_GITHUB_NAME="origin"
REMOTE_GITHUB_BRANCH="main"
```

`REMOTE_GITHUB_REPOSITORY` DOIT prendre par défaut l'identifiant du projet.
`REMOTE_GITHUB_NAME` DOIT prendre par défaut `origin` et
`REMOTE_GITHUB_BRANCH` DOIT prendre par défaut `main`.

#### Scenario: initialisation au premier push

- ÉTANT DONNÉ que la configuration GitHub est absente ou incomplète
- QUAND l'utilisateur lance `rid projects github push <ID PROJECT>`
- ALORS `github_update()` est exécutée de manière interactive
- ET les variables GitHub sont demandées puis enregistrées dans `project.env`
- ET le push ne commence qu'après une configuration complète

### Requirement: identifiants GitHub

Le système MUST initialiser et utiliser les identifiants GitHub locaux avec
des permissions restrictives.

Le système DOIT initialiser et utiliser `config/github.username` et
`config/github.token` selon le parcours sécurisé des autres fournisseurs.

Les deux fichiers DOIVENT être limités aux permissions `600`, ne DOIVENT
jamais être affichés dans les journaux et le token DOIT être transmis à Git
uniquement par le mécanisme temporaire existant `git_with_token`.

#### Scenario: identifiants absents

- ÉTANT DONNÉ que les identifiants GitHub n'existent pas
- QUAND un premier push GitHub est demandé
- ALORS l'utilisateur est invité à saisir le nom d'utilisateur et le token
- ET le token est saisi sans affichage puis confirmé
- ET les fichiers d'identifiants sont créés avec les permissions `600`

#### Scenario: identifiants invalides

- ÉTANT DONNÉ qu'un fichier d'identifiant existe avec des permissions
  incorrectes ou une valeur vide
- QUAND un push GitHub est demandé
- ALORS la commande échoue explicitement
- ET le contenu de l'identifiant n'est jamais affiché

### Requirement: remote GitHub HTTPS

Le provider GitHub DOIT utiliser le remote défini par
`REMOTE_GITHUB_NAME` et refuser un remote dont l'URL ne respecte pas le
format `https://hôte/propriétaire/dépôt.git`.

Si le remote configuré n'existe pas, il DOIT être ajouté avec l'URL dérivée de
`REMOTE_GITHUB_BASE_URL`, `REMOTE_GITHUB_OWNER` et
`REMOTE_GITHUB_REPOSITORY`. S'il existe avec une autre URL, la commande DOIT
échouer sans l'écraser.

Le provider GitHub MUST validate the configured remote before publishing.

#### Scenario: remote GitHub absent

- ÉTANT DONNÉ que le remote `REMOTE_GITHUB_NAME` n'existe pas
- QUAND un push GitHub est demandé
- ALORS le remote est ajouté avec l'URL GitHub déclarée
- ET la publication utilise ce remote

#### Scenario: remote GitHub incohérent

- ÉTANT DONNÉ que le remote configuré possède une autre URL
- QUAND un push GitHub est demandé
- ALORS la commande échoue explicitement
- ET aucun remote existant n'est écrasé

### Requirement: aide CLI

Les aides GitHub MUST décrire les commandes disponibles et leur syntaxe.

#### Scenario: aide GitHub

- ÉTANT DONNÉ que l'utilisateur demande `rid projects github help`
- QUAND l'aide est affichée
- ALORS `push` et `update` sont listés

Les niveaux d'aide suivants DOIVENT être disponibles et cohérents :

- `rid help` affiche les commandes de premier niveau et leur description
  succincte ;
- `rid projects help` affiche les commandes du niveau `projects` et leur
  description succincte, dont `github` ;
- `rid projects github help` affiche `push` et `update` ;
- `rid projects github push help` décrit la publication et rappelle la syntaxe
  `rid projects github push <ID PROJECT>`.

### Requirement: compatibilité

L'ajout de GitHub MUST préserver les parcours Forgejo et GitLab existants.

#### Scenario: conservation des fournisseurs existants

- ÉTANT DONNÉ qu'un parcours Forgejo ou GitLab existant est utilisé
- QUAND la publication GitHub est ajoutée
- ALORS le comportement du parcours existant reste inchangé

L'ajout de GitHub DOIT préserver les variables, l'initialisation et le
comportement existants de la publication Forgejo et GitLab.
