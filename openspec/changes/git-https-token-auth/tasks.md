## 1. Module cœur `lib/git-auth.sh`

- [x] 1.1 Créer le fichier `lib/git-auth.sh` avec l'en-tête et le sourcing de `lib/logging.sh`
- [x] 1.2 Implémenter `git_with_token()` avec la signature `<project_path> <git_username> <token> <git_args...>` — validation des paramètres obligatoires, retour code 1 si manquants
- [x] 1.3 Implémenter la création du répertoire temporaire (`mktemp -d`) avec permissions restrictives (owner DEVOPS_USER, mode 700)
- [x] 1.4 Implémenter la création du fichier `credentials` (mode 600, owner DEVOPS_USER) contenant username et token sur deux lignes
- [x] 1.5 Implémenter la création du script `askpass.sh` (mode 700, owner DEVOPS_USER) sans aucun secret — le script examine `$1` pour distinguer les demandes Username/Password, lit `credentials`, échoue explicitement pour tout autre prompt
- [x] 1.6 Implémenter l'exécution de la commande Git via `runuser -u DEVOPS_USER` avec `GIT_ASKPASS=<chemin>/askpass.sh` et `GIT_TERMINAL_PROMPT=0` dans un subshell avec `trap 'rm -rf "${tmp_dir}"' EXIT`
- [x] 1.7 Implémenter la propagation du code de retour Git et les messages d'erreur sans exposition du token
- [x] 1.8 Vérifier la syntaxe avec `bash -n lib/git-auth.sh`

## 2. Module provider `lib/forgejo-auth.sh`

- [x] 2.1 Créer le fichier `lib/forgejo-auth.sh` avec l'en-tête et le sourcing de `lib/logging.sh` et `lib/git-auth.sh`
- [x] 2.2 Implémenter la fonction de déduction Forgejo depuis l'URL du remote : extraction de `forgejo_host`, `forgejo_owner`, `forgejo_repo` — gestion des URLs avec/sans `.git`, erreur sur URL non-HTTPS ou malformée
- [x] 2.3 Implémenter la lecture et validation de `config/forgejo.username` (existence, non vide)
- [x] 2.4 Implémenter la lecture et validation de `config/forgejo.token` (existence, permissions 600, non vide)
- [x] 2.5 Implémenter la fonction `forgejo_git_fetch()` appelant `git_with_token()` avec les paramètres résolus
- [x] 2.6 Implémenter la fonction `forgejo_git_push()` appelant `git_with_token()` avec les paramètres résolus
- [x] 2.7 Implémenter le comportement fail-closed pour chaque anomalie (token absent, username absent, permissions invalides, token vide, URL non-HTTPS) avec messages d'erreur explicites sans exposition du token
- [x] 2.8 Vérifier la syntaxe avec `bash -n lib/forgejo-auth.sh`

## 3. Sourcing dans `root-install-debian.sh`

- [x] 3.1 Ajouter `. "$BASH_SCRIPT_PATH/lib/git-auth.sh"` après le sourcing de `lib/logging.sh` et avant `modules/projects/packaging.sh`
- [x] 3.2 Ajouter `. "$BASH_SCRIPT_PATH/lib/forgejo-auth.sh"` après le sourcing de `lib/git-auth.sh` et avant `modules/projects/forgejo-release.sh`
- [x] 3.3 Vérifier la syntaxe avec `bash -n root-install-debian.sh`

## 4. Modification de `publish_release()` dans `modules/projects/forgejo-release.sh`

- [x] 4.1 Avancer la déduction des informations Forgejo (host, owner, repo) avant le `git fetch` — réutiliser la logique existante de l'étape 7 en la repositionnant après la validation du projet
- [x] 4.2 Avancer la lecture/bootstrap du token (`config/forgejo.token`) avant le `git fetch` — réutiliser la logique existante de l'étape 8 en la repositionnant
- [x] 4.3 Lors du bootstrap automatique du token, ajouter la persistance de `forgejo.username` dans `config/forgejo.username` (permissions 600)
- [x] 4.4 Remplacer le `git fetch origin` direct (étape 5 actuelle) par un appel à `forgejo_git_fetch()` utilisant le token déjà validé
- [x] 4.5 Vérifier que le token est réutilisé pour les appels API Release (étapes 9-12) sans relecture
- [x] 4.6 Supprimer les étapes devenues obsolètes (ancien fetch non authentifié, ancienne position de la lecture du token)
- [x] 4.7 Ajuster la numérotation et les `print_title` des étapes
- [x] 4.8 Vérifier la syntaxe avec `bash -n modules/projects/forgejo-release.sh`

