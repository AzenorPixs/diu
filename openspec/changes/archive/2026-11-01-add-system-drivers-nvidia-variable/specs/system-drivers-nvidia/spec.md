# system-drivers-nvidia Specification

## Purpose
Déclarer le réglage système qui contrôle les traitements NVIDIA existants du
point d’entrée DIU.

## ADDED Requirements

### Requirement: Déclaration statique du drapeau NVIDIA

Le DIU SHALL déclarer `SYSTEM_DRIVERS_NVIDIA` dans
`modules/diu/variables/system/system_drivers_nvidia.sh` avec `config=STATIC`,
`state=ENABLE`, `scope=system` et `default_value=0`. Le chargeur existant
SHALL découvrir cette déclaration sans modification.

#### Scenario: Initialisation par défaut

- **WHEN** `SYSTEM_DRIVERS_NVIDIA` n’est pas déjà définie au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_DRIVERS_NVIDIA=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_DRIVERS_NVIDIA=0` dans le processus courant

#### Scenario: Valeur existante

- **WHEN** `SYSTEM_DRIVERS_NVIDIA` est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL conserver et exporter sa valeur sans réécrire sa
  déclaration persistante

### Requirement: Consommation du drapeau système NVIDIA

Les consommateurs existants SHALL utiliser `SYSTEM_DRIVERS_NVIDIA` à la place
du drapeau historique `DRIVERS_NVIDIA`. Une valeur `1` SHALL conserver les
traitements existants ; une valeur absente ou `0` SHALL les ignorer sans
erreur de variable non définie.

#### Scenario: Traitements NVIDIA activés

- **WHEN** `SYSTEM_DRIVERS_NVIDIA` vaut `1`
- **THEN** les consommateurs SHALL conserver les branches existantes pour
  l’installation, les modules noyau, les répertoires de journaux et le runtime
  Docker NVIDIA

#### Scenario: Traitements NVIDIA désactivés ou absents

- **WHEN** `SYSTEM_DRIVERS_NVIDIA` est absente ou vaut `0`
- **THEN** ces branches SHALL être ignorées sans erreur de variable non définie
