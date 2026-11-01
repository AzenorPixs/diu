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

### Requirement: Sixième entrée FSTAB

Le DIU SHALL déclarer `SYSTEM_FSTAB_CONFIG6` dans
`modules/diu/variables/system/system_fstab_config6.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `NONE`. Quand `SYSTEM_FSTAB` vaut `1`, le
point d’entrée SHALL ajouter sa valeur à `/etc/fstab` après
`SYSTEM_FSTAB_CONFIG5`, sauf si elle vaut `NONE`.

#### Scenario: Initialisation et ajout de l’entrée

- **WHEN** `SYSTEM_FSTAB_CONFIG6` est absente
- **THEN** le DIU SHALL persister et exporter `SYSTEM_FSTAB_CONFIG6=NONE`
- **AND** quand `SYSTEM_FSTAB=1` et la valeur est différente de `NONE`, SHALL
  l’ajouter après la cinquième entrée dans `/etc/fstab`

#### Scenario: FSTAB désactivé ou entrée vide de configuration

- **WHEN** `SYSTEM_FSTAB` est absent ou vaut `0`, ou
  `SYSTEM_FSTAB_CONFIG6` vaut `NONE`
- **THEN** le bloc explicite SHALL ignorer la sixième entrée sans erreur de
  variable non définie

### Requirement: Migration de l’affectation historique FSTAB_CONFIG6

Avant de sourcer `/root/diu/variables.sh`, le nettoyage SHALL migrer une valeur
littérale simple de `FSTAB_CONFIG6` vers `SYSTEM_FSTAB_CONFIG6` si cette
dernière n’est pas déjà déclarée. Une valeur nécessitant une interprétation
shell SHALL bloquer le nettoyage sans mutation.

#### Scenario: Valeur historique simple

- **WHEN** `variables.sh` contient une affectation littérale simple de
  `FSTAB_CONFIG6`
- **THEN** le nettoyage SHALL persister sa valeur dans `system.env` si
  `SYSTEM_FSTAB_CONFIG6` n’y est pas déjà déclarée, puis supprimer l’ancienne
  affectation

#### Scenario: Nouvelle déclaration déjà présente

- **WHEN** `system.env` déclare déjà `SYSTEM_FSTAB_CONFIG6`
- **THEN** cette valeur SHALL prévaloir et l’affectation historique SHALL être
  supprimée sans transfert

#### Scenario: Valeur historique ambiguë

- **WHEN** l’affectation historique nécessite une interprétation shell
- **THEN** le nettoyage SHALL retourner un code non nul sans modifier les
  fichiers ni afficher leur contenu
