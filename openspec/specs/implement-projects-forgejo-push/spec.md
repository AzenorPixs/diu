# implement-projects-forgejo-push Specification

## Purpose
Définir la publication sécurisée d'un dépôt Git local d'un projet DIU vers un
dépôt Forgejo distant configuré.

## Requirements

### Requirement: commande de publication Forgejo

DIU MUST exposer `diu projects forgejo push <ID PROJECT>` et sa variante
`all`, conformément aux scénarios ci-dessous et à `git-provider-availability`.
La branche MUST utiliser `--force-with-lease` et les tags MUST rester sans
forçage. Pour un dépôt annoncé absent, le lease MUST attendre l'absence de
la branche avec `--force-with-lease=refs/heads/<branche>:` et MUST NOT
dépendre d'une référence héritée ni supprimer une référence locale.

#### Scenario: publication du dépôt local

- **GIVEN** un dépôt local et un dépôt Forgejo existant
- **WHEN** un push Forgejo est demandé
- **THEN** les références authentifiées sont récupérées avant le push
- **AND** la branche distante configurée reçoit la branche locale avec
  `--force-with-lease`
- **AND** le tag du dernier commit, s'il existe, est publié sans forçage

#### Scenario: récupération Forgejo en échec

- **GIVEN** un dépôt Forgejo existant
- **WHEN** le fetch échoue pour une cause autre qu'une indisponibilité reconnue
- **THEN** la commande échoue explicitement sans push de branche ni de tag

#### Scenario: dépôt distant absent

- **GIVEN** un dépôt Forgejo absent
- **WHEN** un push Forgejo est demandé
- **THEN** aucun fetch ni appel API de création n'est exécuté
- **AND** le push utilise `--force-with-lease=refs/heads/<branche>:`
- **AND** Forgejo peut créer le dépôt selon sa configuration serveur
- **AND** aucune référence locale n'est supprimée
- **AND** le tag du dernier commit, s'il existe, est publié sans forçage

#### Scenario: dépôt distant absent avec référence de suivi héritée

- **GIVEN** un dépôt Forgejo absent et une référence de suivi locale héritée
- **WHEN** un push Forgejo est demandé
- **THEN** le lease attend l'absence de la branche distante et ignore
  l'ancienne valeur de suivi
- **AND** aucune référence locale n'est supprimée

#### Scenario: création concurrente de la branche distante

- **GIVEN** un dépôt annoncé absent lors de la vérification
- **WHEN** la branche distante est créée avant le premier push
- **THEN** le lease refuse de l'écraser et la commande échoue explicitement
- **AND** aucun tag n'est publié après ce rejet

#### Scenario: publication groupée

- **WHEN** `diu projects forgejo push all` est demandé
- **THEN** chaque projet sélectionné utilise le parcours Forgejo unitaire

#### Scenario: sélection explicite de Forgejo

- **GIVEN** un projet configuré également pour GitLab ou GitHub
- **WHEN** un push Forgejo est demandé
- **THEN** il utilise ou initialise les variables `REMOTE_FORGEJO_*`
- **AND** les configurations des autres fournisseurs sont conservées

#### Scenario: publication Forgejo sans confirmation

- **GIVEN** une configuration Forgejo et des identifiants valides
- **WHEN** un push Forgejo est demandé
- **THEN** il démarre après vérifications sans confirmation supplémentaire

#### Scenario: Indisponibilité reconnue avant le push

- **WHEN** la vérification ou le fetch rencontre une indisponibilité reconnue
- **THEN** aucun push n'est exécuté
- **AND** le résultat suit `git-provider-availability` : publication non
  confirmée, retour zéro et statut interne d'indisponibilité

### Requirement: configuration Forgejo du projet

La configuration Forgejo MUST utiliser les variables suivantes dans
`project.env` :

```bash
REMOTE_FORGEJO_BASE_URL=
REMOTE_FORGEJO_OWNER=
REMOTE_FORGEJO_REPOSITORY="<ID PROJECT>"
REMOTE_FORGEJO_NAME="origin"
REMOTE_FORGEJO_BRANCH="main"
REMOTE_FORGEJO_SSL_VERIFY="No"
```

`REMOTE_FORGEJO_REPOSITORY` DOIT prendre par défaut l'identifiant du projet,
`REMOTE_FORGEJO_NAME` DOIT prendre par défaut `origin` et
`REMOTE_FORGEJO_BRANCH` DOIT prendre par défaut `main`.

#### Scenario: initialisation au premier push

