## Purpose

Publier une Release Forgejo contenant le paquet Debian DIU construit par
`build_deb()`, en vérifiant la cohérence du paquet, la synchronisation
Git et l'authentification, puis en créant le tag, la Release et en
uploadant l'asset via l'API REST Forgejo.

## Requirements

### Requirement: Sélection du paquet dans dist/

La fonction `publish_release()` SHALL identifier le paquet Debian à
publier dans le répertoire `dist/` du projet.

Le paquet attendu SHALL avoir pour nom `diu_*_all.deb`.

La fonction SHALL appliquer une politique fail-closed :

- 0 paquet trouvé : erreur explicite, aucun appel API, code retour 1
- exactement 1 paquet trouvé : continuer
- plus de 1 paquet trouvé : erreur explicite, aucun appel API, code retour 1

Les autres fichiers éventuellement présents dans `dist/` SHALL être
ignorés.

#### Scenario: Exactement un paquet valide trouvé

WHEN dist/ contient exactement un fichier diu_*_all.deb
THEN la fonction identifie ce paquet comme cible de publication
AND la fonction continue vers la vérification des métadonnées

#### Scenario: Aucun paquet trouvé

WHEN dist/ ne contient aucun fichier diu_*_all.deb
THEN la fonction affiche un message d'erreur explicite
AND aucun appel API n'est effectué
AND la fonction retourne le code 1

#### Scenario: Plusieurs paquets trouvés

WHEN dist/ contient plus d'un fichier diu_*_all.deb
THEN la fonction affiche un message d'erreur identifiant les paquets trouvés
AND aucun appel API n'est effectué
AND la fonction retourne le code 1

### Requirement: Vérification des métadonnées du paquet

La fonction SHALL vérifier la cohérence entre le nom du fichier `.deb`
et les métadonnées contenues dans le paquet.

Le champ `Package` du fichier `control` extrait du paquet SHALL être
identique à `diu`.

Le champ `Version` du fichier `control` extrait du paquet SHALL
correspondre exactement à la version contenue dans le nom du fichier.

#### Scenario: Métadonnées cohérentes

WHEN le nom du fichier est diu_2026.08.12.12.23_all.deb
AND le champ Package du paquet vaut diu
AND le champ Version du paquet vaut 2026.08.12.12.23
THEN la vérification passe avec succès
AND la fonction continue

#### Scenario: Package incohérent

WHEN le champ Package du paquet ne vaut pas diu
THEN la fonction affiche un message d'erreur identifiant l'incohérence
AND la fonction retourne le code 1

#### Scenario: Version incohérente

WHEN le champ Version du paquet ne correspond pas à la version du nom de fichier
THEN la fonction affiche un message d'erreur identifiant l'incohérence
AND la fonction retourne le code 1

### Requirement: Vérification Git avant publication

Avant toute publication Forgejo, la fonction SHALL vérifier que le
dépôt local est dans un état valide pour la publication.

Les vérifications obligatoires sont :

- le projet est un dépôt Git valide
- le remote origin existe
- la branche courante est main
- origin/main existe
- HEAD et origin/main pointent sur le même commit

#### Scenario: Dépôt synchronisé

WHEN le dépôt est un dépôt Git valide
AND origin existe
AND la branche courante est main
AND origin/main existe
AND HEAD et origin/main pointent sur le même commit
THEN la vérification passe avec succès
AND la fonction continue vers la récupération du token

#### Scenario: Dépôt non synchronisé

WHEN HEAD et origin/main ne pointent pas sur le même commit
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

#### Scenario: Branche distante origin/main absente

WHEN origin existe
AND origin/main n'existe pas
THEN la fonction affiche un message d'erreur explicite
AND aucun tag ni Release n'est créé
AND la fonction retourne le code 1

### Requirement: Déduction de l'URL Forgejo

La fonction SHALL déduire les informations de connexion Forgejo
à partir de l'URL du remote origin.

