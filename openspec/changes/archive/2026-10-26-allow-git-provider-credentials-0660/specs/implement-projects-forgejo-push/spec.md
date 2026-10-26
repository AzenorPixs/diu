## MODIFIED Requirements

### Requirement: identifiants Forgejo

`forgejo_push()` MUST utiliser `config/forgejo.username` et
`config/forgejo.token` (mode `600` ou `660`, jamais journalisés). Le token MUST passer
à Git uniquement par `git_with_token`. Si un fichier manque, le push MUST
appeler `forgejo_credentials_setup()` avant `forgejo-auth`. Ce setup MUST
obtenir une confirmation explicite avant toute écriture puis demander les
données interactivement. Le provider MUST rester strict : aucune création,
erreur si identifiants absents ou invalides.

#### Scenario: identifiants absents

- ÉTANT DONNÉ que les identifiants Forgejo n'existent pas
- QUAND un premier push Forgejo est demandé
- ALORS `forgejo_push()` appelle `forgejo_credentials_setup()`
- ET la fonction demande la confirmation de l'utilisateur
- ET le parcours d'initialisation demande les informations requises après confirmation
- ET les fichiers d'identifiants sont créés avec les permissions `600`
- ET le push n'est tenté qu'après validation des identifiants

#### Scenario: initialisation des identifiants refusée

- ÉTANT DONNÉ que les identifiants Forgejo n'existent pas
- QUAND `forgejo_credentials_setup()` est refusée par l'utilisateur
- ALORS aucun fichier d'identifiant n'est créé
- ET `forgejo-auth` n'est pas appelé
- ET aucun push n'est tenté

#### Scenario: identifiants invalides

- ÉTANT DONNÉ qu'un fichier d'identifiant existe avec des permissions
  incorrectes ou une valeur vide
- QUAND un push Forgejo est demandé
- ALORS la commande échoue explicitement
- ET le contenu de l'identifiant n'est jamais affiché

#### Scenario: Identifiants partagés existants

- **WHEN** `config/forgejo.username` et `config/forgejo.token` sont non vides et ont chacun le mode exact `600` ou `660`
- **THEN** les lecteurs les acceptent dans les parcours Git et API existants
- **AND** leurs contenus et leurs permissions restent inchangés
- **AND** les autres modes sont refusés avant lecture sans affichage des identifiants
- **AND** la protection des secrets temporaires reste inchangée
