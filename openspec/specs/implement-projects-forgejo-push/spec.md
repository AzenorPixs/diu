# implement-projects-forgejo-push Specification

## Purpose
Définir la publication sécurisée d'un dépôt Git local d'un projet DIU vers un
dépôt Forgejo distant configuré.

## Requirements

### Requirement: commande de publication Forgejo

DIU MUST exposer `rid projects forgejo push <ID PROJECT>` et sa variante
`all`. Pour un dépôt existant, il MUST réussir le fetch authentifié avant
le push ; pour un dépôt absent, déléguer la création au premier push sans
fetch ni création API. La branche MUST utiliser `--force-with-lease`, le
tag rester sans forçage et le push démarrer sans confirmation supplémentaire
si configuration et identifiants sont valides. Les échecs MUST respecter
`git-provider-availability`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu` et un dépôt Forgejo existant
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS les références du remote Forgejo configuré sont récupérées avant le
  push de branche
- ET le dépôt local est poussé vers le dépôt Forgejo distant configuré avec
  `--force-with-lease` pour la branche publiée
- ET la branche distante configurée reçoit la branche locale publiée
- ET le tag pointant sur le dernier commit, s'il existe, est publié sans
  option de forçage

#### Scenario: récupération Forgejo en échec

- ÉTANT DONNÉ un dépôt Forgejo existant
- QUAND la récupération authentifiée de ses références échoue pour une cause autre qu'une indisponibilité reconnue
- ALORS la commande échoue explicitement
- ET aucun push de branche ni de tag n'est exécuté

#### Scenario: dépôt distant absent

- ÉTANT DONNÉ le dépôt local du projet `diu` et un dépôt Forgejo distant
  configuré mais absent
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS aucune récupération de références n'est exécutée
- ET aucun appel API de création n'est exécuté
- ET le premier push Git Forgejo crée le dépôt selon la configuration serveur
- ET la branche distante configurée reçoit la branche locale publiée avec
  `--force-with-lease`
- ET le tag pointant sur le dernier commit, s'il existe, est publié sans
  option de forçage

#### Scenario: publication groupée

- ÉTANT DONNÉ plusieurs projets configurés pour Forgejo
- QUAND l'utilisateur exécute `rid projects forgejo push all`
- ALORS chaque projet sélectionné est publié par le parcours Forgejo unitaire

#### Scenario: sélection explicite de Forgejo

- ÉTANT DONNÉ que le projet possède déjà une configuration GitLab ou GitHub
- QUAND l'utilisateur exécute `rid projects forgejo push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur Forgejo
- ET elle utilise ou initialise les variables `REMOTE_FORGEJO_*`
- ET elle ne remplace pas les configurations GitLab ou GitHub

#### Scenario: publication Forgejo sans confirmation

- ÉTANT DONNÉ une configuration Forgejo et des identifiants valides
- QUAND l'utilisateur exécute `rid projects forgejo push <ID PROJECT>`
- ALORS le parcours Forgejo ne demande pas de confirmation avant le push
- ET le push démarre après les vérifications existantes

#### Scenario: Indisponibilité reconnue avant le push

- **WHEN** la vérification du dépôt ou la récupération préalable rencontre une indisponibilité reconnue
- **THEN** aucun push n'est exécuté
- **AND THEN** le résultat public suit git-provider-availability : publication non confirmée, retour zéro et statut interne d'indisponibilité

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

`forgejo_push()` MUST utiliser `config/forgejo.username` et
`config/forgejo.token` (mode `600`, jamais journalisés). Le token MUST passer
à Git uniquement par `git_with_token`. Si un fichier manque, le push MUST
appeler `forgejo_credentials_setup()` avant `forgejo-auth`. Ce setup MUST
obtenir une confirmation explicite avant toute écriture puis demander les
données interactivement. Le provider MUST rester strict : aucune création,
erreur si identifiants absents ou invalides.

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
