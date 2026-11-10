# system-update-engines Specification

## Purpose
Définir les parcours de mise à jour système ciblés et leur composition générale.

## Requirements

### Requirement: Parcours système ciblés
Le DIU SHALL exposer `diu system engine apt update`, `diu system engine github update` et `diu system engine flatpak update` comme parcours ciblés indépendants. Ils SHALL assurer les mises à jour de versions de leurs logiciels installés sans modifier leur état désiré.

#### Scenario: Mise à jour APT ciblée
- **WHEN** `diu system engine apt update` est invoqué
- **THEN** le DIU exécute la phase Debian et son bilan APT, sans exécuter les phases GitHub, Flatpak ou réseau.

#### Scenario: Mise à jour GitHub ciblée
- **WHEN** `diu system engine github update` est invoqué
- **THEN** le DIU vérifie le moteur GitHub et met à jour Codex CLI si configuré, sans exécuter APT, Flatpak ou réseau.

#### Scenario: Mise à jour Flatpak ciblée
- **WHEN** `diu system engine flatpak update` est invoqué
- **THEN** le DIU vérifie le moteur Flatpak et Flathub et met à jour les applications système installées, sans exécuter les phases APT ou GitHub.

### Requirement: Composition du parcours général
`diu system engine update` SHALL exécuter les phases APT, GitHub et Flatpak dans cet ordre et agréger leurs erreurs. `diu system update` SHALL exécuter cette composition puis le réseau et agréger leurs erreurs. Les échecs SHALL NOT empêcher les phases ultérieures. Dans `diu update`, la phase système GitHub SHALL exécuter Codex CLI selon ses conditions habituelles sans report vers softwares.

#### Scenario: Ordre des moteurs
- **WHEN** `diu system engine update` est invoqué
- **THEN** les phases APT, GitHub et Flatpak sont exécutées dans cet ordre sans exécuter le réseau

#### Scenario: Ordre général
- **WHEN** `diu system update` est invoqué
- **THEN** les phases APT, GitHub, Flatpak et réseau sont exécutées dans cet ordre

#### Scenario: Échec d'une phase
- **WHEN** une phase échoue
- **THEN** les phases suivantes sont tentées et le résultat du parcours est non nul

#### Scenario: Codex dans le parcours universel
- **WHEN** `diu update` est invoqué et que Codex CLI est admissible dans la phase GitHub système
- **THEN** cette phase exécute sa mise à jour une seule fois

### Requirement: Suppression des anciennes syntaxes
Le DIU SHALL refuser `diu system apt update`, `diu system github update`, `diu system flatpak update`, `diu system update apt`, `diu system update apt debian`, `diu system update debian` et `diu system update flatpak` sans effectuer leur ancienne action.

#### Scenario: Ancienne syntaxe
- **WHEN** une ancienne syntaxe de mise à jour système supprimée est invoquée
- **THEN** elle retourne une erreur de syntaxe sans exécuter de mise à jour.
