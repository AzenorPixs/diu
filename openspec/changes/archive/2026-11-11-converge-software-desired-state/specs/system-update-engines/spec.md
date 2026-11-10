# Spec Delta

## MODIFIED Requirements

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
