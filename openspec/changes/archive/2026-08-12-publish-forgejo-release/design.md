## Context

Le DIU construit un paquet Debian via `build_deb()` (modules/projects/packaging.sh)
qui dépose le résultat dans `dist/`. Le projet utilise Forgejo comme forge Git.
Le workflow humain actuel est :

    rid proj gitc diu
    rid proj gitp diu "DIU"
    rid proj deb diu
    rid proj rel diu        ← nouveau

`git_push()` et `build_deb()` sont déjà implémentés et ne doivent pas être modifiés.
La publication de Release est une responsabilité distincte qui consomme le paquet
déjà construit sans le reconstruire.

L'API Forgejo exposée par l'instance cible (forgejo.pixs.fr) est compatible avec
l'API REST documentée dans le Swagger de l'instance. L'authentification se fait
par Access Token en header `Authorization: token <TOKEN>`.

Documentation de référence :
- Swagger instance : `https://forgejo.pixs.fr/api/swagger`
- API Usage : https://forgejo.org/docs/latest/user/api/usage/
- Tags and Releases : https://forgejo.org/docs/latest/user/repository/releases/

**Note :** Tous les endpoints nécessaires ont été vérifiés sur le Swagger
de l'instance forgejo.pixs.fr (voir D6).

## Goals / Non-Goals

**Goals:**

- Publier une Release Forgejo à partir d'un paquet `.deb` déjà construit
- Vérifier la cohérence du paquet (nom, Package, Version)
- Vérifier la synchronisation complète HEAD == origin/main avant publication,
  en rafraîchissant l'état distant via `git fetch origin`
- Gérer l'authentification Forgejo par token avec bootstrap automatique optionnel
- Garantir l'immutabilité des Releases existantes
- Adopter un comportement déterministe et fail-closed en cas de ré-exécution
  ou d'état partiellement publié

**Non-Goals:**

- Reconstruire le paquet Debian (rôle de `build_deb()`)
- Effectuer un commit ou un push (rôle de `git_push()`)
- Générer un changelog complexe
- Gérer le 2FA/OTP lors du bootstrap du token (hors périmètre)
- Corriger silencieusement les permissions du fichier token
- Gérer la rotation ou la suppression de Releases existantes
- Réparer automatiquement une Release créée avec un asset manquant
- Autoriser la reprise sur un tag existant sans Release (hors périmètre)

## Decisions

### D1: Emplacement du code — modules/projects/forgejo-release.sh

**Choix :** Créer un nouveau fichier `modules/projects/forgejo-release.sh`
contenant la fonction `publish_release()`.

**Rationale :** Le projet suit une architecture modulaire avec séparation par
domaine fonctionnel dans `modules/projects/`. Le packaging est dans
`packaging.sh`, les fonctions Git sont dans `root-install-debian.sh` (migration
future vers `modules/projects/`). Un fichier dédié respecte le principe de
responsabilité unique et la convention existante.

**Alternative rejetée :** Ajouter dans `packaging.sh` — car la publication
Forgejo est une responsabilité distincte du packaging Debian.

### D2: Rafraîchissement de l'état distant avant comparaison

**Choix :** Exécuter `git fetch origin` avant de comparer HEAD et origin/main.

**Rationale :** La référence locale `origin/main` peut être obsolète si un
autre poste a poussé des commits entre-temps. Sans fetch, la comparaison
porterait sur un état potentiellement périmé et pourrait autoriser une
publication sur un commit qui n'est plus le dernier sur la branche distante.

**Séquence :**

```
1. git fetch origin
2. Vérifier que origin/main existe (refs/remotes/origin/main)
3. Comparer HEAD avec origin/main
```

**Ce que git fetch origin fait exactement :**

- met à jour les références distantes locales telles que `origin/main`
  (branche de suivi distante) ;
- ne modifie pas la branche locale `main` ;
- ne modifie pas le working tree ;
- n'effectue aucun push.