À partir d'une URL de forme `https://<host>/<owner>/<repo>[.git]`,
la fonction SHALL extraire :

- la base Forgejo (ex: `https://forgejo.pixs.fr`)
- le propriétaire (ex: `rootforgejo`)
- le nom du dépôt (ex: `diu`)

#### Scenario: URL standard extraite

WHEN l'URL du remote origin est https://forgejo.pixs.fr/rootforgejo/diu.git
THEN la base Forgejo est https://forgejo.pixs.fr
AND le owner est rootforgejo
AND le repository est diu

### Requirement: Authentification par token

La fonction SHALL utiliser un Access Token Forgejo pour
l'authentification aux API.

Le token SHALL être stocké dans `<project_path>/config/forgejo.token`.

Le fichier token SHALL avoir les permissions exactes `600`.

Le token ne SHALL jamais être affiché dans les logs ni la sortie standard.

La fonction ne SHALL jamais corriger silencieusement les permissions
du fichier token. L'administrateur devra appliquer explicitement
`chmod 600` en cas de permissions invalides.

Le bootstrap automatique avec authentification 2FA/OTP est hors périmètre
de ce premier change. Si le bootstrap ne peut pas aboutir à cause de la
méthode d'authentification du compte Forgejo, la fonction SHALL appliquer
le scénario "Échec de création automatique du token" et demander une
création manuelle.

Le token SHALL utiliser les privilèges minimaux nécessaires aux opérations
de publication prévues par `publish_release()`. Le scope exact du token
sera déterminé lors de la vérification du Swagger de l'instance Forgejo
(voir Task 1).

#### Scenario: Token présent et permissions valides

WHEN config/forgejo.token existe
AND ses permissions sont exactement 600
THEN la fonction utilise ce token pour l'authentification

#### Scenario: Permissions du token invalides

WHEN config/forgejo.token existe
AND ses permissions ne sont pas exactement 600
THEN la fonction affiche une erreur de sécurité explicite
AND le token n'est pas utilisé
AND aucun appel de publication Forgejo n'est effectué
AND la fonction retourne le code 1

#### Scenario: Token absent

WHEN config/forgejo.token n'existe pas
THEN la fonction propose explicitement à l'utilisateur de créer un token
AND la fonction demande l'identifiant Forgejo
AND la fonction demande le mot de passe de manière non affichée
AND la fonction crée un token via l'API Forgejo
AND la fonction enregistre le token dans config/forgejo.token
AND la fonction applique chmod 600
AND le token n'est jamais affiché

#### Scenario: Token absent et création annulée

WHEN l'utilisateur refuse la création automatique du token
THEN la fonction affiche une erreur
AND la fonction ne tente pas de publier la Release
AND la fonction retourne le code 1

#### Scenario: Échec de création automatique du token

WHEN config/forgejo.token n'existe pas
AND l'utilisateur accepte la création automatique
AND l'authentification ou la création du token Forgejo échoue
THEN aucun token n'est enregistré
AND la fonction indique clairement que le token doit être créé manuellement
dans Forgejo
AND aucune Release n'est créée
AND la fonction retourne le code 1

Le mot de passe saisi ne SHALL jamais être écrit sur disque ni affiché.

### Requirement: Vérification de l'existence de la Release

Avant création, la fonction SHALL vérifier si le tag `v<VERSION>`
et la Release correspondante existent déjà sur Forgejo.

#### Scenario: Tag et Release inexistants

WHEN le tag v<VERSION> n'existe pas sur Forgejo
AND aucune Release correspondante n'existe
THEN la fonction continue vers la création de la Release

#### Scenario: Tag déjà existant

WHEN le tag v<VERSION> existe déjà sur Forgejo
THEN la fonction affiche une erreur explicite
AND aucune Release n'est créée
AND le tag existant n'est ni déplacé, ni recréé, ni modifié
AND la fonction retourne le code 1

#### Scenario: Release déjà existante

