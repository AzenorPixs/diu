# system-debian-apt Specification

## Purpose

Gérer les dépôts Debian officiels depuis le module system, avec le format
deb822 à partir de Trixie et le format historique pour les versions antérieures.

## Requirements

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

Le DIU SHALL supporter les quatre contextes suivants :
`diu system update apt debian` met à jour les paquets Debian officiels avec
les informations détaillées des cibles ; `diu system update apt` exécute une
seule transaction globale `apt-get update` puis `apt-get dist-upgrade -y` ;
`diu system update` délègue à ce contexte global ; `diu update` réutilise ce
contexte pour sa partie APT avant la mise à jour du DIU.

#### Scenario: Mise à jour officielle

- **WHEN** `diu system update apt debian` est exécuté
- **THEN** seuls les paquets des dépôts Debian officiels sont traités et les
  cibles sont affichées paquet par paquet

#### Scenario: Mise à jour APT globale

- **WHEN** `diu system update apt` est exécuté
- **THEN** APT actualise ses index puis exécute une seule transaction
  `dist-upgrade -y`

#### Scenario: Module system

- **WHEN** `diu system update` est exécuté
- **THEN** il délègue à `diu system update apt`

#### Scenario: Mise à jour DIU

- **WHEN** `diu update` est exécuté
- **THEN** sa partie APT réutilise le contexte APT global avant la mise à jour
  de DIU
