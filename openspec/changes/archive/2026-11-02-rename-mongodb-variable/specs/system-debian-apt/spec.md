## ADDED Requirements

### Requirement: Repli du dépôt MongoDB depuis le réglage logiciel

`SYSTEM_APT_MONGODB` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source MongoDB n’est détectée et si `SYSTEM_APT_MONGODB` n’est pas
déjà configurée, sa valeur initiale SHALL être déterminée par
`SOFTWARES_APT_MONGODB` et `MONGODB_VERSION`. Lorsque le logiciel est actif, la
version déclarée SHALL sélectionner la branche du dépôt comme auparavant.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source MongoDB APT n’est détectée
- **AND** `SOFTWARES_APT_MONGODB` vaut `1`
- **AND** `MONGODB_VERSION` contient une version prise en charge
- **THEN** le DIU SHALL persister la branche correspondante dans
  `SYSTEM_APT_MONGODB`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_MONGODB` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur les réglages logiciels
