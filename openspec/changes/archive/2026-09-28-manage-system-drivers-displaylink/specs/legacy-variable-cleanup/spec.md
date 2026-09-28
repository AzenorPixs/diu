## MODIFIED Requirements

### Requirement: Consommateurs migrés

Les consommateurs du projet SHALL utiliser SYSTEM_DEBIAN_RELEASE à la place de DEBIAN_RELEASE et SYSTEM_DEBIAN_ENVIRONNEMENT à la place de DEBIAN_TYPE et SYSTEM_DRIVERS_DISPLAY_LINK à la place de DISPLAY_LINK. Les mentions de l’ancien nom SHALL être limitées à la migration, sa documentation et ses tests. La valeur historique SHALL ne pas être transférée vers la nouvelle variable.

#### Scenario: Sélection de distribution

- **WHEN** une opération choisit un comportement selon la distribution Debian
- **THEN** elle utilise SYSTEM_DEBIAN_RELEASE selon la déclaration dynamique existante

#### Scenario: Sélection de l’environnement

- **WHEN** une opération choisit un comportement selon le type d’environnement
- **THEN** elle utilise SYSTEM_DEBIAN_ENVIRONNEMENT selon sa déclaration dynamique
- **AND** les branches existantes LXC, PHYSICAL, PROXMOX et VM sont conservées

#### Scenario: Préférence DisplayLink migrée
- **WHEN** une commande explicite DisplayLink valide son installation ou sa suppression
- **THEN** elle met à jour SYSTEM_DRIVERS_DISPLAY_LINK sans transférer la valeur historique
- **AND** le parcours historique ne consomme plus cette préférence pour installer automatiquement le pilote
