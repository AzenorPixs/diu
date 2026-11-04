# Delta for software-management

## ADDED Requirements

### Requirement: Mise à jour globale des paquets Debian

Le moteur `deb` SHALL collecter les paquets installés dont une version
officielle est disponible, puis SHALL exécuter leur mise à jour dans une seule
transaction APT. Il SHALL ne pas afficher de ligne individuelle pour les
paquets déjà à jour ou non applicables.

#### Scenario: Plusieurs paquets Debian

- **WHEN** plusieurs paquets installés disposent d'une mise à jour officielle
- **THEN** une seule transaction APT est exécutée avec toutes les cibles

#### Scenario: Paquets sans action

- **WHEN** un paquet est déjà à jour ou sans candidat Debian officiel
- **THEN** il est ignoré sans message individuel et sans installation
  supplémentaire
