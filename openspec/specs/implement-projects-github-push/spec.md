# implement-projects-github-push Specification

## Purpose
Définir la publication sécurisée d'un dépôt Git local vers un dépôt GitHub
configuré pour un projet DIU.

## Requirements

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

### Requirement: vérification du dépôt GitHub avant publication

Avant de configurer le remote local, le système MUST vérifier par une requête
GitHub authentifiée l'existence du dépôt défini par `REMOTE_GITHUB_OWNER` et
`REMOTE_GITHUB_REPOSITORY`.

#### Scenario: dépôt distant existant

- **WHEN** l'utilisateur exécute `rid projects github push <ID PROJECT>` pour un dépôt GitHub accessible
- **THEN** le système conserve le dépôt distant et poursuit la validation du remote puis le push existants

#### Scenario: vérification inaccessible

- **WHEN** l'API GitHub retourne un statut autre que `200` ou `404`
- **THEN** la commande échoue explicitement sans créer ni modifier de remote local

### Requirement: création confirmée d'un dépôt GitHub absent

Lorsque la vérification GitHub retourne `404`, le système MUST demander une
confirmation explicite avant toute création. Après confirmation, il DOIT
demander une visibilité `private` ou `public`, avec `private` comme valeur par
défaut, puis créer le dépôt sans contenu initial.

#### Scenario: création acceptée

- **WHEN** un dépôt GitHub absent est confirmé avec une visibilité valide
- **THEN** le système crée le dépôt pour le propriétaire configuré et poursuit le flux de publication existant

#### Scenario: création refusée

- **WHEN** l'utilisateur refuse la création d'un dépôt GitHub absent
- **THEN** la commande s'arrête explicitement sans créer ni modifier de remote local

#### Scenario: visibilité invalide

- **WHEN** l'utilisateur confirme la création et saisit une visibilité autre que `private` ou `public`
- **THEN** le système redemande une visibilité valide avant d'envoyer une requête de création

### Requirement: protection du token GitHub pour les appels API

Les appels GitHub nécessaires à la vérification et à la création MUST
utiliser le token sans l'inclure dans une URL, des arguments de commande ou des
journaux. Tout fichier temporaire contenant le token DOIT être en permissions
`600` et supprimé après usage.

#### Scenario: appel API authentifié

- **WHEN** la publication GitHub vérifie ou crée un dépôt
- **THEN** le token est transmis par un mécanisme temporaire protégé et n'apparaît pas dans la sortie de la commande
