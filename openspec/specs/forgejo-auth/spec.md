# Authentification Forgejo

## Purpose

Fournir un provider d'authentification Git HTTPS spécifique à Forgejo,
gérant la résolution du host, la lecture et la validation du token, et la
transmission au cœur générique `git-auth`.

## Requirements

### Requirement: Déduction du host et du repository Forgejo depuis le remote

Le provider SHALL déduire les informations du repository à partir de l'URL
HTTPS du remote origin du dépôt.

À partir d'une URL de forme `https://<host>/<owner>/<repo>[.git]`, le
provider SHALL extraire :

- `forgejo_host` : le host Forgejo (ex: `forgejo.pixs.fr`)
- `forgejo_owner` : le propriétaire du repository (ex: `rootforgejo`)
- `forgejo_repo` : le nom du repository (ex: `diu`)

Le provider SHALL fonctionner avec toute instance Forgejo accessible via
HTTPS, pas uniquement `forgejo.pixs.fr`.

#### Scenario: URL standard

WHEN l'URL du remote origin est `https://forgejo.pixs.fr/rootforgejo/diu.git`
THEN le host est `forgejo.pixs.fr`
AND le owner est `rootforgejo`
AND le repository est `diu`

#### Scenario: URL sans .git

WHEN l'URL du remote origin est `https://forgejo.example.com/user/project`
THEN le host est `forgejo.example.com`
AND le owner est `user`
AND le repository est `project`

#### Scenario: URL non-HTTPS

WHEN l'URL du remote origin n'est pas une URL HTTPS
THEN le provider retourne une erreur explicite
AND aucune opération Git n'est tentée

#### Scenario: URL malformée

WHEN l'URL du remote origin ne peut pas être décodée
THEN le provider retourne une erreur explicite
AND aucune opération Git n'est tentée

### Requirement: Distinction entre owner du repository et identité d'authentification

Le provider SHALL distinguer et résoudre avant authentification `forgejo_owner`
(propriétaire) et `forgejo_repo` (nom), extraits de l'URL du remote, ainsi que
`forgejo_username` (identité Git HTTPS). Il SHALL obtenir le username
indépendamment du owner, qui peut différer du détenteur du token. Sa source
sera déterminée dans le design : information persistée avec le token,
configuration projet ou autre mécanisme déterministe.

#### Scenario: Owner distinct du username

WHEN le repository appartient à une organisation `monorga`
AND le token est détenu par l'utilisateur `alice`
THEN `forgejo_owner` vaut `monorga`
AND `forgejo_username` vaut `alice`
AND les deux valeurs sont distinctes

#### Scenario: Owner identique au username

WHEN le repository appartient à l'utilisateur `alice`
AND le token est détenu par `alice`
THEN `forgejo_owner` et `forgejo_username` ont la même valeur
AND ils restent des concepts distincts résolus indépendamment

#### Scenario: Username non résolu

WHEN `forgejo_username` ne peut pas être déterminé
THEN le provider retourne une erreur explicite
AND aucune opération Git n'est tentée

### Requirement: Localisation du fichier token

Le provider SHALL localiser le token Forgejo dans le fichier
`<project_path>/config/forgejo.token`.

#### Scenario: Token présent

WHEN `config/forgejo.token` existe dans le projet
THEN le provider lit le contenu du fichier comme token

#### Scenario: Token absent

WHEN `config/forgejo.token` n'existe pas dans le projet
THEN le provider retourne une erreur indiquant l'absence du token
AND aucune opération Git n'est tentée

### Requirement: Validation des permissions du fichier token

Le provider SHALL accepter exactement `600` ou `660` pour le token et le
username locaux avant lecture, dans tous les parcours Git et API existants.
Il SHALL NOT modifier les permissions des fichiers existants. Les autres
modes SHALL être refusés. Les créations restent en `600` et les fichiers
secrets temporaires SHALL conserver leur protection existante.

#### Scenario: Permissions valides

WHEN les permissions de `config/forgejo.token` sont exactement 600 ou 660
THEN le provider utilise le token
AND les permissions et le contenu du fichier restent inchangés

#### Scenario: Permissions invalides

WHEN les permissions de `config/forgejo.token` ne sont ni 600 ni 660
THEN le provider retourne une erreur de sécurité explicite
AND le token n'est pas lu
AND aucune opération Git n'est tentée

