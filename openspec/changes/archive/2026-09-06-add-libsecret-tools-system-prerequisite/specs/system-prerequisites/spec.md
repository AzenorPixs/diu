# Change: Ajouter libsecret-tools aux prérequis système

## MODIFIED Requirements

### Requirement: Liste obligatoire

Le module `system` SHALL gérer également le prérequis Debian `libsecret-tools`.

#### Scenario: Liste des prérequis

- **WHEN** la fonction d'installation des prérequis est appelée
- **THEN** elle inclut `libsecret-tools` dans la liste obligatoire et le traite avec le mécanisme existant
