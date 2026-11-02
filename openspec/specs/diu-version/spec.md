# diu-version Specification

## Purpose
TBD - created by archiving change declare-diu-version-variable. Update Purpose after archive.

## Requirements

### Requirement: Version dynamique du paquet DIU

Le DIU SHALL déclarer `DIU_VERSION` dans
`modules/diu/variables/diu/diu_version.sh` avec `DYNAMIC`, `ENABLE` et scope
`diu`. `variable_generator()` SHALL lire la version installée du paquet DIU
avec `dpkg-query` et ne SHALL pas persister le résultat dans un fichier de
configuration.

#### Scenario: Version du paquet disponible

- **WHEN** `DIU_VERSION` n’est pas déjà définie et le paquet `diu` est installé
- **THEN** le générateur SHALL exporter exactement sa version Debian dans
  `DIU_VERSION`
- **AND** SHALL NOT écrire cette valeur dans `diu.env`

#### Scenario: Valeur déjà fournie

- **WHEN** `DIU_VERSION` est déjà définie
- **THEN** le module SHALL préserver et exporter cette valeur sans appeler le
  générateur

#### Scenario: Version indisponible

- **WHEN** `dpkg-query` est absent, échoue ou ne retourne aucune version
- **THEN** le module SHALL échouer avec un diagnostic stderr et un statut non
  nul
- **AND** SHALL retirer toute valeur `DIU_VERSION` partielle

### Requirement: Résumé de version DIU

Le résumé final de l’installation SHALL afficher `DIU_VERSION` à la place de
`VERSION_ALIAS`.

#### Scenario: Résumé final

- **WHEN** le point d’entrée atteint son résumé final
- **THEN** la version du paquet DIU installée est affichée depuis `DIU_VERSION`
