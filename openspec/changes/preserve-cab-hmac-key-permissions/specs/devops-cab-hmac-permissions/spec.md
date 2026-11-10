## ADDED Requirements

### Requirement: Droits ciblés de la clé HMAC CAB
Lors de la normalisation récursive du compte DevOps, DIU SHALL appliquer par une opération ciblée 0770 aux fichiers réguliers `*.hmac.key` du répertoire `.opencode/state/cgpt-approval-bridge` du compte. Les autres fichiers SHALL suivre leurs propres règles de normalisation ; les liens symboliques SHALL NOT être suivis par cette opération.

#### Scenario: Clé CAB et fichier voisin
- **WHEN** une clé HMAC CAB et un fichier ordinaire sont normalisés
- **THEN** la clé est en 0770 et le fichier ordinaire conserve la règle habituelle 0770

#### Scenario: Lien symbolique
- **WHEN** un lien symbolique porte un nom de clé HMAC dans ce répertoire
- **THEN** la normalisation ciblée ne modifie pas la cible du lien

### Requirement: Droits ordinaires DevOps
DIU SHALL normaliser les répertoires du compte DevOps en 2770 et ses fichiers ordinaires en 0770, sans modifier les règles spécifiques des fichiers sensibles.

#### Scenario: Répertoire et fichier ordinaires
- **WHEN** la normalisation du compte DevOps est exécutée
- **THEN** les répertoires ordinaires utilisent 2770 et les fichiers ordinaires 0770