## 5. Modification de `git_push()` dans `root-install-debian.sh`

- [x] 5.1 Adapter `git_push()` pour déléguer intégralement l'authentification et l'exécution du push à `forgejo_git_push()` — le provider reste l'unique responsable de la validation du token, du username, du parsing du remote et du comportement fail-closed
- [x] 5.2 Propager le code retour du provider et conserver un message fonctionnel approprié sans dupliquer sa logique de validation
- [x] 5.3 Vérifier qu'aucun bootstrap automatique n'est déclenché depuis `git_push()`
- [x] 5.4 Vérifier qu'aucun fallback Username/Password interactif n'est possible
- [x] 5.5 Vérifier la syntaxe de `root-install-debian.sh` avec `bash -n`

## 6. Vérifications statiques et locales

- [x] 6.1 Exécuter `bash -n` sur tous les fichiers modifiés et créés (`lib/git-auth.sh`, `lib/forgejo-auth.sh`, `root-install-debian.sh`, `modules/projects/forgejo-release.sh`)
- [x] 6.2 Exécuter `shellcheck` sur `lib/git-auth.sh` et `lib/forgejo-auth.sh` si disponible — SC1091 (info, sourcing dynamique) et SC2034 (warning, faux positif scope dynamique) — aucune erreur critique
- [ ] 6.3 Vérifier les permissions des fichiers temporaires (répertoire temporaire owner DEVOPS_USER mode 700, `askpass.sh` owner DEVOPS_USER mode 700, `credentials` owner DEVOPS_USER mode 600) — réaliser ces vérifications par un test local contrôlé ou une instrumentation temporaire de test ne modifiant pas le comportement fonctionnel livré ; ne jamais désactiver ou affaiblir le cleanup de production
- [ ] 6.4 Vérifier que `askpass.sh` ne contient pas le token — inspection réalisée par test local contrôlé sans modifier le code fonctionnel
- [ ] 6.5 Vérifier que le remote origin n'est jamais modifié après une opération authentifiée (`git remote get-url origin` inaltéré)
- [ ] 6.6 Vérifier que `.git/config` ne contient aucun credential ajouté
- [ ] 6.7 Vérifier qu'aucun credential store persistant n'est créé
- [ ] 6.8 Vérifier que le répertoire temporaire est supprimé après succès — réaliser cette vérification par test local contrôlé ou instrumentation temporaire sans affaiblir le cleanup de production
- [ ] 6.9 Vérifier que le répertoire temporaire est supprimé après échec Git — réaliser cette vérification par test local contrôlé ou instrumentation temporaire sans affaiblir le cleanup de production

## 7. Cas legacy

- [ ] 7.1 Vérifier le comportement quand `config/forgejo.token` est présent mais `config/forgejo.username` est absent : fail-closed, message demandant la création de `config/forgejo.username`, aucun fallback `owner=username`, aucun bootstrap automatique, aucune commande Git distante exécutée

## 8. Tests d'intégration Forgejo réels

Ces tests impliquent de vrais appels Git vers Forgejo et ne doivent pas être
exécutés automatiquement pendant l'implémentation sans validation explicite
de l'administrateur. Utiliser le DIU de développement (`ridt`).

- [ ] 8.1 Tester `ridt proj rel` avec `forgejo.token` et `forgejo.username` existants et valides — fetch authentifié réussi, HEAD == origin/main, publication réussie
- [ ] 8.2 Tester `ridt proj rel` avec token absent sur une nouvelle version jamais publiée sur Forgejo — bootstrap automatique, création de `forgejo.token` + `forgejo.username`, fetch authentifié, création du tag, création de la Release, upload asset réussi. Toute suppression éventuelle d'un tag/Release de test doit rester une action administrateur explicite
- [ ] 8.3 Tester `ridt proj gitp` avec `forgejo.token` et `forgejo.username` existants — push authentifié réussi, aucun prompt Username/Password
- [ ] 8.4 Tester `ridt proj gitp` avec token absent — échec explicite (code 1, message), aucun bootstrap, aucun prompt
- [ ] 8.5 Tester `ridt proj gitp` avec `forgejo.token` présent mais `forgejo.username` absent — fail-closed, message explicite, aucun fallback
- [ ] 8.6 Tester `ridt proj rel` avec token invalide/refusé par Forgejo — fail-closed, erreur explicite, aucun bootstrap (fichier existe)
- [ ] 8.7 Vérifier l'absence de prompt Username/Password dans tous les scénarios ci-dessus
- [ ] 8.8 Vérifier empiriquement que le scope `write:repository` du token fonctionne pour `git fetch`, `git push` et les appels API Release — documenter le résultat
