# Modifications de la spécification software-management

## ADDED Requirements

### Requirement: Moteur GitHub pour les logiciels

DIU SHALL accept `rid softwares install github <SOFTWARE>`,
`rid softwares remove github <SOFTWARE>`, `rid softwares update github
<SOFTWARE>` and `rid softwares update github`. The engine SHALL route only to
an explicitly registered software recipe and SHALL return a non-zero error for
an unknown software without executing a system command.

#### Scenario: Action GitHub déclarée

- **WHEN** an action targets a software with an explicit GitHub recipe
- **THEN** DIU calls the corresponding recipe action

#### Scenario: Action GitHub inconnue

- **WHEN** an action targets an undeclared software
- **THEN** DIU returns an error without executing an installation command

### Requirement: Opérations GitHub granulaires idempotentes

Each GitHub recipe SHALL provide installation, removal and update behavior as
applicable, SHALL be granular and idempotent, and SHALL set its global software
state variable to `1` after successful installation or to `0` after successful
removal. Installation of an installed software and removal of an absent
software SHALL not cause an unintended side effect.

#### Scenario: Installation répétée

- **WHEN** an already installed GitHub software is installed again
- **THEN** the recipe reports the existing state without reinstalling it

#### Scenario: Suppression répétée

- **WHEN** an absent GitHub software is removed
- **THEN** the recipe reports the absent state and returns success

### Requirement: Mise à jour depuis la dernière release GitHub

For an installed GitHub software, the update recipe SHALL obtain the latest
available GitHub release, compare it with the locally installed version, and
perform an update only when the remote release is newer. A targeted update
SHALL not install an absent software.

#### Scenario: Release plus récente

- **WHEN** the latest GitHub release is newer than the local version
- **THEN** DIU calls the software update recipe

#### Scenario: Logiciel déjà à jour

- **WHEN** the local version matches or is newer than the latest release
- **THEN** DIU reports that no update is available without reinstalling

### Requirement: Mise à jour globale des logiciels GitHub

`rid softwares update github`, `rid softwares update` and `rid update` SHALL
process only installed and recognized GitHub software recipes. They SHALL
continue independent recipes after an individual failure and SHALL return a
non-zero result when at least one recipe fails.

#### Scenario: Mise à jour globale

- **WHEN** the global GitHub update command is invoked
- **THEN** DIU updates each installed recognized GitHub software once

#### Scenario: Échec isolé

- **WHEN** one GitHub software update fails
- **THEN** DIU reports a global failure after processing the other recognized software
