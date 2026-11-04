# system-prerequisites Specification

## Purpose

Définir et installer les prérequis APT obligatoires du module `system` après
la mise à jour des dépôts, de manière ordonnée et idempotente.

## Requirements

### Requirement: Liste obligatoire

Le module system SHALL conserver exactement le socle commun de paquets détaillé ci-dessous. La liste effective SHALL compléter ce seul socle par les paquets de la famille définie par SYSTEM_DEBIAN_ENVIRONNEMENT.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Liste des prérequis

- **WHEN** la fonction d'installation des prérequis est appelée
- **THEN** tous les paquets du socle sont vérifiés avec les compléments de la famille

#### Scenario: Paquet Debian pytest

- **WHEN** le prérequis Python pytest est absent
- **THEN** le paquet Debian `python3-pytest` est annoncé et installé

#### Scenario: pytest requis

- **WHEN** `python3-pytest` n'est pas installé
- **THEN** la fonction d'installation l'annonce et l'installe

#### Scenario: Socle exact et complément des prérequis système

- **WHEN** le module system constitue la liste effective des prérequis
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Le module `system` SHALL conserver le socle commun suivant :
`aptitude`, `apache2-utils`, `apt-transport-https`, `bash-completion`,
`bind9-dnsutils`, `ca-certificates`, `curl`, `dirmngr`, `ethtool`, `extrepo`,
`git`, `gnupg`, `gpg`, `inetutils-telnet`, `iptables`, `jq`, `lshw`,
`libpq5`, `libsecret-tools`, `lsb-release`, `man-db`, `manpages-fr`, `net-tools`, `netcat-traditional`,
`nicstat`, `openssl`, `pciutils`, `postgresql-client`, `python3-pytest`, `ripgrep`, `shellcheck`,
`sudo`, `tcpdump`, `traceroute`, `tree`, `util-linux`, `wget`.

La liste effective SHALL être ce socle complété uniquement par les paquets de
la famille définie par `SYSTEM_DEBIAN_ENVIRONNEMENT`.

### Requirement: Installation ordonnée et silencieuse

La fonction SHALL vérifier individuellement chaque paquet avec `dpkg-query`,
traiter les prérequis dans l'ordre alphabétique et éliminer les doublons.
Elle SHALL produire aucune sortie pour un paquet déjà installé et SHALL
annoncer chaque paquet absent avant son installation individuelle par
`apt-get install -y -- <paquet>`.
Elle SHALL signaler et propager un échec APT sans installer les paquets suivants.

#### Scenario: Prérequis déjà présents

- **WHEN** tous les prérequis sont installés
- **THEN** aucune ligne de prérequis n'est affichée et aucune installation n'est exécutée

#### Scenario: Prérequis manquants

- **WHEN** un ou plusieurs prérequis sont absents
- **THEN** ils sont annoncés et installés individuellement dans l'ordre alphabétique, une seule fois chacun

#### Scenario: Aptitude déjà présent

- **WHEN** aptitude est installé mais un autre prérequis manque
- **THEN** la fonction installe le prérequis manquant sans réinstaller aptitude

#### Scenario: Échec d'installation

- **WHEN** APT échoue pour un paquet absent
- **THEN** la fonction signale ce paquet et retourne un statut non nul sans installer le suivant

### Requirement: Ordre dans le sous-module des prérequis

Dans `system_apt_update`, la fonction SHALL rester appelée après la mise à
jour des dépôts APT officiels et non officiels et le nettoyage APT.
Le parcours historique sans argument SHALL appeler la même fonction à la
place de ses listes générales, avant sa configuration APT.
Le parcours historique et la fonction commune SHALL NOT installer DisplayLink ; seules les commandes explicites system drivers SHALL gérer ce pilote.

#### Scenario: Préparation des prérequis

- **WHEN** la mise à jour système est exécutée
- **THEN** les index, la transaction APT et le nettoyage sont terminés avant l'installation des prérequis

#### Scenario: Installation historique

- **WHEN** le parcours sans argument atteint son bloc de prérequis
- **THEN** il appelle system_install_prerequisites avant sa configuration APT
- **AND** il n'utilise plus aptitude comme témoin de toute la liste

#### Scenario: DisplayLink conservé

- **WHEN** le parcours historique s'exécute, quel que soit l'environnement ou la valeur statique DisplayLink
- **THEN** aucun paquet DisplayLink n'est installé automatiquement

### Requirement: Compléments par famille

La fonction SHALL ajouter `acl` au socle pour LXC, PHYSICAL, VM et DOCKER.
Elle SHALL ajouter `acl`, `conntrack`, `glances` et `rsync` pour PROXMOX.
DOCKER et VM SHALL avoir exactement les mêmes prérequis.
Pour une valeur absente, vide, UNSET ou inconnue, la fonction SHALL conserver
uniquement le socle initial sans complément spécifique.

#### Scenario: Familles standards

- **WHEN** l'environnement vaut LXC, PHYSICAL, VM ou DOCKER
- **THEN** la liste effective contient le socle et acl, sans complément Proxmox ou DisplayLink

#### Scenario: Famille Proxmox

- **WHEN** l'environnement vaut PROXMOX
- **THEN** la liste effective contient le socle et acl, conntrack, glances, rsync

#### Scenario: Équivalence Docker et VM

- **WHEN** les paquets absents sont les mêmes dans DOCKER et VM
- **THEN** les deux familles produisent les mêmes installations

#### Scenario: Environnement indéterminé

- **WHEN** l'environnement est absent, vide, UNSET ou inconnu
- **THEN** seule la liste du socle initial est vérifiée
