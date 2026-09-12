## ADDED Requirements

### Requirement: Isolation de Flatpak des mises à jour globales

Les mises à jour globales du module system SHALL ne pas appliquer
`SYSTEM_FLATPAK` et SHALL ne jamais appeler `flatpak update`. Seule la commande
explicite `rid system update flatpak` SHALL pouvoir mettre à jour le paquet
Debian `flatpak`.

#### Scenario: Mise à jour globale

- **WHEN** `rid system update` ou `rid update` est exécuté
- **THEN** aucune mise à jour ciblée de Flatpak n'est invoquée
- **AND** `flatpak update` n'est pas exécuté
