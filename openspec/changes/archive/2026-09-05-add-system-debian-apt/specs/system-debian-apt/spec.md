# Delta for system-debian-apt

## ADDED Requirements

### Requirement: Variables de configuration

Le DIU SHALL déclarer les cinq variables APT Debian statiques, activées dans
le scope system, avec les valeurs par défaut demandées.

#### Scenario: Valeurs initiales

- **WHEN** une variable est absente
- **THEN** le générateur l'exporte avec sa valeur par défaut et la persiste
  dans `system.env`.

### Requirement: Configuration Debian par version

Le moteur SHALL écrire le format deb822 pour Trixie et les versions ultérieures
et le format historique pour Bookworm et les versions antérieures.

#### Scenario: Debian Trixie

- **WHEN** la release courante est Trixie ou plus récente
- **THEN** `debian.sources` contient release et security, avec les options
  variables, sans modifier les fichiers tiers.

#### Scenario: Debian Bookworm ou antérieure

- **WHEN** la release courante est Bookworm ou antérieure
- **THEN** `/etc/apt/sources.list` contient les dépôts Debian officiels et
  l'ancien `debian.sources` géré par le DIU est supprimé.

### Requirement: Contextes system

Le DIU SHALL distinguer la mise à jour Debian officielle de la mise à jour de
tous les dépôts APT.

#### Scenario: Mise à jour officielle

- **WHEN** `diu system update apt debian` est exécuté
- **THEN** les dépôts Debian officiels sont régénérés puis leurs index sont
  actualisés.

#### Scenario: Mise à jour APT globale

- **WHEN** `diu system update apt` est exécuté
- **THEN** les index officiels et tiers sont actualisés.
