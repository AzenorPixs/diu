## MODIFIED Requirements

### Requirement: identifiants Forgejo

Le push MUST préparer les identifiants avant les transports. Une paire absente ou incomplète MUST passer par forgejo_credentials_setup avec consentement explicite avant écriture. Les fichiers valides en 600 ou 660 MUST être préservés. Toute paire invalide MUST être rejetée sans remplacement. Le token MUST rester hors des arguments, URL et sorties.

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

#### Scenario: Fin d’entrée avant consentement

- **WHEN** la confirmation est refusée ou l'entrée se termine
- **THEN** aucun fichier n'est créé, modifié ou supprimé ; aucun transport n'est exécuté

#### Scenario: Paire partielle préservée

- **WHEN** une moitié valide existe et le setup est accepté
- **THEN** seul le fichier manquant est publié après validation candidate ; la moitié existante conserve son contenu et son mode

#### Scenario: Échec du setup

- **WHEN** la validation candidate ou la persistance échoue
- **THEN** les fichiers préexistants restent intacts ; les nouveaux fichiers partiels et temporaires sont nettoyés ; aucun push n’est exécuté

#### Scenario: Choix explicite du mode

- **WHEN** le setup doit fournir un token absent
- **THEN** il propose saisie ou création API après consentement ; un échec ne publie aucun identifiant

