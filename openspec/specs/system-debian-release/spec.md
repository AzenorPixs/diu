# system-debian-release Specification

## Purpose

Exposer le nom de code de la distribution courante dans SYSTEM_DEBIAN_RELEASE.

## Requirements

### Requirement: Déclaration système dynamique

Le DIU SHALL déclarer SYSTEM_DEBIAN_RELEASE dans
`modules/diu/variables/system/system_debian_release.sh`, avec config DYNAMIC,
state ENABLE et scope system. Le fichier SHALL définir variable_generator et
être découvert par config_generator sans modification de celui-ci.

#### Scenario: Initialisation

- **WHEN** la déclaration est chargée et la variable est absente
- **THEN** sa valeur est générée et exportée sans écriture persistante

#### Scenario: Valeur déjà définie

- **WHEN** SYSTEM_DEBIAN_RELEASE est déjà définie, même vide
- **THEN** sa valeur est conservée sans nouvelle génération

### Requirement: Nom de code de la distribution courante

Le générateur SHALL lire VERSION_CODENAME depuis /etc/os-release et produire
le nom de code en minuscules, par exemple trixie, bookworm ou bullseye.
Il SHALL isoler la lecture pour ne pas modifier les autres variables du DIU.

#### Scenario: Releases et casse

- **WHEN** VERSION_CODENAME vaut trixie, Bookworm ou BULLSEYE
- **THEN** le générateur produit respectivement trixie, bookworm ou bullseye

#### Scenario: Détection impossible

- **WHEN** le fichier est absent ou illisible, son chargement échoue, ou le nom
  de code est vide ou invalide (autre que lettres ASCII, chiffres, points,
  tirets et underscores, avec une lettre initiale)
- **THEN** un diagnostic est produit sur stderr et le chargement échoue
- **AND** SYSTEM_DEBIAN_RELEASE reste absente et aucune configuration n'est écrite
