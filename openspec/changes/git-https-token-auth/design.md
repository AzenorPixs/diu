## Context

Le DIU exécute des opérations Git (fetch, push) sous `DEVOPS_USER` via
`runuser`. Ces opérations ciblent des remotes HTTPS Forgejo mais
n'actuellement aucun mécanisme d'authentification automatisé — Git demande
interactivement un identifiant et un mot de passe.

Un token Forgejo persistant existe déjà dans `config/forgejo.token` pour les
appels API REST (release). Ce token n'est pas réutilisé pour les opérations
Git.

Les contraintes principales sont :

- les opérations Git s'exécutent sous `DEVOPS_USER` via `runuser` ;
- le token ne doit jamais persister dans la configuration Git, les URLs de
  remote, les credential stores, ni apparaître dans `ps` ou `/proc/*/cmdline` ;
- le mécanisme doit être extensible à d'autres fournisseurs (GitHub, GitLab)
  sans modification du cœur ;
- `publish_release()` dispose déjà d'un bootstrap automatique du token qui
  doit être préservé.

Voir `proposal.md` pour la motivation complète et les spécifications pour les
exigences normatives.

## Goals / Non-Goals

**Goals:**

- Fournir une primitive `git_with_token()` dans `lib/git-auth.sh` exécutant
  toute commande Git authentifiée via un mécanisme éphémère.
- Fournir un provider `lib/forgejo-auth.sh` résolvant les informations Forgejo
  (host, owner, repo, username, token) et déléguant au cœur.
- Intégrer l'authentification dans `publish_release()` (fetch) et `git_push()`
  (push).
- Garantir un comportement fail-closed sans fallback interactif.

**Non-Goals:**

- Implémentation des providers GitHub et GitLab.
- Authentification Git SSH.
- Rotation automatique des tokens.
- Gestionnaire de secrets externe.
- Modification du scope du token Forgejo existant.

## Decisions

### Decision 1 : Mécanisme d'authentification Git — `GIT_ASKPASS` temporaire

**Choix :** Utiliser un script `GIT_ASKPASS` temporaire associé à un fichier
de credentials séparé, avec `GIT_TERMINAL_PROMPT=0` pour interdire tout
fallback terminal.

**Alternatives considérées :**

| Alternative | Pourquoi rejetée |
|---|---|
| `git -c http.extraHeader=...` | Expose le token dans les arguments de processus (`/proc/PID/cmdline`). |
| Credential helper (`git credential fill`) | Plus complexe, le helper reste en mémoire plus longtemps. |
| Netrc temporaire | Format standardisé, risque de lecture par d'autres processus sous le même utilisateur. |
| `GIT_ASKPASS` avec token en dur dans le script | Le script doit être exécutable (700) mais le token doit être en 600. Incompatible. |

**Architecture retenue :**

Le mécanisme repose sur trois éléments temporaires créés dans un répertoire
dédié :

```
/tmp/diu-git-auth-XXXXXX/        (répertoire, permissions restrictives)
├── askpass.sh                    (script ASKPASS, mode 700, owner DEVOPS_USER)
└── credentials                   (fichier credentials, mode 600, owner DEVOPS_USER)
```

**`askpass.sh`** (mode 700) :

- ne contient AUCUN secret ;
- reçoit le prompt comme premier argument (`$1`) ;
- si `$1` correspond à une demande Username (contient `Username`) :
  retourne la première ligne de `credentials` ;
- si `$1` correspond à une demande Password (contient `Password`) :
  retourne la seconde ligne de `credentials` ;
- pour tout autre prompt : échoue explicitement (exit 1) sans exposer
  de credential ;

**`credentials`** (mode 600) :

- contient exactement deux lignes :
  - ligne 1 : `forgejo_username` ;
  - ligne 2 : le token.

**Variables d'environnement transmises au processus Git :**

- `GIT_ASKPASS=<chemin>/askpass.sh` — désigne le helper ;
- `GIT_TERMINAL_PROMPT=0` — interdit explicitement tout fallback terminal.
  Si `ASKPASS` échoue ou ne fournit pas les credentials, Git échoue au lieu
  de demander Username/Password sur le terminal.

Le token n'apparaît jamais dans `askpass.sh`. Le chemin du fichier
`credentials` est connu du helper via son propre nom de répertoire (calculé
relativement à `$0`), sans nécessiter de variable d'environnement transmettant
le secret.

