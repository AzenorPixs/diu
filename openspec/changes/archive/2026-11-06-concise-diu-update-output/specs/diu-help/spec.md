## ADDED Requirements

### Requirement: Découverte des aides réseau

L'aide système SHALL distinguer l'affichage de `/etc/hosts` de la gestion du JSON et indiquer les aides contextuelles réseau disponibles.

#### Scenario: Aide système
- **WHEN** l'aide de `system` est demandée
- **THEN** elle indique que `system network hosts` affiche `/etc/hosts` et montre comment consulter les aides réseau et hosts

#### Scenario: Aide réseau
- **WHEN** l'aide de `system network` est demandée
- **THEN** elle présente les sous-commandes hosts et indique comment consulter leur aide
