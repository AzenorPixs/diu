## MODIFIED Requirements

### Requirement: Fonction d'exécution Git authentifiée

`git_with_token` SHALL exécuter Git sous authentification HTTPS par token,
avec chemin du dépôt, identifiant, token, commande et arguments en paramètres.
La fonction SHALL retourner le code Git original. Hors contexte de push
tolérant, elle SHALL afficher les erreurs sans token. Dans ce contexte, une
panne reconnue SHALL signaler l'indisponibilité à l'appelant sans diagnostic
d'erreur ; les autres échecs SHALL rester explicites.

#### Scenario: Exécution réussie de git fetch

WHEN la fonction est appelée avec un token valide pour `fetch origin`
THEN la commande `git fetch origin` est exécutée avec succès
AND le code de retour 0 est retourné

#### Scenario: Exécution réussie de git push

WHEN la fonction est appelée avec un token valide pour `push origin main`
THEN la commande `git push origin main` est exécutée avec succès
AND le code de retour 0 est retourné

#### Scenario: Échec de la commande Git

WHEN la commande Git échoue hors contexte de push tolérant (réseau, authentification refusée, etc.)
THEN le code de retour non-zéro de Git est propagé
AND un message d'erreur explicite est affiché
AND le message ne contient pas le token
