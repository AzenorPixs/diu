## MODIFIED Requirements

### Requirement: Commandes modulaires du moteur APT
DIU SHALL accepter `diu softwares install apt <SOFTWARE>`, `diu softwares remove apt <SOFTWARE>` et `diu softwares update apt <SOFTWARE>`. DIU SHALL refuser `diu softwares apt update` sans lancer de mise à jour APT.

#### Scenario: Commande granulaire
- **WHEN** l'utilisateur invoque `diu softwares install apt <SOFTWARE>`
- **THEN** DIU route l'action vers le moteur APT du module `softwares`

#### Scenario: Ancienne commande refusée
- **WHEN** l'utilisateur invoque `diu softwares apt update`
- **THEN** DIU retourne une erreur sans lancer de mise à jour APT

### Requirement: Mise à jour globale APT
`diu softwares update apt` SHALL mettre à jour tous les paquets installés avec APT avant les mises à jour sélectives applicables. `diu update` SHALL NOT appeler cette mise à jour via `softwares_update`.

#### Scenario: Mise à jour globale
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU met à jour les paquets installés avec APT une seule fois

#### Scenario: Mise à jour globale du DIU
- **WHEN** l'utilisateur invoque `diu update`
- **THEN** DIU n'appelle pas la mise à jour générale du module logiciels

### Requirement: Mise à jour globale APT du module softwares
`diu softwares update apt` SHALL exécuter la mise à jour APT globale, puis les mises à jour sélectives des logiciels APT reconnus et installés. La phase sélective SHALL toujours être exécutée après la phase APT. Les logiciels absents ou non déclarés SHALL être ignorés sans installation.

#### Scenario: Ordre des phases
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU exécute d'abord la mise à jour APT globale
- **AND** DIU exécute ensuite les mises à jour sélectives applicables

#### Scenario: Logiciel absent
- **WHEN** un logiciel reconnu n'est pas installé
- **THEN** DIU ne rejoue pas sa mise à jour sélective
- **AND** DIU ne l'installe pas