Son utilisation est donc compatible avec l'indépendance de `publish_release()`
vis-à-vis de `git_push()`.

**Comportement en cas d'échec du fetch :**

- Si le fetch échoue (réseau, serveur injoignable) :
  - afficher une erreur explicite identifiant la cause
  - ne créer aucun tag ni Release
  - retourner le code 1
- Un fetch qui échoue ne doit pas être considéré comme "pas de remote" :
  le message d'erreur doit distinguer "remote absent" de "fetch impossible"

### D3: Parsing de l'URL Forgejo

**Choix :** Extraire base, owner et repository depuis l'URL du remote origin
via des opérations Bash natives, sans dépendance externe.

**Rationale :** Les URLs Forgejo suivent le schéma standard
`https://<host>/<owner>/<repo>[.git]`. Le parsing Bash natif avec des
opérations de chaînes (`//`, `/`, `%`) est suffisant et portable.

**Algorithme :**

```bash
# 1. Récupérer l'URL du remote origin
remote_url="$(git -C "${project_path}" remote get-url origin)"

# 2. Vérifier que l'URL est HTTPS (support du premier change)
if [[ "${remote_url}" != https://* ]]; then
    print_error "Seules les URLs HTTPS sont supportées pour la publication Forgejo."
    return 1
fi

# 3. Retirer le protocole https://
url_path="${remote_url#https://}"

# 4. Extraire le host (tout avant le premier /)
forgejo_host="${url_path%%/*}"

# 5. Retirer le host pour obtenir owner/repo[.git]
remainder="${url_path#*/}"

# 6. Extraire owner (tout avant le premier /)
forgejo_owner="${remainder%%/*}"

# 7. Extraire repo_with_suffix (tout après owner/)
forgejo_repo="${remainder#*/}"

# 8. Retirer le suffixe .git si présent
forgejo_repo="${forgejo_repo%.git}"

# 9. Reconstruire la base Forgejo
forgejo_base="https://${forgejo_host}"
```

**Validation :**

```bash
# 10. Vérifier que les trois composants sont non vides
if [[ -z "${forgejo_host}" || -z "${forgejo_owner}" || -z "${forgejo_repo}" ]]; then
    print_error "Impossible d'extraire les informations Forgejo depuis : ${remote_url}"
    return 1
fi
```

**Comportement si l'URL ne correspond pas au format supporté :**

- URL SSH (`git@...`) : non supportée dans ce premier change → erreur explicite + retour 1
- URL HTTPS mal formée (composants vides après parsing) → erreur explicite + retour 1
- Aucun appel API Forgejo n'est effectué en cas d'échec de parsing

### D4: Gestion du token — approche en deux phases

**Choix :** Séparer la lecture du token et le bootstrap en deux fonctions
internes distinctes.

**Phase 1 — Lecture :**
1. Vérifier si `config/forgejo.token` existe
2. Si oui, vérifier les permissions (`stat -c %a`)
3. Si permissions != 600 : erreur de sécurité, arrêt
4. Si OK, lire le token et l'utiliser

**Phase 2 — Bootstrap (si fichier absent) :**
1. Proposer la création automatique
2. Si accepté : demander identifiant + mot de passe (`read -s`)
3. Appeler `POST /api/v1/users/<user>/tokens` avec BasicAuth
4. Body : `{"name":"diu-publish","scopes":["write:repository"],"repositories":[{"owner":"...","name":"..."}]}`
5. Si succès : extraire `sha1` de la réponse, écrire le token, `chmod 600`
6. Si échec : message clair demandant la création manuelle
7. Le mot de passe est dans une variable locale, jamais exporté,
   jamais écrit sur disque

**Portée du token :** Le token SHALL utiliser les privilèges minimaux
nécessaires aux opérations de publication prévues par `publish_release()`.
Le scope `write:repository` est retenu pour cette V1. La restriction du
token au dépôt courant est supportée via `repositories[]` dans
`CreateAccessTokenOption` (confirmé sur le Swagger).

