## MODIFIED Requirements

### Requirement: commande de publication Forgejo

Le système MUST exposer la commande `rid projects forgejo push <ID PROJECT>`
et la commande groupée `rid projects forgejo push all`.

#### Scenario: publication du dépôt local

- ÉTANT DONNÉ le dépôt local du projet `diu`
- QUAND l'utilisateur exécute `rid projects forgejo push diu`
- ALORS le dépôt local est poussé vers le dépôt Forgejo distant configuré avec
  `--force-with-lease` pour la branche publiée
- ET la branche distante configurée reçoit la branche locale publiée
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
