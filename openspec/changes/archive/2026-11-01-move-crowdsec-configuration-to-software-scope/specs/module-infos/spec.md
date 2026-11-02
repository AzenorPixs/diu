## ADDED Requirements

### Requirement: Informations des logiciels CrowdSec

`softwares_infos` SHALL afficher les interrupteurs CrowdSec du scope logiciels
et SHALL NOT afficher la clé API. `system_info_debian` SHALL NOT présenter le
dépôt CrowdSec comme une variable du scope system.

#### Scenario: Informations CrowdSec sans secret

- **WHEN** les informations logicielles sont demandées
- **THEN** les trois interrupteurs CrowdSec sont affichés sous le bloc
  `SOFTWARES`
- **AND** la clé API n'est pas affichée
