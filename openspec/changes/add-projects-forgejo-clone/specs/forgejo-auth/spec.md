## MODIFIED Requirements

### Requirement: Appel au cœur générique

Le provider SHALL transmettre au cœur `git-auth` :

- le chemin du dépôt ou de la copie de travail temporaire ;
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

#### Scenario: Délégation d'un clonage temporaire

WHEN un clonage HTTPS authentifié est demandé pour un dépôt Forgejo configuré
THEN le provider lit et valide le token et ses permissions
AND détermine `forgejo_username`
AND transmet les informations au cœur `git-auth`
AND le cœur exécute le clonage sous DEVOPS_USER
AND aucun identifiant ni token n'est enregistré dans la configuration Git
