## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.6` et l'ordre des rubriques du scénario « Rubriques documentaires conservées ». Pour template, le titre SHALL être `DEVOPS.md — Template`. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document, avec Chromium puis Firefox.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.6 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, `Docker, pour tests nécessitant des droits root`, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire

## ADDED Requirements

### Requirement: Références Docker des tests nécessitant des droits root

La rubrique Docker SHALL porter le titre exact
`Docker, pour tests nécessitant des droits root`. Elle SHALL contenir quatre
puces, dans cet ordre : version détectée ou diagnostic existant, chemin du
binaire ou diagnostic existant, `/var/run/docker.sock`, `debian:stable-slim`.
Les deux dernières puces SHALL rester des références documentaires fixes.
Les autres rubriques et sondes SHALL être conservées.

#### Scenario: Docker disponible

- **WHEN** la version et le binaire Docker sont détectés
- **THEN** la rubrique porte le titre exact et les quatre puces dans l'ordre prévu
- **AND THEN** les deux références apparaissent chacune une seule fois

#### Scenario: Docker indisponible

- **WHEN** le binaire Docker est absent ou sa sonde échoue
- **THEN** les diagnostics existants sont conservés dans les premières puces
- **AND THEN** le socket et l'image restent indiqués sans nouvelle sonde ou action Docker

#### Scenario: Portée documentaire des références

- **WHEN** les références Docker sont ajoutées au document
- **THEN** le générateur ne sonde pas le socket, ne télécharge ni ne lance l'image et ne modifie aucune permission
- **AND THEN** leur présence ne constitue pas une preuve de disponibilité ou de fonctionnement
