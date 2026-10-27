## MODIFIED Requirements

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

### Requirement: Authentification Forgejo de forgejo_push()

La fonction `forgejo_push()` SHALL utiliser `forgejo-auth`/`git-auth` pour
exécuter le push HTTPS authentifié.

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

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` est absent
THEN une erreur explicite est affichée indiquant l'absence du token
AND aucun `git push` n'est exécuté
AND aucun bootstrap automatique de token n'est lancé par `forgejo_push()`
AND aucune invite Username/Password n'est affichée
AND la fonction retourne le code 1

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
