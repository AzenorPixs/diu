# diu-package-update Specification

## Purpose
Rechercher et installer de manière contrôlée la dernière version disponible du paquet DIU dans les releases des dépôts configurés.

## Requirements

### Requirement: Mise à jour dédiée du paquet DIU

La commande `rid diu update` SHALL rechercher les releases publiques des fournisseurs Forgejo, GitHub et GitLab configurés dans le `project.env` du projet DIU situé dans `DEVOPS_PROJECTS_ROOT`. Elle SHALL parcourir toutes les pages et choisir la version Debian valide la plus élevée correspondant à un asset `diu_<version>_all.deb` et un tag `v<version>`. Les brouillons et préversions signalés par Forgejo ou GitHub SHALL être exclus.

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

### Requirement: Installation contrôlée

La commande SHALL comparer la version sélectionnée à la version installée avec dpkg et ne SHALL NOT rétrograder ni réinstaller une version égale. Avant installation, elle SHALL vérifier le nom, la version et l'architecture du paquet téléchargé. Les téléchargements temporaires SHALL être nettoyés et les erreurs signalées.

#### Scenario: Mise à jour disponible
- **WHEN** le paquet téléchargé possède les métadonnées attendues et une version supérieure à celle installée
- **THEN** la commande installe ce paquet avec dpkg

#### Scenario: Version déjà installée ou supérieure
- **WHEN** la version installée est égale ou supérieure au candidat
- **THEN** aucune installation n'est lancée

#### Scenario: Paquet incohérent
- **WHEN** le nom, la version ou l'architecture du paquet ne correspond pas au candidat
- **THEN** la commande retourne une erreur sans installation

### Requirement: Aide et compatibilité

Les aides SHALL présenter `rid diu update` et `rid update diu` SHALL rester un alias de cette commande.

#### Scenario: Alias historique
- **WHEN** `rid update diu` est invoqué
- **THEN** la même mise à jour ciblée du paquet DIU est exécutée
