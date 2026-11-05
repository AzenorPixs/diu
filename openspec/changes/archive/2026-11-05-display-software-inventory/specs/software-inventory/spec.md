## Purpose
Présenter l’état configuré des logiciels et la disponibilité des moteurs.

## ADDED Requirements

### Requirement: Inventaire des logiciels
La commande `diu infos softwares` MUST afficher une colonne par moteur APT, GitHub et Flatpak, avec un titre vert gras si disponible et rouge gras sinon. Elle MUST afficher les logiciels disposant de variables déclarées, en vert pour la valeur 1, jaune pour 0, et indiquer une valeur inconnue sans afficher le nom des variables ni les secrets.

#### Scenario: États configurés
- **WHEN** les états de logiciels valent 1 et 0
- **THEN** leurs noms sont affichés dans les couleurs correspondantes sous leur moteur.

#### Scenario: État absent
- **WHEN** une variable est absente ou invalide
- **THEN** le logiciel est indiqué comme inconnu sans afficher la variable.

### Requirement: Routage partagé
`diu infos` et `diu softwares infos` MUST appeler le même affichage que `diu infos softwares`. Les aides MUST présenter les deux syntaxes. La détection MUST être locale et ne MUST NOT lancer d’installation ni d’accès réseau.

#### Scenario: Informations globales
- **WHEN** les informations globales sont demandées
- **THEN** la partie SOFTWARES utilise l’inventaire commun.
