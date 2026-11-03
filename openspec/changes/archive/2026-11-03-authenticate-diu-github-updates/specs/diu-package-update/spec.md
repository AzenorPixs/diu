## MODIFIED Requirements

### Requirement: Mise à jour dédiée du paquet DIU

La commande `rid diu update` SHALL rechercher les releases Forgejo, GitHub et GitLab configurés dans le `project.env` du projet DIU situé dans `DEVOPS_PROJECTS_ROOT`. Elle SHALL parcourir toutes les pages et choisir la version Debian valide la plus élevée correspondant à un asset `diu_<version>_all.deb` et un tag `v<version>`. Les brouillons et préversions signalés par Forgejo ou GitHub SHALL être exclus. L'accès GitHub privé SHALL réutiliser le mécanisme d'identifiants GitHub du projet.

#### Scenario: Comparaison entre fournisseurs
- **WHEN** plusieurs dépôts configurés exposent des paquets DIU admissibles
- **THEN** la commande sélectionne la version Debian la plus élevée parmi leurs releases admissibles

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
