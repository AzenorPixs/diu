# SW12 — Gestion des applications Flatpak

## Why

Le moteur Flatpak du module `system` prépare uniquement le client et Flathub ;
DIU ne peut pas encore gérer le cycle de vie des applications Flatpak. Cette
évolution complète la gestion des logiciels sans mélanger le paquet Debian du
moteur avec les applications qu'il installe.

## What Changes

- Ajoute le moteur `flatpak` au module `softwares` pour installer et retirer
  des applications Flatpak par leur identifiant.
- Ajoute `rid softwares flatpak update` pour mettre à jour les applications
  Flatpak installées.
- Intègre cette mise à jour, une seule fois, à `rid softwares update` et à
  `rid update`.
- Ajoute le routage sûr, les diagnostics et l'aide contextuelle associés.

## Capabilities

### New Capabilities

- `software-flatpak`: Gérer les applications Flatpak par le module `softwares`
  sans administrer le moteur système Flatpak.

### Modified Capabilities

- `universal-update`: Inclure le participant Flatpak à la mise à jour globale
  sans doublon et sans modifier la portée des autres participants.

## Impact

Le changement ajoute un module Bash Flatpak, adapte le routage logiciels,
l'orchestrateur de mise à jour, l'aide et les tests Python isolés. Il n'ajoute
aucune dépendance : le client Flatpak et Flathub doivent être préparés par le
module `system` avant toute gestion d'application.