**Signature retenue :**

```
git_with_token <project_path> <git_username> <token> <git_args...>
```

Exemple d'appel :
```
git_with_token "/home/devops/datas/monprojet" "alice" "abc123" fetch origin
```

### Decision 2 : Cycle de vie et cleanup via subshell

**Choix :** La partie de `git_with_token()` utilisant les credentials SHALL
être exécutée dans un subshell dédié avec un `trap` limité à son cycle de vie.

```bash
(
    trap 'rm -rf "${tmp_dir}"' EXIT
    # Création askpass.sh + credentials
    # Exécution de la commande Git
)
```

**Contraintes du trap :**

- le trap est installé dans le subshell, pas dans le shell parent du DIU ;
- il couvre : succès, erreur Git, erreur de création des fichiers,
  interruption du sous-processus (SIGTERM, SIGINT) ;
- le répertoire temporaire est supprimé intégralement (`rm -rf`).

**Fichiers temporaires :**

| Élément | Propriétaire | Permissions | Contenu |
|---|---|---|---|
| Répertoire temporaire | DEVOPS_USER | 700 | — |
| `askpass.sh` | DEVOPS_USER | 700 | Script sans secret |
| `credentials` | DEVOPS_USER | 600 | username + token |

Les fichiers ne sont PAS placés dans le répertoire du projet Git (évite
toute contamination du dépôt).

### Decision 3 : Emplacement des modules

**Choix :**

```
lib/
├── git-auth.sh        # Cœur générique : git_with_token()
└── forgejo-auth.sh    # Provider Forgejo : résolution + validation + appel
```

**Rationale :** Respecte l'architecture existante `lib/` pour les fonctions
génériques. `forgejo-auth.sh` ne dépend pas de `modules/projects/`.
`git-auth.sh` ne dépend d'aucun provider.

Les deux fichiers sont sourcés dans `root-install-debian.sh` après
`lib/logging.sh` et avant `modules/projects/`.

### Decision 4 : Résolution de `forgejo_username`

