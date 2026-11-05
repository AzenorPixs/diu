## ADDED Requirements

### Requirement: Installation d’une version explicitement demandée

`rid diu update <VERSION>` SHALL installer la version exacte depuis une release GitHub publique admissible, quelle que soit la version installée. La version SHALL être valide selon les règles Debian et les contrôles existants. La commande SHALL NOT consulter Forgejo dans ce mode et SHALL signaler toute version absente ou inaccessible sans installation. Les arguments supplémentaires SHALL être refusés.

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

## MODIFIED Requirements

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

