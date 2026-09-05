# Delta for system-debian-apt

## MODIFIED Requirements

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
