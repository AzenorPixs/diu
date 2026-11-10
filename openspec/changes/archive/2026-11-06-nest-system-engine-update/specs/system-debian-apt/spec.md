## MODIFIED Requirements

### Requirement: Mise à jour du sous-module APT
`diu system engine apt update` SHALL régénérer les dépôts Debian et tiers gérés, mettre à jour les index et exécuter une transaction dist-upgrade, le nettoyage et les prérequis, puis produire le bilan système et APT.

#### Scenario: Variables activées
- **WHEN** les variables contrib, non-free et backports valent `1`
- **THEN** les composants et suites correspondants sont présents.

#### Scenario: Variables désactivées
- **WHEN** une variable de dépôt vaut `0`
- **THEN** l'élément correspondant est absent de la configuration régénérée.

#### Scenario: Mise à jour officielle
- **WHEN** les dépôts officiels sont configurés
- **THEN** ils sont régénérés avant la transaction APT globale.

#### Scenario: Mise à jour APT globale
- **WHEN** `diu system engine apt update` est exécuté
- **THEN** les index sont actualisés et une transaction dist-upgrade est exécutée.

### Requirement: Isolation de Flatpak du sous-module APT
Le parcours APT SHALL NOT exécuter les contrôles ciblés du moteur Flatpak ni appeler `flatpak update`.

#### Scenario: Mise à jour APT
- **WHEN** `diu system engine apt update` est exécuté
- **THEN** aucun contrôle ciblé Flatpak ni `flatpak update` n'est exécuté.
