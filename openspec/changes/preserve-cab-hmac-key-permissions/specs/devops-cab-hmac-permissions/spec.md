## ADDED Requirements

### Requirement: Droits ciblés de la clé HMAC CAB
Lors de la normalisation récursive du compte DevOps, DIU SHALL appliquer 0770 aux seuls fichiers réguliers `*.hmac.key` du répertoire `.opencode/state/cgpt-approval-bridge` du compte. Les autres fichiers SHALL conserver leurs règles de normalisation ; les liens symboliques SHALL NOT être suivis par cette opération.

#### Scenario: Clé CAB et fichier voisin
- **WHEN** une clé HMAC CAB et un fichier ordinaire sont normalisés
- **THEN** la clé est en 0770 et le fichier ordinaire conserve la règle habituelle 0775

#### Scenario: Lien symbolique
- **WHEN** un lien symbolique porte un nom de clé HMAC dans ce répertoire
- **THEN** la normalisation ciblée ne modifie pas la cible du lien
