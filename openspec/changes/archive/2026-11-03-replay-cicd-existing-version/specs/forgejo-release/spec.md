## MODIFIED Requirements

### Requirement: Vérification Git avant publication

La fonction SHALL conserver les contrôles Git préalables et la politique de
bootstrap ci-dessous, en acceptant les tokens existants en `600` ou `660`. Lors du rejeu isolé, le commit du tag MAY être un ancêtre vérifié de la branche distante sans modifier cette dernière.

#### Scenario: Contrôles préalables conservés

WHEN une publication Forgejo est demandée
THEN les contrôles suivants restent obligatoires.

Avant toute publication Forgejo, la fonction SHALL vérifier que le
dépôt local est dans un état valide pour la publication.

La séquence obligatoire de la phase Git SHALL être :

1. validation du projet et du paquet ;
2. déduction des informations Forgejo depuis le remote (host, owner, repo) ;
3. vérification de l'existence de `config/forgejo.token` ;
4. politique d'accès au token (voir ci-dessous) ;
5. `git fetch origin` exécuté via `forgejo-auth`/`git-auth` avec le token ;
6. vérification HEAD == origin/main, ou ancêtre vérifié en rejeu isolé ;
7. réutilisation du même token validé pour les appels API Release
   (vérification tag, création Release, upload asset).

**Politique d'accès au token :**

Le setup explicite SHALL être proposé uniquement lorsque la paire locale
est absente ou incomplète, après contrôle des fichiers déjà présents.
Il SHALL obtenir le consentement avant écriture et préserver la moitié existante.

Les fichiers déjà présents SHALL être contrôlés localement avant setup.
Une paire complète refusée, un fichier vide ou un mode invalide SHALL
provoquer un échec sans setup. Une paire partielle dont le fichier restant
est localement valide SHALL pouvoir être complétée après consentement,
sans remplacement ; la validation distante SHALL précéder la publication.

| État local pertinent                    | Comportement                                      |
|------------------------------------------|---------------------------------------------------|
| Paire absente ou incomplète               | Setup explicite après consentement                    |
| Paire complète, modes 600 ou 660, contenus valides | Utilisation directe                               |
| Présent, permissions autres que 600 ou 660               | Fail-closed, erreur explicite, aucun bootstrap    |
| Présent, contenu vide                    | Fail-closed, erreur explicite, aucun bootstrap    |
| Présent, token refusé par Forgejo        | Fail-closed, erreur explicite, aucun bootstrap    |

Dans tous les cas, aucun fallback silencieux vers Username/Password
interactif ne SHALL être introduit.

Le setup reste la responsabilité du parcours de release via forgejo_credentials_setup.
Le provider `forgejo-auth` ne relance jamais de bootstrap.

Les vérifications Git obligatoires sont :

- le projet est un dépôt Git valide
- le remote origin existe
- la branche courante est main
- origin/main existe
- HEAD et origin/main pointent sur le même commit après fetch, sauf ancêtre vérifié en rejeu isolé authentifié

#### Scenario: Séquence complète avec token existant et valide

WHEN le dépôt est un dépôt Git valide
AND origin existe et est HTTPS
AND la branche courante est main
AND `config/forgejo.token` existe avec des permissions 600 ou 660 et un contenu non vide
AND le token est accepté par Forgejo
THEN les informations Forgejo sont déduites depuis le remote
AND le token est lu et validé
AND `git fetch origin` est exécuté via forgejo-auth/git-auth
AND HEAD == origin/main est vérifié après fetch
AND le même token est réutilisé pour les appels API Release
AND aucune invite Username/Password n'est affichée

#### Scenario: Dépôt synchronisé

WHEN le dépôt est un dépôt Git valide
AND origin existe et est HTTPS
AND la branche courante est main
AND origin/main existe
AND `git fetch origin` authentifié est exécuté avec succès
AND HEAD et origin/main pointent sur le même commit après fetch
THEN la vérification passe avec succès
AND la fonction continue vers la réutilisation du token pour les appels API Release
AND aucune invite Username/Password n'est affichée

#### Scenario: Fichier token absent — bootstrap automatique

WHEN le dépôt est un dépôt Git valide
AND origin existe et est HTTPS
AND la branche courante est main
AND `config/forgejo.token` n'existe pas
THEN `publish_release()` propose le bootstrap automatique du token

#### Scenario: Bootstrap accepté et réussi

WHEN l'utilisateur accepte le bootstrap automatique
AND le bootstrap Forgejo réussit
THEN le token est créé et enregistré dans `config/forgejo.token`
AND les permissions sont 600
AND `git fetch origin` est exécuté via forgejo-auth/git-auth
AND HEAD == origin/main est vérifié après fetch
AND le même token est réutilisé pour les appels API Release

