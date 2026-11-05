## MODIFIED Requirements

### Requirement: Isolation de Flatpak du sous-module APT

Le sous-module APT de `system` SHALL ne pas appliquer `SYSTEM_FLATPAK_ENGINE` et
SHALL ne jamais appeler `flatpak update`. Seule la commande explicite
`diu system update flatpak` SHALL pouvoir mettre à jour le paquet Debian
`flatpak`.

#### Scenario: Mise à jour APT

- **WHEN** `diu system update apt` est exécuté
- **THEN** aucune mise à jour ciblée de Flatpak n'est invoquée
- **AND** `flatpak update` n'est pas exécuté