WHEN une Release pour le tag v<VERSION> existe déjà
THEN la fonction affiche une erreur explicite
AND rien n'est écrasé ni modifié
AND la fonction retourne le code 1

### Requirement: Création de la Release

La fonction SHALL créer une Release Forgejo via l'API REST.

Le tag `v<VERSION>` SHALL cibler exactement le commit HEAD. HEAD ayant
déjà été vérifié comme identique à `origin/main` lors de la phase de
contrôle Git, le tag ne SHALL donc jamais pointer vers un commit
différent de celui validé lors de ces contrôles.

La chaîne de vérification attendue est :

```
HEAD == origin/main
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

#### Scenario: Release créée avec succès

WHEN toutes les vérifications préalables passent
AND le tag et la Release n'existent pas
THEN la fonction crée le tag v<VERSION> pointant sur HEAD via l'API
AND la fonction crée la Release avec le tag, le titre et les notes
AND la fonction récupère l'identifiant de la Release créée

### Requirement: Upload du paquet comme asset

Après création réussie de la Release, la fonction SHALL uploader le
fichier `.deb` comme asset de la Release.

#### Scenario: Upload réussi

WHEN la Release est créée avec succès
AND le fichier .deb existe
THEN la fonction upload le fichier comme asset de la Release
AND la fonction vérifie le succès de l'upload

#### Scenario: Upload échoué après création de Release

WHEN l'upload du fichier échoue après création de la Release
THEN la fonction retourne le code 1
AND la fonction affiche une erreur claire
AND la Release reste visible mais incomplète
AND aucun rollback automatique n'est effectué

### Requirement: Vérification des prérequis

La fonction SHALL vérifier la disponibilité des outils nécessaires
avant de procéder : `git`, `curl`, `jq`, `dpkg-deb`.

#### Scenario: Tous les prérequis disponibles

WHEN les outils git, curl, jq et dpkg-deb sont disponibles
THEN la fonction continue vers la vérification du paquet

#### Scenario: Outil manquant

WHEN un outil requis est absent
THEN la fonction affiche un message identifiant l'outil manquant
AND aucun appel API n'est effectué
AND la fonction retourne le code 1

### Requirement: Commande rid proj rel

Le DIU SHALL accepter la commande `rid proj rel <project_id>` pour
déclencher la publication d'une Release Forgejo à partir du paquet
construit dans `dist/`.

#### Scenario: Publication depuis la commande rid

WHEN l'utilisateur exécute `rid proj rel monprojet`
THEN le DIU valide que le projet existe
AND le DIU vérifie les prérequis
AND le DIU sélectionne le paquet dans dist/
AND le DIU vérifie les métadonnées du paquet
AND le DIU vérifie la synchronisation Git
AND le DIU récupère ou crée le token
AND le DIU vérifie l'existence de la Release
AND le DIU crée la Release et upload l'asset

#### Scenario: Projet inexistant

WHEN l'utilisateur exécute `rid proj rel projetinexistant`
THEN un message d'erreur indique que le projet n'existe pas
AND la fonction retourne le code 1

### Requirement: Indépendance fonctionnelle

La fonction `publish_release()` SHALL rester totalement indépendante
de `git_push()` et `build_deb()`.

La fonction ne SHALL :

- ni effectuer de commit
- ni effectuer de git push
- ni reconstruire implicitement le paquet Debian

#### Scenario: Appel indépendant

WHEN publish_release() est appelée
THEN aucune opération de commit n'est effectuée
AND aucune opération de push n'est effectuée
AND aucun rebuild du paquet n'est déclenché

### Requirement: Immutabilité des Releases

Une Release déjà publiée SHALL être considérée comme immuable.

La fonction ne SHALL :

- rien écraser
- rien modifier
- supprimer automatiquement une Release ou un tag

#### Scenario: Version déjà publiée

WHEN une Release pour la version demandée existe déjà
THEN la fonction retourne une erreur
AND aucune modification n'est effectuée
