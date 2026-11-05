## MODIFIED Requirements

### Requirement: Composition du parcours général
`diu system update` SHALL exécuter les phases APT, GitHub, Flatpak puis réseau en conservant leurs diagnostics et le résultat agrégé. Les échecs des phases SHALL NOT empêcher les phases ultérieures. Dans `diu update`, la phase système GitHub SHALL exécuter Codex CLI selon ses conditions habituelles sans report vers softwares.

#### Scenario: Ordre général
- **WHEN** `diu system update` est invoqué
- **THEN** les phases APT, GitHub, Flatpak et réseau sont exécutées dans cet ordre

#### Scenario: Échec d'une phase
- **WHEN** une phase échoue
- **THEN** les phases suivantes sont tentées et le résultat général est non nul

#### Scenario: Codex dans le parcours universel
- **WHEN** `diu update` est invoqué et que Codex CLI est admissible dans la phase GitHub système
- **THEN** cette phase exécute sa mise à jour une seule fois
