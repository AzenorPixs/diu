# system-fstab Specification

## Purpose
Déclarer le contrôle du bloc FSTAB et les cinq lignes de montage qu’il peut
écrire.

## Requirements

### Requirement: Déclarations statiques système FSTAB

Le DIU SHALL déclarer `SYSTEM_FSTAB` avec `STATIC`, `ENABLE`, scope `system`,
défaut `0`, et `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5` avec les mêmes
attributs et défaut `NONE`, dans un fichier unitaire par variable sous
`modules/diu/variables/system/`.

#### Scenario: Initialisation des valeurs absentes

- **WHEN** une des six variables est absente au chargement
- **THEN** le DIU SHALL persister sa valeur par défaut dans
  `/root/diu/config/system.env`
- **AND** SHALL l’exporter dans le processus courant

#### Scenario: Valeur préconfigurée

- **WHEN** une de ces variables est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL préserver et exporter sa valeur sans réécrire sa
  déclaration persistante

### Requirement: Consommateurs renommés

Le bloc explicite FSTAB SHALL utiliser `SYSTEM_FSTAB` à la place de `FSTAB`.
Le bloc SHALL utiliser `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5` à la
place des anciens noms. Un drapeau absent SHALL équivaloir à `0`; une entrée
absente SHALL équivaloir à `NONE`.

#### Scenario: Configuration FSTAB activée

- **WHEN** `SYSTEM_FSTAB` vaut `1`
- **THEN** le DIU SHALL préserver les écritures existantes des cinq entrées
  dans `/etc/fstab`

#### Scenario: Configuration FSTAB désactivée ou absente

- **WHEN** `SYSTEM_FSTAB` est absente ou vaut `0`
- **THEN** le bloc explicite SHALL être ignoré sans erreur de variable
  non définie

#### Scenario: Traitement FILES2RAM

- **WHEN** le bloc FILES2RAM consulte une entrée FSTAB
- **THEN** il SHALL utiliser le nom `SYSTEM_FSTAB_CONFIG1` et préserver le
  comportement du sentinel `NONE`
