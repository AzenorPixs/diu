## MODIFIED Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`rid diu update` SHALL rechercher en priorité les releases publiques de `https://github.com/AzenorPixs/diu`, sans authentification GitHub et sans dépendre d’un checkout ou d’une configuration GitHub locale. En l’absence de candidat GitHub admissible ou si GitHub est inaccessible, elle SHALL essayer les releases publiques Forgejo si leur configuration locale est disponible. Elle SHALL NOT interroger GitLab. Elle SHALL parcourir toutes les pages, exclure les brouillons et préversions, sélectionner un asset `diu_<version>_all.deb` lié au tag `v<version>`, en privilégiant les versions stables x.y.z puis la plus élevée selon dpkg.

#### Scenario: Dépôt GitHub public sans identifiant
- **WHEN** aucune configuration de projet DIU ni authentification GitHub n’existe
- **THEN** la commande recherche et télécharge anonymement le paquet admissible depuis GitHub

#### Scenario: Jeton GitHub présent
- **WHEN** un jeton GitHub local existe
- **THEN** la commande ne le lit ni ne l’utilise

#### Scenario: Comparaison entre fournisseurs
- **WHEN** GitHub fournit un candidat admissible
- **THEN** la commande ne consulte pas Forgejo, même si sa version est supérieure

#### Scenario: Secours Forgejo
- **WHEN** GitHub est inaccessible, invalide ou sans candidat admissible
- **THEN** la commande essaie Forgejo public si sa configuration est disponible et échoue sans installation si aucun candidat n’est disponible

#### Scenario: GitHub déjà à jour
- **WHEN** GitHub fournit un candidat égal ou inférieur à la version installée
- **THEN** aucune installation ni consultation de Forgejo ne sont réalisées

#### Scenario: Échec après sélection
- **WHEN** le téléchargement, la validation du paquet ou l’installation échoue après sélection d’un candidat
- **THEN** la commande signale l’échec sans essayer un autre fournisseur

#### Scenario: Autres fournisseurs configurés
- **WHEN** GitLab ou une configuration Forgejo invalide sont présents et que GitHub fournit un candidat
- **THEN** la commande les ignore sans les interroger

#### Scenario: Configuration partielle
- **WHEN** la configuration Forgejo est partielle et GitHub fournit un candidat
- **THEN** la commande utilise GitHub sans consulter Forgejo

#### Scenario: Fournisseur absent
- **WHEN** GitHub ne propose aucun paquet admissible et Forgejo est valide et disponible
- **THEN** la commande utilise le meilleur candidat Forgejo

#### Scenario: Dépôt configuré inaccessible
- **WHEN** GitHub est inaccessible ou retourne une réponse invalide
- **THEN** la commande essaie Forgejo et retourne une erreur sans installation si le secours échoue

#### Scenario: Dépôt GitHub privé
- **WHEN** des identifiants GitHub privés sont présents
- **THEN** la commande les ignore et consulte exclusivement le dépôt public DIU