#### Scenario: Username partagé

WHEN les permissions de `config/forgejo.username` sont exactement 660
THEN le provider lit le username sans changer son contenu ni ses permissions
AND le mode 600 reste accepté

#### Scenario: Username avec permissions invalides

WHEN les permissions de `config/forgejo.username` ne sont ni 600 ni 660
THEN le provider retourne une erreur avant lecture du username
AND aucun identifiant n'est affiché

### Requirement: Validation du contenu du token

Le provider SHALL vérifier que le fichier token n'est pas vide.

#### Scenario: Token non vide

WHEN le fichier token contient un jeton non vide
THEN le provider utilise ce jeton

#### Scenario: Token vide

WHEN le fichier token est vide
THEN le provider retourne une erreur explicite
AND aucune opération Git n'est tentée

### Requirement: Appel au cœur générique

Le provider SHALL transmettre au cœur `git-auth` :

- le chemin du dépôt ;
- `forgejo_username` (identifiant d'authentification) ;
- le token lu et validé ;
- la commande Git à exécuter.

Le provider ne SHALL jamais exécuter de commande Git directement ; il
délègue systématiquement au cœur `git-auth`.

#### Scenario: Délégation de git fetch

WHEN un `git fetch` authentifié est demandé pour un remote Forgejo
THEN le provider résout le host, lit le token, valide les permissions
AND détermine `forgejo_username`
AND transmet les informations au cœur `git-auth`
AND le cœur exécute `git fetch origin` sous DEVOPS_USER

#### Scenario: Délégation de git push

WHEN un `git push` authentifié est demandé pour un remote Forgejo
THEN le provider résout le host, lit le token, valide les permissions
AND détermine `forgejo_username`
AND transmet les informations au cœur `git-auth`
AND le cœur exécute `git push` sous DEVOPS_USER

### Requirement: Authentification Forgejo de forgejo_push()

Les transports Forgejo SHALL utiliser forgejo-auth/git-auth avec une paire déjà préparée. Ils SHALL vérifier les identifiants et SHALL échouer sans interaction, écriture persistante ni bootstrap si la paire est absente ou invalide. Le setup explicite relève de l'orchestration avant leur appel.

#### Scenario: Push avec token valide

WHEN `forgejo_push()` est exécutée sur un remote Forgejo HTTPS
AND `config/forgejo.token` existe et est valide
AND `config/forgejo.username` existe et est valide
THEN l'existence du dépôt Forgejo est vérifiée avant toute récupération
AND pour un dépôt existant, les références du remote Forgejo nommé sont
récupérées via `forgejo-auth`/`git-auth` avant le push
AND un échec de récupération empêche le push
AND une indisponibilité reconnue est qualifiée selon git-provider-availability
sans annoncer de succès de publication
AND pour un dépôt absent, aucun fetch ni appel API de création n'est exécuté
AND le premier push délègue la création à Forgejo selon
restore-forgejo-push-to-create
AND le `git push` est exécuté via `forgejo-auth`/`git-auth`
AND aucune invite Username/Password n'est affichée
AND aucun credential n'est stocké de manière persistante

#### Scenario: Dépôt absent avec token valide

WHEN `forgejo_push()` est exécutée avec des identifiants valides
AND le dépôt Forgejo distant est absent
THEN aucun `git fetch` ni appel API de création n'est exécuté
AND le premier `git push` est exécuté via `forgejo-auth`/`git-auth`
AND la création dépend de la configuration push-to-create du serveur

#### Scenario: Push sans token

- **WHEN** le transport Forgejo est appelé sans token préparé
- **THEN** il échoue sans fetch ni push, sans invite et sans création de fichiers

#### Scenario: Push avec permissions invalides

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` existe mais ses permissions ne sont ni 600 ni 660
THEN une erreur de sécurité explicite est affichée
AND aucun `git push` n'est exécuté
AND la fonction retourne le code 1

#### Scenario: Push avec token vide

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` existe mais est vide
THEN une erreur explicite est affichée
AND aucun `git push` n'est exécuté
AND la fonction retourne le code 1

Aucun fallback vers l'ancien comportement interactif Username/Password
ne SHALL être introduit.

### Requirement: Aucune exposition du token

Le token ne SHALL jamais être :

- affiché sur la sortie standard ou d'erreur ;
- inclus dans un message d'erreur ;
- écrit dans un fichier persistant ;
- transmis à un processus autre que le cœur `git-auth`.

#### Scenario: Erreur sans token

WHEN une erreur survient dans le provider (token absent, permissions
invalides, URL malformée, username non résolu)
THEN le message d'erreur ne contient pas le token
AND le token n'est pas affiché

### Requirement: Indépendance du provider

Le provider `lib/forgejo-auth.sh` SHALL dépendre uniquement de :

- la fonction `git_with_token` de `modules/projects/git.sh` (cœur générique) ;
- `lib/logging.sh` (affichage) ;
- outils système : `git`, `stat`, `cat`.

Le provider ne SHALL pas dépendre de `modules/projects/forgejo-release.sh`.

#### Scenario: Pas de dépendance circulaire

WHEN le module `lib/forgejo-auth.sh` est lu
THEN il ne source pas `modules/projects/forgejo-release.sh`
AND il ne contient aucune référence à `publish_release`

### Requirement: Non-responsabilité du bootstrap automatique

Le provider et ses transports SHALL rester sans interaction ni création, suppression ou remplacement d'identifiants persistants. Les parcours de push et de release SHALL préparer une paire incomplète par forgejo_credentials_setup après consentement explicite. Une paire existante invalide SHALL être conservée et rejetée.

#### Scenario: Appel depuis forgejo_push() sans token

- **WHEN** le provider est appelé depuis le parcours de push sans paire préparée
- **THEN** le provider échoue sans tenter de setup et sans mutation

#### Scenario: Appel depuis publish_release() avec bootstrap

WHEN `forgejo-auth` est appelé depuis `publish_release()`
AND le token a été préalablement bootstrapé par `publish_release()`
THEN le provider utilise le token existant
AND le provider ne relance pas de bootstrap

#### Scenario: Paire refusée conservée

- **WHEN** une paire existante est refusée par Forgejo avec HTTP 401 ou 403
- **THEN** le parcours échoue sans suppression, remplacement ni demande de nouveau token

### Requirement: Création du dépôt Forgejo absent

Le provider Forgejo SHALL vérifier le dépôt avant récupération : présent
(`200`), il confirme son existence ; absent (`404`), il délègue sa création
au premier push sans création API. Une autre réponse SHALL être une erreur,
qualifiée selon `git-provider-availability` dans le contexte de push tolérant ;
hors contexte, le contrat d'erreur SHALL rester inchangé.

#### Scenario: Dépôt absent

- **WHEN** le dépôt distant est absent
- **THEN** le provider n'effectue aucun appel API de création
- **THEN** le parcours de publication peut réaliser le premier push Git

#### Scenario: Dépôt utilisateur absent

- **WHEN** le dépôt distant est absent et son propriétaire est l'utilisateur
  authentifié
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Dépôt d'organisation absent

- **WHEN** le dépôt distant est absent et son propriétaire est une
  organisation accessible avec le token
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Compte utilisateur distinct

- **WHEN** le dépôt distant est absent et son propriétaire est un compte
  utilisateur différent de l'utilisateur authentifié
- **THEN** le provider délègue sa création au premier push Git Forgejo
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Dépôt existant

- **WHEN** le dépôt distant existe
- **THEN** le provider confirme son existence avant la récupération des
  références

#### Scenario: Vérification refusée

- **WHEN** Forgejo refuse la vérification du dépôt pour une cause autre qu'une indisponibilité reconnue
- **THEN** le provider retourne une erreur explicite
- **THEN** aucune opération Git n'est tentée

#### Scenario: Création refusée

- **WHEN** Forgejo refuse le premier push Git vers le dépôt absent pour une cause autre qu'une indisponibilité reconnue
- **THEN** le provider retourne l'erreur du push Git
- **THEN** aucun appel API de création n'est effectué

#### Scenario: Vérification temporairement indisponible dans un push

- **WHEN** la vérification du dépôt rencontre une indisponibilité reconnue dans le contexte de push tolérant
- **THEN** la publication publique suit git-provider-availability sans création ni push
- **AND THEN** les clones et releases directes conservent leur contrat d'erreur hors de ce contexte
