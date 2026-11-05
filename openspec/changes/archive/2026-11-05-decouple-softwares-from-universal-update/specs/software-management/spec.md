## MODIFIED Requirements

### Requirement: Mise à jour globale APT
`diu softwares apt update` SHALL mettre à jour tous les paquets installés avec APT. Elle SHALL NOT rejouer les fonctions granulaires `install`, `remove` ou `update` propres aux logiciels. `diu update` SHALL NOT appeler cette commande via `softwares_update`.

#### Scenario: Mise à jour globale
- **WHEN** l'utilisateur invoque `diu softwares apt update`
- **THEN** DIU met à jour les paquets installés avec APT une seule fois

#### Scenario: Mise à jour globale du DIU
- **WHEN** l'utilisateur invoque `diu update`
- **THEN** DIU n'appelle pas la mise à jour générale du module logiciels

### Requirement: Mise à jour globale GitHub
`diu softwares update github` SHALL traiter Codex CLI uniquement lorsque sa variable d’état indique qu’il est installé. `diu softwares update` SHALL inclure cette opération une seule fois. `diu update` SHALL conserver la mise à jour de Codex CLI par la phase système lorsque applicable.

#### Scenario: Codex absent
- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** la mise à jour globale n'installe pas Codex CLI
