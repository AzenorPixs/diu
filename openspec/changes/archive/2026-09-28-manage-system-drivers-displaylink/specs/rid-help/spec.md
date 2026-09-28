## ADDED Requirements

### Requirement: Aide des pilotes DisplayLink
L'aide SHALL exposer les commandes rid system drivers install displaylink et rid system drivers remove displaylink, à la racine, au niveau system, drivers, install/remove et displaylink, sans charger la configuration ni agir sur le système.

#### Scenario: Aide pilote
- **WHEN** help suit un préfixe valide des commandes DisplayLink
- **THEN** les commandes correspondantes sont affichées sans effet de bord