**Problème :** Le spec exige que `forgejo_username` (identité d'authentification)
soit distinct de `forgejo_owner` (propriétaire du repository). Le owner peut
être une organisation.

**Choix :** Persister `forgejo_username` dans un fichier
`config/forgejo.username` créé automatiquement lors du bootstrap du token
par `publish_release()`.

**Alternatives considérées :**

| Alternative | Pourquoi rejetée |
|---|---|
| Déduire du owner | Incorrect : le owner peut être une organisation. |
| Demander à chaque fois | Non déterministe, casse l'automatisation. |
| Utilisateur système DEVOPS_USER | Incorrect : l'identifiant Forgejo n'est pas forcément le même que l'utilisateur Linux. |
| Extraire du token via API | Trop complexe, le token peut ne pas avoir les permissions. |

**Mécanisme :**

- `publish_release()` demande déjà l'identifiant Forgejo lors du bootstrap.
  Il persiste cet identifiant dans `config/forgejo.username` (permissions 600).
- `forgejo-auth.sh` lit `config/forgejo.username` pour obtenir
  `forgejo_username`.
- `forgejo.username` ne contient pas de secret, mais conserve les permissions
  600 pour rester cohérent avec les métadonnées d'authentification locales.

**Politique d'accès :**

| Situation | Comportement |
|---|---|
| `forgejo.token` + `forgejo.username` présents | Utilisation normale |
| `forgejo.token` absent | Bootstrap automatique (crée les deux fichiers) |
| `forgejo.token` présent + `forgejo.username` absent | Fail-closed, erreur explicite demandant à l'administrateur de créer `config/forgejo.username` |

Aucun fallback `owner=username` ne SHALL être introduit. Aucun prompt
Username/Password ne SHALL être déclenché.

### Decision 5 : Séquence de `publish_release()`

**Ordre actuel :**
1. Vérification paquet/projet
2. `git fetch origin` (non authentifié — bloque)
3. Vérification Git
4. Lecture/bootstrap du token
5. Appels API Release

**Nouvel ordre :**
1. Vérification paquet/projet
2. Déduction des informations Forgejo (host, owner, repo)
3. Lecture de `config/forgejo.token`
4. Si absent : bootstrap automatique existant (crée aussi `forgejo.username`)
5. Token disponible et validé
6. `git fetch origin` via `forgejo-auth`/`git-auth`
7. Vérification HEAD == origin/main
8. Réutilisation du token pour les appels API Release

**Impact :** Les étapes 2 et 3 sont avancées avant le fetch. Le bootstrap
est déplacé avant le fetch. Le token lu est réutilisé pour les appels API
(au lieu d'être relu). La logique de bootstrap existante est préservée
intacte mais repositionnée.

### Decision 6 : `git_push()` — token absent = échec explicite

**Choix :** `git_push()` ne déclenche pas de bootstrap automatique du token.

Si `config/forgejo.token` ou `config/forgejo.username` est absent,
`git_push()` affiche une erreur explicite indiquant que les fichiers
d'authentification doivent être créés (via `rid proj rel` ou manuellement)
et retourne 1.

**Rationale :** Le bootstrap nécessite une interaction utilisateur
(identifiant + mot de passe Forgejo). `git_push()` n'est pas le lieu
approprié pour cette interaction dans ce premier change. L'orchestration
du bootstrap reste dans `publish_release()`.

### Decision 7 : Source des appels

**`lib/git-auth.sh`** sera sourcé dans `root-install-debian.sh` à la ligne :

```bash
. "$BASH_SCRIPT_PATH/lib/git-auth.sh"
```

après `lib/logging.sh` et avant `modules/projects/packaging.sh`.

**`lib/forgejo-auth.sh`** sera sourcé à la ligne :

```bash
. "$BASH_SCRIPT_PATH/lib/forgejo-auth.sh"
```

après `lib/git-auth.sh` et avant `modules/projects/forgejo-release.sh`.

## Risks / Trade-offs

**[Risk] Fenêtre d'exposition du token dans le fichier `credentials`**
→ Mitigation : Le fichier est créé avec permissions 600 dans un répertoire
avec permissions restrictives. Le subshell est court-lived. Le trap garantit
la suppression même en cas d'erreur ou d'interruption.

**[Risk] Incohérence entre `forgejo.token` et `forgejo.username`**
→ Mitigation : Les deux fichiers sont créés ensemble lors du bootstrap.
Si l'un existe sans l'autre (cas legacy), le provider retourne une erreur
explicative avec la marche à suivre.

**[Risk] Compatibilité `runuser` / `GIT_ASKPASS`**
→ Le script `askpass.sh` et le fichier `credentials` doivent être lisibles
par `DEVOPS_USER`. Créés avec le bon owner via `runuser -u DEVOPS_USER`.
Le répertoire temporaire est créé dans un emplacement accessible.

**[Risk] Changement d'ordre dans `publish_release()` peut casser des
cas limites**
→ Mitigation : La logique de bootstrap est préservée intacte, seule sa
position dans la séquence change. Les vérifications Git restent identiques.

**[Risk] Projets existants avec `forgejo.token` mais sans `forgejo.username`**
→ Mitigation : Fail-closed explicite avec message demandant à
l'administrateur de créer le fichier. Aucun fallback automatique.

## Migration Plan

1. Créer `lib/git-auth.sh` et `lib/forgejo-auth.sh`.
2. Ajouter les sourcing dans `root-install-debian.sh`.
3. Modifier `publish_release()` :
   - avancer la lecture/bootstrap du token avant le fetch ;
   - lors du bootstrap, créer aussi `config/forgejo.username` ;
   - remplacer `git fetch origin` par l'appel via `forgejo-auth` ;
   - réutiliser le token pour les appels API.
4. Modifier `git_push()` :
   - remplacer le push direct par l'appel via `forgejo-auth` ;
   - ajouter la vérification explicite du token et du username absents.
5. Cas legacy : projets avec `forgejo.token` mais sans `forgejo.username` :
   - fail-closed avec message explicite ;
   - l'administrateur crée manuellement le fichier ou relance un bootstrap.

**Rollback :** Supprimer les sourcing dans `root-install-debian.sh` et
restaurer les appels Git directs. Les fichiers `config/forgejo.token` et
`config/forgejo.username` restent sans effet sans les modules.

## Open Questions

- Le scope `write:repository` du token Forgejo existant couvre-t-il
  `git fetch` et `git push` en plus des appels API REST ? À vérifier
  empiriquement lors de l'implémentation. Si fetch/push échoue pour une
  raison de scope, documenter le comportement réel avant toute modification
  des permissions. Ne jamais élargir automatiquement le token.
