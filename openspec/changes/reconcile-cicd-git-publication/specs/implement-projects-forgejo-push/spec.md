## MODIFIED Requirements

### Requirement: commande de publication Forgejo

DIU MUST exposer `diu projects forgejo push <ID PROJECT>` et sa variante
`all`, conformément aux scénarios ci-dessous et à `git-provider-availability`.
La branche MUST utiliser `--force-with-lease` et, hors CI/CD, les tags MUST rester sans forçage. Dans le CI/CD, un tag distant divergent MAY être remplacé avec un lease explicite sur sa valeur observée selon `projects-cicd`. Pour un dépôt annoncé absent, le lease MUST attendre l'absence de
la branche avec `--force-with-lease=refs/heads/<branche>:` et MUST NOT
dépendre d'une référence héritée ni supprimer une référence locale.

#### Scenario: publication du dépôt local

- **GIVEN** un dépôt local et un dépôt Forgejo existant
- **WHEN** un push Forgejo est demandé
- **THEN** les références authentifiées sont récupérées avant le push
- **AND** la branche distante configurée reçoit la branche locale avec
  `--force-with-lease`
- **AND** hors CI/CD, le tag du dernier commit, s'il existe, est publié sans forçage

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
- **AND** hors CI/CD, le tag du dernier commit, s'il existe, est publié sans forçage

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
