# Authentification Git HTTPS

## Purpose

Fournir une primitive générique et agnostique du fournisseur pour exécuter des
commandes Git authentifiées via un token HTTPS temporaire, sans exposer le
secret ni modifier la configuration Git persistante.

## Requirements

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

### Requirement: Exécution sous ENV_DEVOPS_USER

Toute commande Git authentifiée SHALL être exécutée sous l'utilisateur
système `ENV_DEVOPS_USER` via `runuser`.

Le processus Git enfant SHALL appartenir à `ENV_DEVOPS_USER`.

#### Scenario: Exécution sous le bon utilisateur

WHEN une commande Git authentifiée est exécutée
THEN le processus Git s'exécute sous l'identité de ENV_DEVOPS_USER
AND les fichiers créés dans le dépôt appartiennent à ENV_DEVOPS_USER

### Requirement: Mécanisme d'authentification éphémère

Le mécanisme Git HTTPS SHALL être éphémère et fournir le token temporairement.
Il SHALL NOT modifier l'URL origin, y introduire un token, écrire celui-ci dans
`.git/config` ou la configuration Git globale de l'utilisateur, ni utiliser de
credential store persistant. Le design SHALL justifier le mécanisme retenu
(credential helper éphémère, `GIT_ASKPASS` temporaire ou configuration via `-c`).

#### Scenario: Remote non modifié

WHEN une commande Git authentifiée est exécutée
THEN l'URL du remote origin n'est pas modifiée
AND `.git/config` ne contient pas le token après exécution

#### Scenario: Aucun credential store persistant

WHEN une commande Git authentifiée est exécutée
THEN aucun fichier de credentials persistant n'est créé
AND aucune entrée n'est ajoutée dans un credential manager

#### Scenario: Pas de secret dans l'URL

WHEN une commande Git authentifiée est exécutée
THEN le remote origin ne contient pas de token dans son URL
AND `git remote get-url origin` retourne l'URL d'origine inaltérée

### Requirement: Protection du token contre l'exposition

Le token SHALL NOT apparaître dans la sortie de `ps`, `/proc/*/cmdline`, les
sorties standard ou d'erreur, ni les messages d'erreur. Le mécanisme SHALL
privilégier une approche minimisant son exposition dans les arguments de
processus (fichier temporaire protégé, variable d'environnement ou pipe).

#### Scenario: Token absent de ps

WHEN une commande Git authentifiée est en cours d'exécution
THEN la commande `ps` ne contient pas le token en clair dans les arguments

#### Scenario: Token absent des messages d'erreur

WHEN une commande Git authentifiée échoue
THEN le message d'erreur ne contient pas le token

### Requirement: Nettoyage systématique des ressources temporaires

Toute ressource temporaire contenant ou référençant le token SHALL être
supprimée après chaque exécution de commande Git, qu'elle ait réussi ou échoué.

Les fichiers temporaires SHALL être créés avec des permissions restrictives
(600) avant d'y écrire le token.

#### Scenario: Nettoyage après succès

WHEN une commande Git authentifiée se termine avec succès
THEN toutes les ressources temporaires liées au token sont supprimées

#### Scenario: Nettoyage après échec

WHEN une commande Git authentifiée échoue
THEN toutes les ressources temporaires liées au token sont supprimées
AND aucun fichier temporaire contenant le token ne subsiste

#### Scenario: Permissions restrictives

WHEN un fichier temporaire est créé pour le mécanisme d'authentification
THEN ses permissions sont exactement 600

### Requirement: Comportement fail-closed

En cas d'échec de l'établissement de l'authentification, la fonction SHALL
appliquer un comportement fail-closed.

Aucun fallback silencieux vers une authentification interactive
(Username/Password) ne SHALL être tenté.

La fonction SHALL retourner un code d'erreur explicite.

#### Scenario: Token vide

WHEN le token fourni est vide
THEN la commande Git n'est pas exécutée
AND un message d'erreur explicite est affiché
AND la fonction retourne le code 1

#### Scenario: Paramètres manquants

WHEN les paramètres obligatoires (chemin, utilisateur, token) sont manquants
THEN la commande Git n'est pas exécutée
AND un message d'erreur explicite est affiché
AND la fonction retourne le code 1

#### Scenario: Pas de fallback interactif

WHEN l'authentification échoue
THEN aucune invite Username/Password n'est affichée
AND aucune tentative de saisie interactive n'est déclenchée

### Requirement: Extensibilité multi-fournisseur

La fonction `git_with_token`, définie dans `modules/projects/git.sh`, SHALL
rester entièrement agnostique du fournisseur de forge.

La fonction ne SHALL contenir aucune logique spécifique à Forgejo, GitHub
ou GitLab.

Toute la logique spécifique à un fournisseur SHALL être encapsulée dans
le module provider correspondant (`lib/forgejo-auth.sh`, etc.).

#### Scenario: Indépendance du cœur

WHEN la fonction `git_with_token` de `modules/projects/git.sh` est lue
THEN elle ne contient aucune référence à un fournisseur spécifique
AND elle ne contient aucune dépendance vers `lib/forgejo-auth.sh`
