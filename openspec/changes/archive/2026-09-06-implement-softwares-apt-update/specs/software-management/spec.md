## ADDED Requirements

### Requirement: Mise à jour globale APT du module softwares

`rid softwares update apt` SHALL exécuter `rid softwares apt update`, puis
réexécuter les mises à jour sélectives des logiciels APT reconnus et installés.
La phase sélective SHALL toujours être exécutée après la phase APT. Les
logiciels absents ou non déclarés SHALL être ignorés sans installation.

#### Scenario: Ordre des phases

- **WHEN** l'utilisateur invoque `rid softwares update apt`
- **THEN** DIU exécute d'abord la mise à jour APT globale
- **AND** DIU exécute ensuite les mises à jour sélectives applicables

#### Scenario: Logiciel absent

- **WHEN** un logiciel reconnu n'est pas installé
- **THEN** DIU ne rejoue pas sa mise à jour sélective
- **AND** DIU ne l'installe pas

### Requirement: Intégration aux mises à jour globales

`rid softwares update` SHALL appeler la même séquence que `rid softwares update
apt`. `rid update` SHALL inclure cette séquence une seule fois pour le module
`softwares`.

#### Scenario: Mise à jour du module softwares

- **WHEN** l'utilisateur invoque `rid softwares update`
- **THEN** DIU exécute la mise à jour APT puis les mises à jour sélectives

#### Scenario: Mise à jour de tous les modules

- **WHEN** l'utilisateur invoque `rid update`
- **THEN** DIU exécute la séquence `softwares` après la phase APT
- **AND** aucune mise à jour sélective n'est rejouée une seconde fois
