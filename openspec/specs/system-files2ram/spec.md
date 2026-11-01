# system-files2ram Specification

## Purpose
Déclarer le contrôle système de la configuration FILES2RAM existante.

## Requirements

### Requirement: Déclaration statique de SYSTEM_FILES2RAM

Le DIU SHALL déclarer `SYSTEM_FILES2RAM` dans
`modules/diu/variables/system/system_files2ram.sh` avec `STATIC`, `ENABLE`,
scope `system` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Valeur par défaut

- **WHEN** `SYSTEM_FILES2RAM` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_FILES2RAM=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_FILES2RAM=0` dans le processus courant

#### Scenario: Valeur déjà configurée

- **WHEN** `SYSTEM_FILES2RAM` est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL la conserver et l’exporter sans réécriture

### Requirement: Consommateur FILES2RAM renommé

Le consommateur du point d’entrée SHALL utiliser `SYSTEM_FILES2RAM` à la place
de `FILES2RAM`. Une valeur absente ou `0` SHALL ignorer le bloc FILES2RAM sans
erreur de variable non définie. Une valeur `1` SHALL conserver les traitements
existants.

#### Scenario: FILES2RAM activé

- **WHEN** `SYSTEM_FILES2RAM` vaut `1`
- **THEN** le DIU SHALL conserver la configuration tmpfiles et FSTAB
  existante, y compris ses conditions de suppression initiale des journaux

#### Scenario: FILES2RAM désactivé ou absent

- **WHEN** `SYSTEM_FILES2RAM` est absente ou vaut `0`
- **THEN** le DIU SHALL ignorer ce bloc sans erreur de variable non définie
