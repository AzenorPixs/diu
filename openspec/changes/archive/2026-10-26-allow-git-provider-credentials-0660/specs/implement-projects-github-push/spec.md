## MODIFIED Requirements

### Requirement: identifiants GitHub

Le système MUST initialiser et utiliser les identifiants GitHub locaux avec
des permissions restrictives.

Le système DOIT initialiser et utiliser `config/github.username` et
`config/github.token` selon le parcours sécurisé des autres fournisseurs.

Les deux fichiers MUST être limités aux permissions exactes `600` ou `660`, MUST NOT
être affichés dans les journaux et le token MUST être transmis à Git
uniquement par le mécanisme temporaire existant `git_with_token`.

#### Scenario: identifiants absents

- ÉTANT DONNÉ que les identifiants GitHub n'existent pas
- QUAND un premier push GitHub est demandé
- ALORS l'utilisateur est invité à saisir le nom d'utilisateur et le token
- ET le token est saisi sans affichage puis confirmé
- ET les fichiers d'identifiants sont créés avec les permissions `600`

#### Scenario: identifiants invalides

- ÉTANT DONNÉ qu'un fichier d'identifiant existe avec des permissions
  incorrectes ou une valeur vide
- QUAND un push GitHub est demandé
- ALORS la commande échoue explicitement
- ET le contenu de l'identifiant n'est jamais affiché

#### Scenario: Identifiants partagés existants

- **WHEN** `config/github.username` et `config/github.token` sont non vides et ont chacun le mode exact `600` ou `660`
- **THEN** les lecteurs les acceptent dans les parcours Git et API existants
- **AND** leurs contenus et leurs permissions restent inchangés
- **AND** les autres modes sont refusés avant lecture sans affichage des identifiants
- **AND** la protection des secrets temporaires reste inchangée