Si la création du token échoue à cause du scope, la fonction ne SHALL
pas élargir silencieusement les privilèges — elle affichera l'erreur,
demandera une création manuelle et retournera 1.

**Hors périmètre :** Le 2FA/OTP lors du bootstrap. Si le bootstrap échoue
à cause d'une authentification à facteurs multiples, la fonction applique
le scénario d'échec et demande une création manuelle.

### D5: Séquence complète de publish_release()

```
 1. Vérification des prérequis (git, curl, jq, dpkg-deb)
 2. Validation du projet (existe, est un dépôt Git)
 3. Sélection du paquet dans dist/ (fail-closed)
 4. Vérification des métadonnées du paquet (dpkg-deb --show)
 5. git fetch origin (rafraîchissement de l'état distant)
 6. Vérification Git (HEAD == origin/main, branche main)
 7. Déduction de l'URL Forgejo depuis le remote origin
 8. Lecture ou bootstrap du token
 9. Vérification existence tag/Release (GET /tags/{tag}, GET /releases/tags/{tag})
10. Création du tag v<VERSION> (POST /tags, target=<HEAD_SHA>)
11. Création de la Release (POST /releases)
12. Upload de l'asset (POST /releases/{id}/assets)
```

### D6: API Forgejo — endpoints retenus

Tous les endpoints ont été vérifiés sur le Swagger de l'instance
`https://forgejo.pixs.fr/api/swagger`.

**Sources de vérification :**
- Swagger UI : `https://forgejo.pixs.fr/api/swagger`
- Documentation officielle : https://forgejo.org/docs/latest/user/api/usage/
- Documentation officielle : https://forgejo.org/docs/latest/user/repository/releases/

#### Endpoints confirmés

| Opération | Méthode | Endpoint | Body / Contrat |
|---|---|---|---|
| Vérifier existence tag | GET | `/api/v1/repos/{owner}/{repo}/tags/{tag}` | 200 si existe, 404 sinon |
| Créer tag | POST | `/api/v1/repos/{owner}/{repo}/tags` | `{"tag_name":"...","target":"<SHA>","message":"..."}` |
| Rechercher Release par tag | GET | `/api/v1/repos/{owner}/{repo}/releases/tags/{tag}` | 200 si existe, 404 sinon |
| Créer Release | POST | `/api/v1/repos/{owner}/{repo}/releases` | `{"tag_name":"...","name":"...","body":"..."}` |
| Upload asset | POST | `/api/v1/repos/{owner}/{repo}/releases/{id}/assets` | multipart/form-data, champ `file` |
| Créer token | POST | `/api/v1/users/{username}/tokens` | BasicAuth, `{"name":"...","scopes":[...],"repositories":[...]}` |

**Endpoint non disponible :**
`POST /api/v1/repos/{owner}/{repo}/git/refs` — non disponible en POST
sur cette instance. Ne pas utiliser pour la création de tag.

**Authentification :**
- `Authorization: token <TOKEN>` pour les appels API
- BasicAuth pour la création du token

**Scope du token :**
- Le Swagger ne fournit pas de mapping scope/endpoint exhaustif
- Pour cette V1 : `write:repository` pour les opérations d'écriture
- Si la création du token échoue à cause du scope : ne pas élargir
  silencieusement, afficher l'erreur, demander une création manuelle,
  retourner 1

**Restriction au dépôt :**
- Supportée via `repositories: [{"owner":"...","name":"..."}]`
  dans `CreateAccessTokenOption`
- Utilisée pour limiter le token au dépôt courant

**Hors périmètre :**
- TOTPHeader (2FA/OTP) : existe mais non implémenté dans ce premier change

### D7: Gestion des erreurs HTTP

Chaque appel curl SHALL vérifier :