#### Scenario: Bootstrap refusé par l'utilisateur

WHEN `config/forgejo.token` est absent
AND l'utilisateur refuse le bootstrap automatique
THEN la fonction affiche une erreur
AND aucun fetch ni publication n'est tenté
AND la fonction retourne le code 1

#### Scenario: Fichier token présent mais permissions invalides

WHEN `config/forgejo.token` existe
AND ses permissions ne sont ni 600 ni 660
THEN la fonction affiche une erreur de sécurité explicite
AND aucun bootstrap automatique n'est tenté
AND aucun `git fetch` n'est exécuté
AND aucun fallback interactif n'est tenté
AND la fonction retourne le code 1

#### Scenario: Fichier token présent mais vide

WHEN `config/forgejo.token` existe
AND ses permissions sont 600
AND son contenu est vide
THEN la fonction affiche une erreur explicite
AND aucun bootstrap automatique n'est tenté
AND aucun `git fetch` n'est exécuté
AND aucun fallback interactif n'est tenté
AND la fonction retourne le code 1

#### Scenario: Token refusé par Forgejo

WHEN `config/forgejo.token` existe et est lu
AND l'authentification Git HTTPS avec ce token est refusée par Forgejo
THEN la fonction affiche une erreur d'authentification explicite
AND aucun bootstrap automatique n'est tenté (le fichier existe déjà)
AND aucun fallback interactif n'est tenté
AND la fonction retourne le code 1

#### Scenario: Dépôt non synchronisé

WHEN `git fetch origin` authentifié est exécuté avec succès
AND HEAD et origin/main ne pointent pas sur le même commit après fetch hors rejeu isolé autorisé
THEN la fonction affiche un message d'erreur indiquant que le dépôt n'est pas synchronisé
AND aucun tag ni Release n'est créé
AND la fonction retourne le code 1

#### Scenario: Branche courante non main

WHEN la branche courante n'est pas main
THEN la fonction affiche un message d'erreur
AND la fonction retourne le code 1

#### Scenario: Remote origin absent

WHEN le remote origin n'existe pas
THEN la fonction affiche un message d'erreur
AND la fonction retourne le code 1

#### Scenario: Remote non-HTTPS

WHEN le remote origin n'est pas une URL HTTPS
THEN la fonction affiche un message d'erreur
AND la fonction retourne le code 1

#### Scenario: Branche distante origin/main absente

WHEN origin existe
AND origin/main n'existe pas
THEN la fonction affiche un message d'erreur explicite
AND aucun tag ni Release n'est créé
AND la fonction retourne le code 1

#### Scenario: Release avec username absent

- **WHEN** le token est valide mais le username est absent et le setup est accepté
- **THEN** le parcours complète seulement le username et conserve le token existant


#### Scenario: Rejeu isolé d’un commit antérieur

- **WHEN** le commit du tag est un ancêtre vérifié de la branche distante dans le contexte isolé
- **THEN** la release peut être vérifiée ou complétée sans modifier la branche distante

### Requirement: Création de la Release

La fonction SHALL créer la Release Forgejo par API REST avec le tag ciblant exactement HEAD déjà vérifié, les métadonnées et l’artefact décrits ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Release créée avec succès

WHEN toutes les vérifications préalables passent
AND le tag et la Release n'existent pas
THEN la fonction crée le tag v<VERSION> pointant sur HEAD via l'API
AND la fonction crée la Release avec le tag, le titre et les notes
AND la fonction récupère l'identifiant de la Release créée

#### Scenario: Identité du commit et métadonnées de la Release

- **WHEN** la fonction crée une Release Forgejo
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL créer une Release Forgejo via l'API REST.

Le tag `v<VERSION>` SHALL cibler exactement le commit HEAD. HEAD ayant
déjà été vérifié comme identique à `origin/main`, ou ancêtre en rejeu isolé, le tag ne SHALL donc jamais pointer vers un commit différent de celui validé lors de ces contrôles.

La chaîne de vérification attendue est :

```
HEAD == origin/main (ou ancêtre en rejeu isolé)
        ↓
tag v<VERSION>
        ↓
Release DIU <VERSION>
        ↓
asset diu_<VERSION>_all.deb
```

La Release utilisera :

- Tag : `v<VERSION>` ciblant exactement HEAD
- Titre : `DIU <VERSION>`
- Notes de Release : version, SHA du commit HEAD, message du dernier commit
