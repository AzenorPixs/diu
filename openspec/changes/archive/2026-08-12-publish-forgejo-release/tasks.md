## Tasks

- [x] Task 1 : Vérifier les endpoints et le scope token sur le Swagger Forgejo

**Résultat :** endpoints et scope vérifiés manuellement sur le Swagger
de l'instance `https://forgejo.pixs.fr/api/swagger`.

**Endpoints confirmés :**

| Opération | Méthode | Endpoint | Body / Contrat |
|---|---|---|---|
| Vérifier existence tag | GET | `/api/v1/repos/{owner}/{repo}/tags/{tag}` | Réponse 200 si existe, 404 sinon |
| Créer tag | POST | `/api/v1/repos/{owner}/{repo}/tags` | `{"tag_name":"...","target":"<SHA>","message":"..."}` |
| Rechercher Release par tag | GET | `/api/v1/repos/{owner}/{repo}/releases/tags/{tag}` | Réponse 200 si existe, 404 sinon |
| Créer Release | POST | `/api/v1/repos/{owner}/{repo}/releases` | `{"tag_name":"...","name":"...","body":"..."}` |
| Upload asset | POST | `/api/v1/repos/{owner}/{repo}/releases/{id}/assets` | multipart/form-data, champ `file` |
| Créer token | POST | `/api/v1/users/{username}/tokens` | BasicAuth, `{"name":"...","scopes":[...],"repositories":[...]}` |

**Endpoint confirmé mais NON disponible en POST :**
`/api/v1/repos/{owner}/{repo}/git/refs` — ne pas utiliser pour la création de tag.

**Scope token :**
- Le Swagger ne fournit pas de mapping scope/endpoint exhaustif
- Pour cette V1 : `write:repository` pour les opérations d'écriture
- Si la création du token échoue à cause du scope : ne pas élargir silencieusement,
  afficher l'erreur, demander une création manuelle, retourner 1

**Restriction au dépôt :**
- Supportée via `repositories: [{"owner":"...","name":"..."}]` dans
  `CreateAccessTokenOption`

**Authentification :**
- `Authorization: token <TOKEN>` pour les appels API (confirmé)
- BasicAuth pour la création du token (confirmé)
- TOTPHeader existe mais hors périmètre du premier change

- [x] Task 2 : Créer le module modules/projects/forgejo-release.sh

Créer le fichier `modules/projects/forgejo-release.sh` avec :

- l'en-tête `#!/usr/bin/env bash` et le commentaire de description
- la fonction `publish_release()` acceptant un paramètre `project_id`
- le squelette de la séquence complète (D5) avec des étapes
  numérotées commentées
- les appels aux fonctions de logging du projet (`print_title`,
  `print_info`, `print_success`, `print_error`)

- [x] Task 3 : Implémenter la vérification des prérequis

Dans `publish_release()`, implémenter la vérification de disponibilité
des outils `git`, `curl`, `jq`, `dpkg-deb` via `command -v`.

- Outil manquant → `print_error` + `return 1`
- Tous disponibles → continuer

- [x] Task 4 : Implémenter la validation du projet

Vérifier que :

- `project_id` n'est pas vide
- le répertoire `${DEVOPS_PROJECTS_ROOT}/${project_id}` existe
- le répertoire est un dépôt Git valide (`git rev-parse --is-inside-work-tree`)

- [x] Task 5 : Implémenter la sélection du paquet dans dist/

Rechercher le fichier `diu_*_all.deb` dans `${project_path}/dist/` :

- 0 trouvé → erreur + return 1
- exactement 1 → continuer
- plus de 1 → erreur + return 1

Utiliser un tableau Bash pour compter les correspondances.

- [x] Task 6 : Implémenter la vérification des métadonnées du paquet

Extraire les métadonnées via `dpkg-deb --show --showformat` :

- vérifier que `Package` == `diu`
- vérifier que `Version` correspond à la version extraite du nom de fichier
- incohérence → erreur + return 1

