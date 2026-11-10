# diu-package-update Specification

## Purpose
Rechercher et installer de manière contrôlée la dernière version disponible du paquet DIU en priorité dans les releases publiques GitHub de AzenorPixs/diu, sans authentification, avec Forgejo configuré en secours.

## Requirements

### Requirement: Mise à jour dédiée du paquet DIU

`diu diu update` SHALL rechercher en priorité les releases publiques de `https://github.com/AzenorPixs/diu`, sans authentification GitHub et sans dépendre d’un checkout ou d’une configuration GitHub locale. En l’absence de candidat GitHub admissible ou si GitHub est inaccessible, elle SHALL essayer les releases publiques Forgejo si leur configuration locale est disponible. Elle SHALL NOT interroger GitLab. 

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

### Requirement: Sélection des versions de mise à jour DIU

La commande SHALL parcourir toutes les pages, exclure les brouillons et préversions, sélectionner un asset `diu_<version>_all.deb` lié au tag `v<version>`, en privilégiant les versions stables x.y.z puis la plus élevée selon dpkg.

#### Scenario: Application de la règle

- **WHEN** la commande sélectionne un candidat de mise à jour
- **THEN** les pages, états de release, noms, tags et versions sont traités selon ces règles

### Requirement: Installation contrôlée

Sans version explicite, la commande SHALL comparer la version sélectionnée à la version installée selon la priorité DIU puis dpkg dans la même catégorie, et ne SHALL NOT réinstaller une version égale. Avant installation, elle SHALL vérifier le nom, la version et l'architecture du paquet téléchargé. Les téléchargements temporaires SHALL être nettoyés et les erreurs signalées.

#### Scenario: Mise à jour disponible
- **WHEN** le paquet téléchargé possède les métadonnées attendues et une version supérieure à celle installée selon la priorité DIU
- **THEN** la commande installe ce paquet avec dpkg

#### Scenario: Version déjà installée ou supérieure
- **WHEN** aucune version explicite n’est demandée et la version installée est égale ou supérieure au candidat selon la priorité DIU
- **THEN** aucune installation n'est lancée

#### Scenario: Paquet incohérent
- **WHEN** le nom, la version ou l'architecture du paquet ne correspond pas au candidat
- **THEN** la commande retourne une erreur sans installation

### Requirement: Aide et compatibilité

Les aides SHALL présenter `diu diu update` et `diu update diu` SHALL rester un alias de cette commande.

#### Scenario: Alias historique
- **WHEN** `diu update diu` est invoqué
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

### Requirement: Installation d’une version explicitement demandée

`diu diu update <VERSION>` SHALL installer la version exacte depuis une release GitHub publique admissible, quelle que soit la version installée. La version SHALL être valide selon les règles Debian et les contrôles existants. La commande SHALL NOT consulter Forgejo dans ce mode et SHALL signaler toute version absente ou inaccessible sans installation. Les arguments supplémentaires SHALL être refusés.

#### Scenario: Réinstallation de la version installée
- **WHEN** la version demandée correspond à la version installée et à un paquet admissible GitHub
- **THEN** le paquet est vérifié puis installé de nouveau

#### Scenario: Version plus ancienne ou plus récente
- **WHEN** la version demandée est plus ancienne ou plus récente que la version installée et possède un paquet admissible GitHub
- **THEN** cette version exacte est vérifiée puis installée

#### Scenario: Version absente ou inaccessible
- **WHEN** la version demandée est absente de GitHub ou GitHub est inaccessible
- **THEN** la commande échoue sans installation et sans consultation de Forgejo

#### Scenario: Version ou arguments invalides
- **WHEN** la version est invalide ou des arguments supplémentaires sont fournis
- **THEN** la commande échoue avant téléchargement ou installation

#### Scenario: Contrôles conservés
- **WHEN** les métadonnées du paquet téléchargé diffèrent de la version demandée, du nom DIU ou de l’architecture attendue
- **THEN** aucune installation n’est lancée

### Requirement: Résultat synthétique de la mise à jour DIU

La commande SHALL signaler un résultat réussi avec une coche et masquer les détails techniques des opérations réussies. En cas d'échec, elle SHALL afficher les diagnostics utiles et retourner un état d'échec.

#### Scenario: Version déjà à jour
- **WHEN** aucune version explicite n'est demandée et le candidat n'est pas supérieur à la version installée
- **THEN** la commande affiche une coche et les versions installée et disponible sans installer le paquet

#### Scenario: Installation réussie
- **WHEN** le paquet sélectionné est vérifié et installé
- **THEN** la commande affiche une coche et les versions avant et après installation sans les détails de téléchargement ou de dpkg

#### Scenario: Échec d'une opération
- **WHEN** la sélection, le téléchargement, la vérification ou l'installation échoue
- **THEN** la commande affiche les diagnostics disponibles et retourne un échec

#### Scenario: Secours réussi
- **WHEN** GitHub échoue mais que le secours Forgejo réussit
- **THEN** les détails de l'échec de GitHub restent masqués et seul le résultat réussi est affiché
