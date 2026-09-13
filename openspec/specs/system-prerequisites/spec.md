# system-prerequisites Specification

## Purpose

Définir et installer les prérequis APT obligatoires du module `system` après
la mise à jour des dépôts, de manière ordonnée et idempotente.

## Requirements

### Requirement: Liste obligatoire

Le module `system` SHALL gérer les prérequis suivants :
`aptitude`, `apache2-utils`, `apt-transport-https`, `bash-completion`,
`bind9-dnsutils`, `ca-certificates`, `curl`, `dirmngr`, `ethtool`, `extrepo`,
`git`, `gnupg`, `gpg`, `inetutils-telnet`, `iptables`, `jq`, `lshw`,
`libsecret-tools`, `lsb-release`, `man-db`, `manpages-fr`, `net-tools`, `netcat-traditional`,
`nicstat`, `openssl`, `pciutils`, `python3-pytest`, `ripgrep`, `shellcheck`,
`sudo`, `tcpdump`, `traceroute`, `tree`, `util-linux`, `wget`.

#### Scenario: Liste des prérequis

- **WHEN** la fonction d'installation des prérequis est appelée
- **THEN** elle utilise exactement la liste obligatoire définie ci-dessus

#### Scenario: Paquet Debian pytest

- **WHEN** le prérequis Python pytest est absent
- **THEN** le paquet Debian `python3-pytest` est annoncé et installé

#### Scenario: pytest requis

- **WHEN** `python3-pytest` n'est pas installé
- **THEN** la fonction d'installation l'annonce et l'installe

### Requirement: Installation ordonnée et silencieuse

La fonction SHALL traiter les prérequis dans l'ordre alphabétique. Elle SHALL
produire aucune sortie pour un paquet déjà installé et SHALL afficher chaque
installation de paquet absent.

#### Scenario: Prérequis déjà présents

- **WHEN** tous les prérequis sont installés
- **THEN** aucune ligne de prérequis n'est affichée et aucune installation
  n'est exécutée

#### Scenario: Prérequis manquants

- **WHEN** un ou plusieurs prérequis sont absents
- **THEN** ils sont installés dans l'ordre alphabétique et chaque paquet
  concerné est annoncé

### Requirement: Ordre dans le sous-module des prérequis

La fonction SHALL être appelée après la mise à jour des dépôts APT officiels et
non officiels par le sous-module qui gère les prérequis système.

#### Scenario: Préparation des prérequis

- **WHEN** le sous-module des prérequis système est exécuté
- **THEN** les index et la transaction APT sont terminés avant l'installation
  des prérequis