- [x] Task 7 : Implémenter git fetch origin et la vérification Git

Exécuter `git fetch origin` via `runuser -u "${DEVOPS_USER}"`.

En cas d'échec du fetch → erreur explicite + return 1.

Puis vérifier :

- la branche courante est `main`
- `origin/main` existe
- `HEAD` == `origin/main` (comparaison des SHA)

- [x] Task 8 : Implémenter le parsing de l'URL Forgejo

Extraire `forgejo_base`, `forgejo_owner`, `forgejo_repo` depuis l'URL
du remote origin en suivant l'algorithme de D3.

Vérifier que les trois composants sont non vides.

URL non HTTPS ou mal formée → erreur + return 1.

- [x] Task 9 : Implémenter la lecture et le bootstrap du token

Phase 1 — Lecture :

- vérifier existence de `config/forgejo.token`
- vérifier permissions (`stat -c %a`) == 600
- permissions invalides → erreur de sécurité + return 1
- OK → lire le token

Phase 2 — Bootstrap (si absent) :

- proposer la création automatique
- si accepté : demander identifiant + mot de passe (`read -s`)
- appeler `POST /api/v1/users/<user>/tokens` avec BasicAuth
- si succès : écrire le token, `chmod 600`
- si échec : message clair demandant création manuelle + return 1
- mot de passe jamais écrit sur disque ni affiché
- scope du token : utiliser le scope minimal déterminé en Task 1

- [x] Task 10 : Implémenter la vérification d'existence du tag et de la Release

Utiliser les endpoints confirmés lors de la Task 1 :

- vérifier si le tag `v<VERSION>` existe
- vérifier si une Release pour ce tag existe

Tag existant → erreur + return 1 (tag ni déplacé ni modifié).
Release existante → erreur + return 1.

- [x] Task 11 : Implémenter la création du tag et de la Release

Créer le tag `v<VERSION>` pointant sur HEAD via l'API Forgejo
(endpoint confirmé en Task 1).

Créer la Release via `POST /api/v1/repos/{owner}/{repo}/releases` :

- tag_name : `v<VERSION>`
- name : `DIU <VERSION>`
- body : version, SHA HEAD, message du dernier commit

Récupérer l'identifiant de la Release créée.

- [x] Task 12 : Implémenter l'upload de l'asset

Uploader le fichier `diu_<VERSION>_all.deb` via
`POST /api/v1/repos/{owner}/{repo}/releases/{id}/assets`.

Vérifier le succès de l'upload.

Échec d'upload après création de Release → return 1 + message d'erreur
clair. La Release reste visible mais incomplète. Aucun rollback.

- [x] Task 13 : Intégrer le dispatch dans root-install-debian.sh

Ajouter dans `root-install-debian.sh` :

- le sourcing de `modules/projects/forgejo-release.sh`
- le case `rel)` dans `manage_project_action` appelant
  `publish_release "$project_id"`
- l'entrée d'aide dans `display_usage`
- l'ajout de `rel` dans la liste des actions disponibles

- [x] Task 14 : Ajouter config/forgejo.token dans .gitignore

Vérifier que `config/forgejo.token` est exclu du versionnement Git.

Si le `.gitignore` actuel ne couvre pas ce chemin, ajouter une règle
d'exclusion adaptée.

- [x] Task 15 : Vérification bash -n et shellcheck

Exécuter `bash -n modules/projects/forgejo-release.sh` pour valider
la syntaxe.

Exécuter `shellcheck modules/projects/forgejo-release.sh` si disponible.

Corriger toute erreur détectée.

- [x] Task 16 : Vérification de cohérence spec/design/implémentation

Vérifier que l'implémentation est conforme aux scénarios définis dans
la spec `specs/forgejo-release/spec.md`.

Vérifier que les décisions du design sont correctement appliquées.

Vérifier qu'aucune fonctionnalité hors périmètre n'a été ajoutée.
