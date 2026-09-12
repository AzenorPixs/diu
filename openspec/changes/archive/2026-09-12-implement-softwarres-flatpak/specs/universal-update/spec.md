## MODIFIED Requirements

### Requirement: Participation des moteurs logiciels

La mise à jour universelle SHALL inclure la portée de `rid update deb`, celle
de `rid update apt` lorsqu'elle est disponible, et la mise à jour globale des
applications Flatpak lorsque le moteur Flatpak est disponible. Une mise à jour
avec moteur explicite SHALL rester limitée à ce moteur.

#### Scenario: Moteurs disponibles

- **WHEN** les moteurs `deb`, `apt` et `flatpak` sont disponibles et `rid update` est invoqué
- **THEN** les logiciels installés relevant de chacun de ces moteurs sont traités

#### Scenario: Mise à jour limitée à deb

- **WHEN** `rid update deb` est invoqué
- **THEN** DIU ne déclenche ni le moteur `apt`, ni le moteur `flatpak`, ni les mises à jour des autres modules

#### Scenario: Moteur Flatpak indisponible

- **WHEN** le moteur Flatpak n'est pas chargé lors d'une mise à jour universelle
- **THEN** DIU le signale comme non chargé sans exécuter de commande Flatpak