- ÉTANT DONNÉ que la configuration Forgejo est absente ou incomplète
- QUAND l'utilisateur lance `diu projects forgejo push <ID PROJECT>`
- ALORS `forgejo_update()` est exécutée de manière interactive
- ET les variables Forgejo sont demandées puis enregistrées dans `project.env`
- ET le push ne commence qu'après une configuration complète

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

### Requirement: remote Forgejo HTTPS

Le remote `REMOTE_FORGEJO_NAME` MUST utiliser l'URL construite depuis
`REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER` et `REMOTE_FORGEJO_REPOSITORY`,
au format `https://<hôte>/<propriétaire>/<dépôt>.git`. Le helper MUST ajouter
le remote absent ou réaligner ses URL de récupération et de publication
sur cette seule destination, conformément aux scénarios ci-dessous.
Les autres remotes et `project.env` MUST rester inchangés.

#### Scenario: remote absent ou incohérent

- **GIVEN** le remote Forgejo configuré est absent ou possède une autre URL
- **WHEN** un push Forgejo est demandé
- **THEN** le remote absent est ajouté avec l'URL déclarée
- **AND** un remote incohérent est réaligné sur cette URL

#### Scenario: URL héritée du modèle

- **GIVEN** le remote pointe encore vers le dépôt du modèle
- **WHEN** un push Forgejo est demandé
- **THEN** ses URL sont réalignées sur la configuration du projet
- **AND** un diagnostic explicite indique la correction sans afficher les
  anciennes URL
- **AND** le parcours poursuit les vérifications de publication

#### Scenario: URL de publication distincte ou multiple

- **GIVEN** une URL de récupération correcte et des pushurl incohérentes
- **WHEN** un push Forgejo est demandé
- **THEN** toutes les URL du remote sont ramenées à la destination déclarée
- **AND** les autres remotes sont préservés

#### Scenario: réalignement idempotent

- **GIVEN** les URL du remote correspondent déjà à la destination déclarée
- **WHEN** le helper est réexécuté
- **THEN** aucune écriture de configuration n'est effectuée

#### Scenario: échec du réalignement

- **WHEN** une lecture, une correction ou sa vérification finale échoue
- **THEN** la commande échoue explicitement avant tout push
- **AND** aucun message de correction réussie n'est affiché
- **AND** une correction partielle peut être reprise par réexécution

### Requirement: vérification TLS Forgejo

`REMOTE_FORGEJO_SSL_VERIFY` MUST accepter `Yes` ou `No` et prendre `No` par
défaut. La valeur `No` DOIT désactiver la vérification TLS uniquement pour les
opérations Forgejo authentifiées. Une valeur différente DOIT provoquer un
échec explicite.

#### Scenario: vérification TLS désactivée

- ÉTANT DONNÉ que `REMOTE_FORGEJO_SSL_VERIFY=No`
- QUAND une opération Forgejo authentifiée est exécutée
- ALORS la vérification TLS est désactivée pour cette opération uniquement

### Requirement: aide CLI

Les niveaux d'aide suivants MUST être disponibles et cohérents :

- `diu help` affiche les commandes de premier niveau et leur description
  succincte ;
- `diu projects help` affiche les commandes du niveau `projects`, dont
  `forgejo` ;
- `diu projects forgejo help` affiche `push` et `update` ;
- `diu projects forgejo push help` décrit la publication et rappelle la
  syntaxe `diu projects forgejo push <ID PROJECT>`.

#### Scenario: aide de publication

- ÉTANT DONNÉ que l'utilisateur demande `diu projects forgejo push help`
- QUAND l'aide est affichée
- ALORS la description de la publication et sa syntaxe sont affichées

### Requirement: compatibilité

L'ajout du parcours dédié Forgejo MUST préserver les variables et les
comportements existants des publications Forgejo historique, GitLab et GitHub.

#### Scenario: conservation des fournisseurs

- ÉTANT DONNÉ qu'une publication historique Forgejo, GitLab ou GitHub est
  utilisée
- QUAND le parcours Forgejo dédié est ajouté
- ALORS les variables et le comportement du parcours utilisé sont conservés

### Requirement: serveur temporairement indisponible pendant la publication

La commande publique de push MUST appliquer le contrat de
`git-provider-availability` aux opérations réseau de sa publication. Une
indisponibilité reconnue MUST produire un statut non bloquant, sans être
présentée comme une publication réussie. Les erreurs non qualifiées MUST
conserver leur comportement antérieur.

#### Scenario: fournisseur inaccessible

- **WHEN** une opération réseau du push rencontre une indisponibilité reconnue
- **THEN** la commande affiche une publication non confirmée et retourne zéro

#### Scenario: refus de publication

- **WHEN** Git refuse le push pour une cause autre qu'une indisponibilité reconnue
- **THEN** la commande échoue explicitement
