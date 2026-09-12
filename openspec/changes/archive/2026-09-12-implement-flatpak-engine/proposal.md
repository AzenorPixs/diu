## Why

Flatpak est encore partiellement géré par le script monolithique : son
installation et sa mise à jour ne sont ni configurables ni compatibles avec la
responsabilité du module `system`. Le DIU doit pouvoir converger explicitement
vers l'état voulu sans installer ou mettre à jour des applications Flatpak.

## What Changes

- Ajoute la variable persistante `SYSTEM_FLATPAK` et sa détection initiale du
  paquet Debian `flatpak`.
- Ajoute le moteur Flatpak idempotent du module `system`, limité au paquet
  Debian et au remote Flathub.
- Ajoute les commandes `rid system install|remove|update flatpak` et leur aide.
- Retire du monolithe la mise à jour globale `flatpak update` et sa gestion
  d'installation conflictuelle.

## Capabilities

### New Capabilities

- `system-flatpak`: Gérer l'état du moteur Flatpak et ses commandes ciblées.

### Modified Capabilities

- `system-debian-apt`: Exclure Flatpak des mises à jour APT globales du module
  `system`.

## Impact

Le changement concerne `modules/diu/variables/system/`,
`modules/system/apt.sh`, l'aide et les traitements historiques de
`root-install-debian.sh`, ainsi que des tests Python isolés. Il n'ajoute aucune
dépendance : `flatpak` reste un paquet Debian installé uniquement à la demande
de l'état ou de la commande explicite.
