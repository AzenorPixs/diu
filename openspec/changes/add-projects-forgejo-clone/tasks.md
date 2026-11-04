## 1. Authentification et clonage temporaire

- [ ] 1.1 Étendre le provider Forgejo avec un clonage HTTPS authentifié délégué au mécanisme Git existant, puis vérifier qu'aucun token ne persiste ni n'est affiché.
- [ ] 1.2 Ajouter la fonction de clonage Forgejo temporaire et sa fusion sans `.git`, puis vérifier le remplacement des fichiers homonymes et la conservation des fichiers locaux absents du dépôt distant.

## 2. Routage et aide

- [ ] 2.1 Ajouter `rid projects forgejo clone <ID PROJECT>` et son traitement d'aide, puis vérifier que les chemins `help` et `?` n'exécutent aucune création ni clonage.
- [ ] 2.2 Mettre à jour l'aide des contextes `projects` et `projects forgejo`, puis vérifier les syntaxes affichées par les tests d'aide ciblés.

## 3. Tests et validation

- [ ] 3.1 Étendre les tests de projets et d'authentification Forgejo pour couvrir la séquence création, configuration, clonage, fusion, exclusion de `.git` et les échecs sans fusion partielle.
- [ ] 3.2 Exécuter `bash -n`, ShellCheck, les tests ciblés et `openspec validate add-projects-forgejo-clone --strict`, puis vérifier que seuls les fichiers du périmètre sont modifiés.