- le code de retour HTTP (2xx = succès)
- le code de sortie curl (0 = succès)
- la présence d'un JSON valide dans la réponse (via `jq`)

En cas d'échec, le message d'erreur SHALL inclure :

- l'opération tentée
- le code HTTP retourné
- le message d'erreur extrait du JSON de réponse Forgejo (si disponible)

### D8: Comportement déterministe en cas de ré-exécution

**Objectif :** Adopter un comportement déterministe et fail-closed en cas de
ré-exécution ou d'état partiellement publié.

**Règles :**

1. **Tag `v<VERSION>` déjà existant :**
   - La fonction retourne une erreur explicite
   - Aucune Release n'est créée
   - Le tag existant n'est ni déplacé, ni recréé, ni modifié
   - L'intervention corrective est laissée à l'administrateur

2. **Release déjà existante (avec ou sans asset) :**
   - La fonction retourne une erreur explicite
   - Aucune modification n'est effectuée
   - L'intervention corrective est laissée à l'administrateur

3. **Asset manquant après création de Release (échec d'upload) :**
   - La Release reste visible mais incomplète sur Forgejo
   - Aucun rollback automatique n'est effectué
   - Une nouvelle exécution détecte la Release existante et échoue
     conformément à la règle 2
   - L'administrateur doit intervenir manuellement :
     soit uploader l'asset via l'interface web, soit supprimer la Release
     et relancer la publication

**Ce comportement n'est PAS idempotent** — c'est volontaire. L'idempotence
impliquerait qu'une seconde exécution puisse réparer silencieusement un état
partiellement publié, ce qui est contraire au principe d'immutabilité des
Releases.

La reprise d'un état partiel avec tag existant mais Release absente est hors
périmètre de ce premier change et pourra faire l'objet d'un change distinct
ultérieur.

### D9: Dispatch et aide

**Modification de root-install-debian.sh :**

- Ajout du sourcing : `. "$BASH_SCRIPT_PATH/modules/projects/forgejo-release.sh"`
- Ajout du case dans `manage_project_action` :
  ```bash
  rel)
      publish_release "$project_id"
      ;;
  ```
- Ajout dans `display_usage` :
  ```
  rid proj rel "ID Projet"
      Publie une Release Forgejo à partir du paquet Debian dans dist/.
  ```
- Ajout de `rel` dans la liste des actions disponibles

## Risks / Trade-offs

**[R1] Forgejo non joignable au moment du fetch ou de la publication**
→ Le fetch échoue en amont ; la publication est bloquée avant toute
modification. Risque faible.

**[R2] Token volé ou compromis**
→ Le token est en `600`, exclu de `.gitignore` et jamais affiché.
La portée est limitée aux privilèges minimaux nécessaires.
Risque résiduel acceptable.

**[R3] Race condition entre vérification et création de Release**
→ Deux exécutions concurrentes pourraient tenter de créer la même
Release. La seconde échouera sur "Release déjà existante" (fail-closed).
Pas de risque de doublon silencieux.

**[R4] État distant non vérifiable (fetch échoue)**
→ La publication est bloquée. L'utilisateur devra vérifier manuellement
la connectivité réseau et réessayer. Comportement prévisible et sûr.

**[R5] Permissions du token modifiées accidentellement**
→ La fonction détecte l'anomalie et refuse d'utiliser le token.
L'administrateur doit corriger manuellement. Pas de correction silencieuse.

**[R6] Endpoints Forgejo non disponibles**
→ Si les endpoints du groupe B ne sont pas disponibles ou incompatibles,
la fonction retourne une erreur explicite. Aucune stratégie alternative
n'est tentée.

**[R7] Upload d'asset échoue après création de Release**
→ La Release reste visible mais incomplète. Aucun rollback. La
ré-exécution détecte la Release existante et échoue (conformément à D8).
L'administrateur doit intervenir manuellement.
