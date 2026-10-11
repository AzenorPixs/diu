# Spec Delta

## MODIFIED Requirements

### Requirement: commande de publication Forgejo

Le système MUST exposer la commande `rid projects forgejo push <ID PROJECT>`
et la commande groupée `rid projects forgejo push all`.

Avant la publication, le système MUST vérifier l'existence du dépôt Forgejo.
Pour un dépôt existant, il MUST récupérer les références du remote Forgejo
configuré par le mécanisme authentifié et MUST arrêter le push si cette
récupération échoue. Pour un dépôt absent, il MUST omettre cette récupération
et déléguer la création au premier push Git, sans appel API de création,
selon forgejo-auth.

Le push de branche MUST utiliser `--force-with-lease` et la destination
Forgejo explicite configurée. La publication MUST préserver le push du tag
éventuel sans option de forçage. Avec une configuration et des identifiants
valides, le parcours MUST démarrer sans confirmation supplémentaire du push.

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
- QUAND la récupération authentifiée de ses références échoue
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
