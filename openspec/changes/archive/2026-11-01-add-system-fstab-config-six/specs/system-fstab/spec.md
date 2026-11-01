## ADDED Requirements

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
