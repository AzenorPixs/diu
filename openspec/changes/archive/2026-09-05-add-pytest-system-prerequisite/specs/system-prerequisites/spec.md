## MODIFIED Requirements

### Requirement: Liste obligatoire

Le module `system` SHALL gérer les prérequis suivants :
`aptitude`, `apache2-utils`, `apt-transport-https`, `bash-completion`,
`bind9-dnsutils`, `ca-certificates`, `curl`, `dirmngr`, `ethtool`, `extrepo`,
`git`, `gnupg`, `gpg`, `inetutils-telnet`, `iptables`, `jq`, `lshw`,
`lsb-release`, `man-db`, `manpages-fr`, `net-tools`, `netcat-traditional`,
`nicstat`, `openssl`, `pciutils`, `pytest`, `ripgrep`, `shellcheck`, `sudo`,
`tcpdump`, `traceroute`, `tree`, `util-linux`, `wget`.

#### Scenario: Liste des prérequis

- **WHEN** la fonction d'installation des prérequis est appelée
- **THEN** elle utilise exactement la liste obligatoire définie ci-dessus

#### Scenario: pytest requis

- **WHEN** `pytest` n'est pas installé
- **THEN** la fonction d'installation l'annonce et l'installe
