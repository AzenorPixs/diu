## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_GRUB_CONFIG

Le DIU SHALL déclarer `SYSTEM_GRUB_CONFIG` dans
`modules/diu/variables/system/system_grub_config.sh` avec `STATIC`, `ENABLE`,
scope `system` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_GRUB_CONFIG` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_GRUB_CONFIG=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_GRUB_CONFIG=0` dans le processus courant

#### Scenario: Valeur préconfigurée

- **WHEN** `SYSTEM_GRUB_CONFIG` est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL la conserver et l’exporter sans réécriture

### Requirement: Consommateur GRUB renommé

Le consommateur GRUB du point d’entrée SHALL utiliser `SYSTEM_GRUB_CONFIG` à
la place de `GRUB_CONFIG`. Une valeur absente ou `0` SHALL ignorer le bloc
GRUB sans erreur de variable non définie. Une valeur `1` SHALL conserver les
traitements GRUB existants.

#### Scenario: Configuration GRUB activée

- **WHEN** `SYSTEM_GRUB_CONFIG` vaut `1`
- **THEN** le DIU SHALL conserver l’exécution existante de la configuration
  GRUB et de `update-grub`

#### Scenario: Configuration GRUB désactivée ou absente

- **WHEN** `SYSTEM_GRUB_CONFIG` est absente ou vaut `0`
- **THEN** le bloc GRUB SHALL être ignoré sans erreur de variable non définie
