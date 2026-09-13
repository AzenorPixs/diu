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

### Requirement: Mise à jour du sous-module APT

Le sous-module `rid system update apt` SHALL régénérer la configuration des
dépôts Debian officiels avant d'actualiser les index et d'exécuter la
transaction unique `apt-get dist-upgrade -y`. Cette régénération SHALL prendre
en compte `SYSTEM_APT_DEBIAN_UPDATES`, `SYSTEM_APT_DEBIAN_BACKPORT`,
`SYSTEM_APT_DEBIAN_CONTRIB`, `SYSTEM_APT_DEBIAN_NONFRFEE` et
`SYSTEM_APT_DEBIAN_SOURCES`, tout en préservant les dépôts tiers.

#### Scenario: Variables activées

- **WHEN** les variables contrib, non-free et backports valent `1`
- **THEN** les composants et suites correspondants sont présents avant la
  mise à jour globale appelée par `ridu`

#### Scenario: Variables désactivées

- **WHEN** une variable de dépôt vaut `0`
- **THEN** l'élément correspondant est absent de la configuration Debian
  régénérée

#### Scenario: Mise à jour officielle

- **WHEN** `diu system update apt debian` est exécuté
- **THEN** seuls les paquets des dépôts Debian officiels sont traités et les
  cibles sont affichées paquet par paquet

#### Scenario: Mise à jour APT globale

- **WHEN** `diu system update apt` est exécuté
- **THEN** APT actualise ses index puis exécute une seule transaction
  `dist-upgrade -y`

### Requirement: Isolation de Flatpak du sous-module APT

Le sous-module APT de `system` SHALL ne pas appliquer `SYSTEM_FLATPAK` et
SHALL ne jamais appeler `flatpak update`. Seule la commande explicite
`rid system update flatpak` SHALL pouvoir mettre à jour le paquet Debian
`flatpak`.

#### Scenario: Mise à jour APT

- **WHEN** `rid system update apt` est exécuté
- **THEN** aucune mise à jour ciblée de Flatpak n'est invoquée
- **AND** `flatpak update` n'est pas exécuté
