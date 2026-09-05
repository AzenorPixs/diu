# Delta for system-debian-apt

## MODIFIED Requirements

### Requirement: Contextes system

Le contexte `diu system update apt` SHALL régénérer la configuration des
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

#### Scenario: Module system

- **WHEN** `diu system update` est exécuté
- **THEN** il délègue à `diu system update apt`

#### Scenario: Mise à jour DIU

- **WHEN** `diu update` est exécuté
- **THEN** sa partie APT réutilise le contexte APT global avant la mise à jour
  de DIU
