## ADDED Requirements

### Requirement: Aide des mises à jour des moteurs système
Les aides système et engine SHALL présenter les commandes de mise à jour groupée et ciblées sous `diu system engine`, sans présenter les anciennes syntaxes ciblées.

#### Scenario: Aide de la hiérarchie engine
- **WHEN** l'aide de `diu system` ou `diu system engine` est demandée
- **THEN** elle présente `diu system engine update` et les trois commandes ciblées APT, GitHub et Flatpak.

#### Scenario: Aide ciblée
- **WHEN** l'aide de `diu system engine apt update`, `github update` ou `flatpak update` est demandée
- **THEN** elle présente la commande ciblée correspondante.
