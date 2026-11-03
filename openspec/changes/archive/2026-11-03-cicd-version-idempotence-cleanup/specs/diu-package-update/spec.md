## MODIFIED Requirements

### Requirement: Mise à jour dédiée du paquet DIU

La commande `rid diu update` SHALL rechercher les releases Forgejo, GitHub et GitLab configurés dans le `project.env` du projet DIU situé dans `DEVOPS_PROJECTS_ROOT`. Elle SHALL parcourir toutes les pages et choisir la version stable x.y.z en priorité, puis la version la plus élevée selon dpkg dans sa catégorie, parmi les assets `diu_<version>_all.deb` et tags `v<version>` admissibles. Les brouillons et préversions signalés par Forgejo ou GitHub SHALL être exclus. L'accès GitHub privé SHALL réutiliser le mécanisme d'identifiants GitHub du projet.

#### Scenario: Comparaison entre fournisseurs
- **WHEN** plusieurs dépôts configurés exposent des paquets DIU admissibles
- **THEN** la commande privilégie une version stable x.y.z puis sélectionne la version la plus élevée de cette catégorie

#### Scenario: Configuration partielle
- **WHEN** un bloc fournisseur est partiel ou une réponse invalide
- **THEN** la commande retourne une erreur sans installer de paquet

#### Scenario: Fournisseur absent
- **WHEN** un bloc fournisseur est entièrement absent
- **THEN** il est ignoré

#### Scenario: Dépôt configuré inaccessible
- **WHEN** un fournisseur configuré ne peut pas être interrogé
- **THEN** la commande retourne une erreur sans installer de paquet

#### Scenario: Dépôt GitHub privé
- **WHEN** GitHub est privé et les identifiants du projet sont valides
- **THEN** ses releases et l'asset retenu sont accessibles par l'API authentifiée
- **AND** le jeton n'est ni journalisé ni transmis à une autre origine lors d'une redirection

#### Scenario: Dépôt GitHub public sans identifiant
- **WHEN** GitHub est public et aucun jeton local n'existe
- **THEN** la recherche et le téléchargement restent possibles sans authentification

### Requirement: Installation contrôlée

La commande SHALL comparer la version sélectionnée à la version installée selon la priorité DIU puis dpkg dans la même catégorie, et ne SHALL NOT réinstaller une version égale. Avant installation, elle SHALL vérifier le nom, la version et l'architecture du paquet téléchargé. Les téléchargements temporaires SHALL être nettoyés et les erreurs signalées.

#### Scenario: Mise à jour disponible
- **WHEN** le paquet téléchargé possède les métadonnées attendues et une version supérieure à celle installée selon la priorité DIU
- **THEN** la commande installe ce paquet avec dpkg

#### Scenario: Version déjà installée ou supérieure
- **WHEN** la version installée est égale ou supérieure au candidat selon la priorité DIU
- **THEN** aucune installation n'est lancée

#### Scenario: Paquet incohérent
- **WHEN** le nom, la version ou l'architecture du paquet ne correspond pas au candidat
- **THEN** la commande retourne une erreur sans installation
