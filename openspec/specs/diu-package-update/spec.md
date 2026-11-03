# diu-package-update Specification

## Purpose
Rechercher et installer de manière contrôlée la dernière version disponible du paquet DIU dans les releases du dépôt GitHub configuré.

## Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`rid diu update` SHALL utiliser exclusivement les releases GitHub configurées dans `DEVOPS_PROJECTS_ROOT/diu/project.env`, sans interroger Forgejo ni GitLab. Elle SHALL parcourir toutes les pages, exclure brouillons et préversions et choisir parmi les assets `diu_<version>_all.deb` associés au tag `v<version>` la version stable x.y.z en priorité, puis la plus élevée selon dpkg. L’accès privé SHALL réutiliser les identifiants GitHub du projet.

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

### Requirement: Aide et compatibilité

Les aides SHALL présenter `rid diu update` et `rid update diu` SHALL rester un alias de cette commande.

#### Scenario: Alias historique
- **WHEN** `rid update diu` est invoqué
- **THEN** la même mise à jour ciblée du paquet DIU est exécutée

### Requirement: Décodage des réponses HTTP

La recherche des releases et le téléchargement du paquet SHALL utiliser le
décodage HTTP des encodages pris en charge par `curl`. Un échec de décodage
SHALL interrompre la mise à jour sans installation du paquet.

#### Scenario: Réponse Zstandard prise en charge
- **WHEN** une API ou un paquet est transmis avec `Content-Encoding: zstd` et que `curl` prend en charge cet encodage
- **THEN** les données décompressées sont respectivement analysées ou vérifiées avant installation

#### Scenario: Encodage ou contenu illisible
- **WHEN** `curl` ne peut pas décoder la réponse de l'API ou du paquet
- **THEN** la commande signale l'échec et ne lance aucune installation
