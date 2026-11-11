## Purpose

Détecter les sources APT réellement déclarées et initialiser une seule fois les variables de dépôts et composants sans écraser la configuration existante.

## ADDED Requirements
### Requirement: Détection des déclarations actives
DIU SHALL détecter les dépôts depuis les entrées actives de sources.list, des fichiers .list et des strophes deb822 .sources. Il SHALL ignorer commentaires, sauvegardes et strophes Enabled: no. Une erreur de lecture SHALL être signalée sans initialiser une absence supposée.
#### Scenario: Source désactivée
- **WHEN** un dépôt apparaît uniquement dans une source commentée ou désactivée
- **THEN** sa détection retourne zéro
#### Scenario: Source active
- **WHEN** le dépôt est déclaré dans une entrée active valide
- **THEN** sa variable booléenne absente est initialisée à un
### Requirement: Initialisation unique des dépôts
Toutes les variables de dépôts SHALL utiliser la détection réelle uniquement lorsqu’elles sont absentes. Les valeurs configurées valides SHALL être préservées. Les branches versionnées MongoDB et Wazuh SHALL rester représentées par leurs sélecteurs existants. Le souhait logiciel seul SHALL NOT activer un dépôt à l’initialisation.
#### Scenario: Valeur explicite désactivée
- **WHEN** une variable persistée vaut zéro et que la source est présente
- **THEN** l’initialisation conserve zéro
### Requirement: Composants non-free indépendants
SYSTEM_APT_DEBIAN_NONFRFEE SHALL piloter uniquement non-free et SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE SHALL piloter uniquement non-free-firmware. À leur première initialisation, une variable absente SHALL valoir un si son composant est déclaré dans une source Debian active, zéro sinon. SYSTEM SHALL permettre leur activation et désactivation séparées, ainsi que contrib, sans modifier les autres composants.
#### Scenario: Firmware seul
- **WHEN** seul non-free-firmware est déclaré et que les variables sont absentes
- **THEN** firmware vaut un et non-free vaut zéro

#### Scenario: Composant firmware séparé sur Bullseye
- **WHEN** l’activation SYSTEM de non-free-firmware séparé est demandée sur Bullseye
- **THEN** DIU refuse avant persistance, cette version utilisant le composant non-free pour ses firmwares
