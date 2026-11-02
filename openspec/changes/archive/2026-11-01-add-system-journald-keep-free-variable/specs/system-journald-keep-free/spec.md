## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_JOURNALD_KEEP_FREE

Le DIU SHALL déclarer `SYSTEM_JOURNALD_KEEP_FREE` dans
`modules/diu/variables/system/system_journald_keep_free.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `1G`. Les valeurs SHALL être un entier
suivi facultativement d’une unité journald parmi `K`, `M`, `G`, `T`, `P` ou
`E`.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_JOURNALD_KEEP_FREE` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SYSTEM_JOURNALD_KEEP_FREE=1G` dans `/root/diu/config/system.env`
- **AND** SHALL exporter la valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SYSTEM_JOURNALD_KEEP_FREE` contient une valeur conforme au format
  documenté
- **THEN** le DIU SHALL la conserver et l’exporter sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SYSTEM_JOURNALD_KEEP_FREE` ne respecte pas le format documenté
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs journald renommés

Les affectations `SystemKeepFree` et `RuntimeKeepFree` du point d’entrée SHALL
utiliser `SYSTEM_JOURNALD_KEEP_FREE` à la place de `JOURNALD_KEEP_FREE`.

#### Scenario: Configuration des deux réserves

- **WHEN** le DIU configure journald
- **THEN** `SystemKeepFree` et `RuntimeKeepFree` reçoivent la valeur
  `SYSTEM_JOURNALD_KEEP_FREE`
