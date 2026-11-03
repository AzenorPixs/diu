## MODIFIED Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`rid diu update` SHALL privilégier GitHub configuré dans `ENV_DEVOPS_PROJECTS_ROOT/diu/project.env`, puis Forgejo en secours. Elle SHALL NOT interroger GitLab. Chaque fournisseur SHALL être validé indépendamment. Elle SHALL parcourir toutes les pages, exclure les brouillons et préversions, sélectionner un asset `diu_<version>_all.deb` lié au tag `v<version>`, en privilégiant les versions stables x.y.z puis la plus élevée selon dpkg. GitHub privé SHALL réutiliser les identifiants du projet.

#### Scenario: Comparaison entre fournisseurs
- **WHEN** GitHub fournit un paquet admissible, même si Forgejo en possède un plus récent
- **THEN** la commande retient le meilleur candidat GitHub et n'interroge pas Forgejo

#### Scenario: Autres fournisseurs configurés
- **WHEN** GitLab ou une configuration Forgejo invalide sont présents et que GitHub fournit un candidat
- **THEN** la commande les ignore sans les interroger

#### Scenario: Configuration partielle
- **WHEN** GitHub est partiellement configuré et Forgejo est valide et disponible
- **THEN** la commande signale l'échec GitHub et utilise Forgejo

#### Scenario: Fournisseur absent
- **WHEN** GitHub est absent ou ne propose aucun paquet admissible et Forgejo est valide et disponible
- **THEN** la commande utilise le meilleur candidat Forgejo

#### Scenario: Dépôt configuré inaccessible
- **WHEN** GitHub est inaccessible ou retourne une réponse invalide
- **THEN** la commande essaie Forgejo et retourne une erreur sans installation si le secours échoue

#### Scenario: Dépôt GitHub privé
- **WHEN** GitHub est privé et les identifiants du projet sont valides
- **THEN** ses releases et l'asset retenu sont accessibles par l'API authentifiée
- **AND** le jeton n'est ni journalisé ni transmis à une autre origine lors d'une redirection

#### Scenario: Dépôt GitHub public sans identifiant
- **WHEN** GitHub est public et aucun jeton local n'existe
- **THEN** la recherche et le téléchargement restent possibles sans authentification

#### Scenario: GitHub déjà à jour
- **WHEN** GitHub fournit un candidat égal ou inférieur à la version installée
- **THEN** aucune installation ni consultation de Forgejo ne sont réalisées

#### Scenario: Échec après sélection
- **WHEN** le téléchargement, la validation du paquet ou l'installation échoue après sélection d'un candidat
- **THEN** la commande signale l'échec sans essayer un autre fournisseur
