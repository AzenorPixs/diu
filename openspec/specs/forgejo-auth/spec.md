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

Le provider SHALL distinguer explicitement :

- `forgejo_owner` : le propriétaire du repository (extrait de l'URL du remote) ;
- `forgejo_repo` : le nom du repository (extrait de l'URL du remote) ;
- `forgejo_username` : l'identifiant utilisé pour l'authentification Git HTTPS.

`forgejo_username` SHALL être obtenu indépendamment de `forgejo_owner`.

Le owner du repository n'est pas nécessairement l'utilisateur qui possède le
token (cas d'un dépôt appartenant à une organisation).

La source exacte de `forgejo_username` sera déterminée dans le design (parmi :
information persistée avec le token, configuration projet, ou autre mécanisme
déterministe).

La spec exige que les trois valeurs soient résolues avant toute opération
d'authentification.

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

Le provider SHALL vérifier que les permissions du fichier token sont
exactement `600` avant de l'utiliser.

Le provider ne SHALL jamais corriger silencieusement les permissions.

#### Scenario: Permissions valides

WHEN les permissions de `config/forgejo.token` sont exactement 600
THEN le provider utilise le token

#### Scenario: Permissions invalides

WHEN les permissions de `config/forgejo.token` ne sont pas 600
THEN le provider retourne une erreur de sécurité explicite
AND le token n'est pas lu
AND aucune opération Git n'est tentée

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

La fonction `forgejo_push()` SHALL utiliser `forgejo-auth`/`git-auth` pour
exécuter le push HTTPS authentifié.

#### Scenario: Push avec token valide

WHEN `forgejo_push()` est exécutée sur un remote Forgejo HTTPS
AND `config/forgejo.token` existe et est valide
AND `config/forgejo.username` existe et est valide
THEN le `git push` est exécuté via `forgejo-auth`/`git-auth`
AND aucune invite Username/Password n'est affichée
AND aucun credential n'est stocké de manière persistante

#### Scenario: Push sans token

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` est absent
THEN une erreur explicite est affichée indiquant l'absence du token
AND aucun `git push` n'est exécuté
AND aucun bootstrap automatique de token n'est lancé par `forgejo_push()`
AND aucune invite Username/Password n'est affichée
AND la fonction retourne le code 1

#### Scenario: Push avec permissions invalides

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` existe mais ses permissions ne sont pas 600
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

- `lib/git-auth.sh` (cœur générique) ;
- `lib/logging.sh` (affichage) ;
- outils système : `git`, `stat`, `cat`.

Le provider ne SHALL pas dépendre de `modules/projects/forgejo-release.sh`.

#### Scenario: Pas de dépendance circulaire

WHEN le module `lib/forgejo-auth.sh` est lu
THEN il ne source pas `modules/projects/forgejo-release.sh`
AND il ne contient aucune référence à `publish_release`

### Requirement: Non-responsabilité du bootstrap automatique

Le provider `forgejo-auth` ne SHALL jamais créer automatiquement un token
Forgejo.

Le bootstrap automatique reste la responsabilité de l'orchestrateur
(`publish_release()` dans ce change).

Lorsqu'une fonction autre que `publish_release()` utilise `forgejo-auth` et
que le token est absent, le provider SHALL retourner une erreur sans tenter
de bootstrap.

#### Scenario: Appel depuis forgejo_push() sans token

WHEN `forgejo-auth` est appelé depuis `forgejo_push()`
AND `config/forgejo.token` est absent
THEN le provider retourne une erreur
AND aucun bootstrap n'est tenté

#### Scenario: Appel depuis publish_release() avec bootstrap

WHEN `forgejo-auth` est appelé depuis `publish_release()`
AND le token a été préalablement bootstrapé par `publish_release()`
THEN le provider utilise le token existant
AND le provider ne relance pas de bootstrap
