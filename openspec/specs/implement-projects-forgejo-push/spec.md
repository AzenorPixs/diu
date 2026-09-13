# implement-projects-forgejo-push Specification

## Purpose
Définir la publication sécurisée d'un dépôt Git local d'un projet DIU vers un
dépôt Forgejo distant configuré.

## Requirements

### Requirement: commande de publication Forgejo

Le système MUST exposer la commande `rid projects forgejo push <ID PROJECT>`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS le dépôt local est poussé vers le dépôt Forgejo distant configuré
- ET la branche distante configurée reçoit la branche locale publiée
- ET le tag pointant sur le dernier commit, s'il existe, est publié

#### Scenario: sélection explicite de Forgejo

- ÉTANT DONNÉ que le projet possède déjà une configuration GitLab ou GitHub
- QUAND l'utilisateur exécute `rid projects forgejo push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur Forgejo
- ET elle utilise ou initialise les variables `REMOTE_FORGEJO_*`
- ET elle ne remplace pas les configurations GitLab ou GitHub

### Requirement: configuration Forgejo du projet

La configuration Forgejo MUST utiliser les variables suivantes dans
`project.env` :

```bash
REMOTE_FORGEJO_BASE_URL=
REMOTE_FORGEJO_OWNER=
REMOTE_FORGEJO_REPOSITORY="<ID PROJECT>"
REMOTE_FORGEJO_NAME="origin"
REMOTE_FORGEJO_BRANCH="main"
REMOTE_FORGEJO_SSL_VERIFY="No"
```

`REMOTE_FORGEJO_REPOSITORY` DOIT prendre par défaut l'identifiant du projet,
`REMOTE_FORGEJO_NAME` DOIT prendre par défaut `origin` et
`REMOTE_FORGEJO_BRANCH` DOIT prendre par défaut `main`.

#### Scenario: initialisation au premier push

- ÉTANT DONNÉ que la configuration Forgejo est absente ou incomplète
- QUAND l'utilisateur lance `rid projects forgejo push <ID PROJECT>`
- ALORS `forgejo_update()` est exécutée de manière interactive
- ET les variables Forgejo sont demandées puis enregistrées dans `project.env`
- ET le push ne commence qu'après une configuration complète

### Requirement: identifiants Forgejo

Le système MUST utiliser `config/forgejo.username` et
`config/forgejo.token` selon le parcours sécurisé Forgejo existant. Lorsque
l'un de ces fichiers est absent, `forgejo_push()` MUST déléguer leur création
à la fonction dédiée `forgejo_credentials_setup()` avant d'appeler
`forgejo-auth`.

`forgejo_credentials_setup()` MUST demander une confirmation explicite avant
toute écriture, puis demander les informations nécessaires de manière
interactive. `forgejo-auth` reste strict : il ne crée aucun identifiant et
retourne une erreur lorsque les identifiants attendus sont absents ou invalides.

Les deux fichiers DOIVENT avoir les permissions `600`, ne DOIVENT jamais être
affichés dans les journaux et le token DOIT être transmis à Git uniquement par
`git_with_token`.

#### Scenario: identifiants absents

- ÉTANT DONNÉ que les identifiants Forgejo n'existent pas
- QUAND un premier push Forgejo est demandé
- ALORS `forgejo_push()` appelle `forgejo_credentials_setup()`
- ET la fonction demande la confirmation de l'utilisateur
- ET le parcours d'initialisation demande les informations requises après confirmation
- ET les fichiers d'identifiants sont créés avec les permissions `600`
- ET le push n'est tenté qu'après validation des identifiants

#### Scenario: initialisation des identifiants refusée

- ÉTANT DONNÉ que les identifiants Forgejo n'existent pas
- QUAND `forgejo_credentials_setup()` est refusée par l'utilisateur
- ALORS aucun fichier d'identifiant n'est créé
- ET `forgejo-auth` n'est pas appelé
- ET aucun push n'est tenté

#### Scenario: identifiants invalides

- ÉTANT DONNÉ qu'un fichier d'identifiant existe avec des permissions
  incorrectes ou une valeur vide
- QUAND un push Forgejo est demandé
- ALORS la commande échoue explicitement
- ET le contenu de l'identifiant n'est jamais affiché

### Requirement: remote Forgejo HTTPS

Le remote nommé par `REMOTE_FORGEJO_NAME` MUST utiliser une URL construite
depuis `REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER` et
`REMOTE_FORGEJO_REPOSITORY`, au format
`https://<hôte>/<propriétaire>/<dépôt>.git`.

Si le remote n'existe pas, il DOIT être ajouté. S'il existe avec une autre URL,
la commande DOIT échouer sans l'écraser.

#### Scenario: remote absent ou incohérent

- ÉTANT DONNÉ que le remote nommé par `REMOTE_FORGEJO_NAME` est absent ou
  possède une URL différente de celle déclarée
- QUAND un push Forgejo est demandé
- ALORS le remote absent est ajouté avec l'URL déclarée
- ET un remote incohérent provoque une erreur sans être écrasé

### Requirement: vérification TLS Forgejo

`REMOTE_FORGEJO_SSL_VERIFY` MUST accepter `Yes` ou `No` et prendre `No` par
défaut. La valeur `No` DOIT désactiver la vérification TLS uniquement pour les
opérations Forgejo authentifiées. Une valeur différente DOIT provoquer un
échec explicite.

#### Scenario: vérification TLS désactivée

- ÉTANT DONNÉ que `REMOTE_FORGEJO_SSL_VERIFY=No`
- QUAND une opération Forgejo authentifiée est exécutée
- ALORS la vérification TLS est désactivée pour cette opération uniquement

### Requirement: aide CLI

Les niveaux d'aide suivants MUST être disponibles et cohérents :

- `rid help` affiche les commandes de premier niveau et leur description
  succincte ;
- `rid projects help` affiche les commandes du niveau `projects`, dont
  `forgejo` ;
- `rid projects forgejo help` affiche `push` et `update` ;
- `rid projects forgejo push help` décrit la publication et rappelle la
  syntaxe `rid projects forgejo push <ID PROJECT>`.

#### Scenario: aide de publication

- ÉTANT DONNÉ que l'utilisateur demande `rid projects forgejo push help`
- QUAND l'aide est affichée
- ALORS la description de la publication et sa syntaxe sont affichées

### Requirement: compatibilité

L'ajout du parcours dédié Forgejo MUST préserver les variables et les
comportements existants des publications Forgejo historique, GitLab et GitHub.

#### Scenario: conservation des fournisseurs

- ÉTANT DONNÉ qu'une publication historique Forgejo, GitLab ou GitHub est
  utilisée
- QUAND le parcours Forgejo dédié est ajouté
- ALORS les variables et le comportement du parcours utilisé sont conservés
