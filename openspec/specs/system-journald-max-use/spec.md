# system-journald-max-use Specification

## Purpose

Déclarer la limite de taille appliquée aux journaux systemd persistants et
volatils.

## Requirements

### Requirement: Déclaration statique de SYSTEM_JOURNALD_MAX_USE

Le DIU SHALL déclarer `SYSTEM_JOURNALD_MAX_USE` dans
`modules/diu/variables/system/system_journald_max_use.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `500M`. Les valeurs SHALL être un entier
suivi facultativement d’une unité journald parmi `K`, `M`, `G`, `T`, `P` ou
`E`.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_JOURNALD_MAX_USE` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SYSTEM_JOURNALD_MAX_USE=500M` dans `/root/diu/config/system.env`
- **AND** SHALL exporter la valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SYSTEM_JOURNALD_MAX_USE` contient une valeur conforme au format
  documenté
- **THEN** le DIU SHALL la conserver et l’exporter sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SYSTEM_JOURNALD_MAX_USE` ne respecte pas le format documenté
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs journald renommés

Les affectations `SystemMaxUse` et `RuntimeMaxUse` du point d’entrée SHALL
utiliser `SYSTEM_JOURNALD_MAX_USE` à la place de `JOURNALD_MAX_USE`.

#### Scenario: Configuration des deux limites

- **WHEN** le DIU configure journald
- **THEN** `SystemMaxUse` et `RuntimeMaxUse` reçoivent la valeur
  `SYSTEM_JOURNALD_MAX_USE`
