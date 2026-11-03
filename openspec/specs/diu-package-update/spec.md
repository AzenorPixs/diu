# diu-package-update Specification

## Purpose
Rechercher et installer de manière contrôlée la dernière version disponible du paquet DIU en priorité dans les releases GitHub configurées, avec Forgejo en secours.

## Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`rid diu update` SHALL privilégier GitHub configuré dans `DEVOPS_PROJECTS_ROOT/diu/project.env`, puis Forgejo en secours. Elle SHALL NOT interroger GitLab. Chaque fournisseur SHALL être validé indépendamment. Elle SHALL parcourir toutes les pages, exclure les brouillons et préversions, sélectionner un asset `diu_<version>_all.deb` lié au tag `v<version>`, en privilégiant les versions stables x.y.z puis la plus élevée selon dpkg. GitHub privé SHALL réutiliser les identifiants du projet.

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
