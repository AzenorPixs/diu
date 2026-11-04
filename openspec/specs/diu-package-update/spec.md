# diu-package-update Specification

## Purpose
Rechercher et installer de manière contrôlée la dernière version disponible du paquet DIU en priorité dans les releases publiques GitHub de AzenorPixs/diu, sans authentification, avec Forgejo configuré en secours.

## Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`rid diu update` SHALL consulter anonymement les releases publiques de `https://github.com/AzenorPixs/diu`, sans configuration locale. Si GitHub échoue ou ne fournit aucun candidat, elle SHALL essayer Forgejo public configuré. Elle SHALL NOT interroger GitLab. Elle SHALL paginer, exclure brouillons et préversions et retenir un asset `diu_<version>_all.deb` lié au tag `v<version>`, en privilégiant les versions stables x.y.z puis la plus élevée selon dpkg.

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
