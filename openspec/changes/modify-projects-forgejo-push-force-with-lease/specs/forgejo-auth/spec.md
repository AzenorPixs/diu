## MODIFIED Requirements

### Requirement: Authentification Forgejo de forgejo_push()

La fonction `forgejo_push()` SHALL utiliser `forgejo-auth`/`git-auth` pour
exécuter le push HTTPS authentifié.

#### Scenario: Push avec token valide

WHEN `forgejo_push()` est exécutée sur un remote Forgejo HTTPS
AND `config/forgejo.token` existe et est valide
AND `config/forgejo.username` existe et est valide
THEN les références du remote Forgejo nommé sont récupérées via
`forgejo-auth`/`git-auth` avant le push
AND le `git push` est exécuté via `forgejo-auth`/`git-auth`
AND aucune invite Username/Password n'est affichée
AND aucun credential n'est stocké de manière persistante

#### Scenario: Push sans token

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` est absent
THEN une erreur explicite est affichée indiquant l'absence du token
AND aucun `git fetch` ni `git push` n'est exécuté
AND aucun bootstrap automatique de token n'est lancé par `forgejo_push()`
AND aucune invite Username/Password n'est affichée
AND la fonction retourne le code 1

#### Scenario: Push avec permissions invalides

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` existe mais ses permissions ne sont pas 600
THEN une erreur de sécurité explicite est affichée
AND aucun `git fetch` ni `git push` n'est exécuté
AND la fonction retourne le code 1

#### Scenario: Push avec token vide

WHEN `forgejo_push()` est exécutée
AND `config/forgejo.token` existe mais est vide
THEN une erreur explicite est affichée
AND aucun `git fetch` ni `git push` n'est exécuté
AND la fonction retourne le code 1
