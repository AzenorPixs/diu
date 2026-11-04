## MODIFIED Requirements

### Requirement: Informations des logiciels CrowdSec

`softwares_infos` SHALL afficher les trois interrupteurs CrowdSec sous le titre
`SOFTWARES`. Elle SHALL NOT afficher la clé API CrowdSec.

#### Scenario: Informations CrowdSec sans secret

- **WHEN** les informations logicielles sont demandées
- **THEN** les réglages logiciels CrowdSec sont affichés
- **AND** la clé API n'est pas affichée

## ADDED Requirements

### Requirement: Informations du contrôle de bureau

`desktop_infos` SHALL afficher `DESKTOP` sous le titre `DESKTOP`.

#### Scenario: État du profil de bureau

- **WHEN** les informations du module desktop sont demandées
- **THEN** la valeur configurée de `DESKTOP` est affichée
- **AND** une variable absente est affichée comme `UNSET`
