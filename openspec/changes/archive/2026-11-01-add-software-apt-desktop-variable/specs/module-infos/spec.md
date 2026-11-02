## MODIFIED Requirements

### Requirement: Informations des logiciels CrowdSec

`softwares_infos` SHALL afficher `SOFTWARES_APT_DESKTOP` et les trois
interrupteurs CrowdSec sous le titre `SOFTWARES`. Elle SHALL NOT afficher la
clé API CrowdSec.

#### Scenario: Informations CrowdSec sans secret

- **WHEN** les informations logicielles sont demandées
- **THEN** les réglages logiciels de bureau et CrowdSec sont affichés
- **AND** la clé API n'est pas affichée
