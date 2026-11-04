## MODIFIED Requirements

### Requirement: Mise à jour dédiée du paquet DIU

La commande `rid diu update` SHALL rechercher et télécharger exclusivement depuis les releases GitHub configurées dans le `project.env` du projet DIU situé dans `DEVOPS_PROJECTS_ROOT`. Elle SHALL ignorer les configurations Forgejo et GitLab, même partielles ou invalides, et ne SHALL NOT interroger ces fournisseurs. Elle SHALL parcourir toutes les pages et choisir la version stable x.y.z en priorité, puis la version la plus élevée selon dpkg dans sa catégorie, parmi les assets `diu_<version>_all.deb` et tags `v<version>` admissibles. Les brouillons et préversions GitHub SHALL être exclus. L'accès GitHub privé SHALL réutiliser le mécanisme d'identifiants GitHub du projet.

#### Scenario: Comparaison entre fournisseurs
- **WHEN** les releases GitHub exposent plusieurs paquets DIU admissibles
- **THEN** la commande privilégie une version stable x.y.z puis sélectionne la version la plus élevée de cette catégorie

#### Scenario: Autres fournisseurs configurés
- **WHEN** Forgejo ou GitLab sont configurés, même de manière partielle ou invalide
- **THEN** la commande les ignore sans les interroger

#### Scenario: Configuration partielle
- **WHEN** la configuration GitHub est absente ou partielle
- **THEN** la commande retourne une erreur sans installer de paquet

#### Scenario: Fournisseur absent
- **WHEN** la configuration GitHub est absente
- **THEN** la commande retourne une erreur sans installer de paquet

#### Scenario: Dépôt configuré inaccessible
- **WHEN** le dépôt GitHub configuré ne peut pas être interrogé ou sa réponse est invalide
- **THEN** la commande retourne une erreur sans installer de paquet ni recourir à un autre fournisseur

#### Scenario: Dépôt GitHub privé
- **WHEN** GitHub est privé et les identifiants du projet sont valides
- **THEN** ses releases et l'asset retenu sont accessibles par l'API authentifiée
- **AND** le jeton n'est ni journalisé ni transmis à une autre origine lors d'une redirection

#### Scenario: Dépôt GitHub public sans identifiant
- **WHEN** GitHub est public et aucun jeton local n'existe
- **THEN** la recherche et le téléchargement restent possibles sans authentification
