## MODIFIED Requirements

### Requirement: commande de publication Forgejo

DIU MUST exposer `rid projects forgejo push <ID PROJECT>` et sa variante
`all`. Pour un dépôt existant, il MUST réussir le fetch authentifié avant
le push ; pour un dépôt absent, déléguer la création au premier push sans
fetch ni création API. La branche MUST utiliser `--force-with-lease`, le
tag rester sans forçage et le push démarrer sans confirmation supplémentaire
si configuration et identifiants sont valides. Les échecs MUST respecter
`git-provider-availability`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu` et un dépôt Forgejo existant
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS les références du remote Forgejo configuré sont récupérées avant le
  push de branche
- ET le dépôt local est poussé vers le dépôt Forgejo distant configuré avec
  `--force-with-lease` pour la branche publiée
- ET la branche distante configurée reçoit la branche locale publiée
- ET le tag pointant sur le dernier commit, s'il existe, est publié sans
  option de forçage

#### Scenario: récupération Forgejo en échec

- ÉTANT DONNÉ un dépôt Forgejo existant
- QUAND la récupération authentifiée de ses références échoue pour une cause autre qu'une indisponibilité reconnue
- ALORS la commande échoue explicitement
- ET aucun push de branche ni de tag n'est exécuté

#### Scenario: dépôt distant absent

- ÉTANT DONNÉ le dépôt local du projet `diu` et un dépôt Forgejo distant
  configuré mais absent
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS aucune récupération de références n'est exécutée
- ET aucun appel API de création n'est exécuté
- ET le premier push Git Forgejo crée le dépôt selon la configuration serveur
- ET la branche distante configurée reçoit la branche locale publiée avec
  `--force-with-lease`
- ET le tag pointant sur le dernier commit, s'il existe, est publié sans
  option de forçage

#### Scenario: publication groupée

- ÉTANT DONNÉ plusieurs projets configurés pour Forgejo
- QUAND l'utilisateur exécute `rid projects forgejo push all`
- ALORS chaque projet sélectionné est publié par le parcours Forgejo unitaire

#### Scenario: sélection explicite de Forgejo

- ÉTANT DONNÉ que le projet possède déjà une configuration GitLab ou GitHub
- QUAND l'utilisateur exécute `rid projects forgejo push <ID PROJECT>`
- ALORS la commande sélectionne explicitement le fournisseur Forgejo
- ET elle utilise ou initialise les variables `REMOTE_FORGEJO_*`
- ET elle ne remplace pas les configurations GitLab ou GitHub

#### Scenario: publication Forgejo sans confirmation

- ÉTANT DONNÉ une configuration Forgejo et des identifiants valides
- QUAND l'utilisateur exécute `rid projects forgejo push <ID PROJECT>`
- ALORS le parcours Forgejo ne demande pas de confirmation avant le push
- ET le push démarre après les vérifications existantes

#### Scenario: Indisponibilité reconnue avant le push

- **WHEN** la vérification du dépôt ou la récupération préalable rencontre une indisponibilité reconnue
- **THEN** aucun push n'est exécuté
- **AND THEN** le résultat public suit git-provider-availability : publication non confirmée, retour zéro et statut interne d'indisponibilité

