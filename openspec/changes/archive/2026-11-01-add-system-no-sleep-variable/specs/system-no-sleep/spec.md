## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_NO_SLEEP

Le DIU SHALL déclarer `SYSTEM_NO_SLEEP` dans
`modules/diu/variables/system/system_no_sleep.sh` avec `STATIC`, `ENABLE`,
scope `system` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_NO_SLEEP` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_NO_SLEEP=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_NO_SLEEP=0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SYSTEM_NO_SLEEP` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SYSTEM_NO_SLEEP` est définie à une valeur autre que `0` ou `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur de veille renommé

Le consommateur de veille du point d’entrée SHALL utiliser `SYSTEM_NO_SLEEP` à
la place de `NO_SLEEP`. Une valeur absente ou `0` SHALL ignorer le bloc sans
erreur de variable non définie. Une valeur `1` SHALL conserver le traitement
systemd existant.

#### Scenario: Veille désactivée

- **WHEN** `SYSTEM_NO_SLEEP` vaut `1`
- **THEN** le DIU SHALL créer `/etc/systemd/sleep.conf.d/nosleep.conf` avec les
  paramètres existants qui interdisent suspend, hibernation et modes combinés

#### Scenario: Veille autorisée ou valeur absente

- **WHEN** `SYSTEM_NO_SLEEP` est absente ou vaut `0`
- **THEN** le bloc SHALL être ignoré sans erreur de variable non définie
- **AND** un éventuel `nosleep.conf` existant SHALL rester intact
