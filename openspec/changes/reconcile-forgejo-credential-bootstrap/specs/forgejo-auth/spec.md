## MODIFIED Requirements

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

