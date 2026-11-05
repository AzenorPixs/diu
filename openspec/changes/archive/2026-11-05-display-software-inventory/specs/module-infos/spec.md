## MODIFIED Requirements

### Requirement: Informations des logiciels CrowdSec

`softwares_infos` SHALL afficher les noms des logiciels CrowdSec et leur état sous le titre `SOFTWARES`. Elle SHALL NOT afficher les noms de variables ou la clé API CrowdSec.

#### Scenario: Informations CrowdSec sans secret

- **WHEN** les informations logicielles sont demandées
- **THEN** les logiciels CrowdSec et leur état sont affichés
- **AND** la clé API et les noms des variables ne sont pas affichés
