# software-engines Specification

## Purpose
Piloter les moteurs logiciels et leurs dépendances sans supprimer de composants partagés.

## Requirements

### Requirement: Configuration des moteurs
Le DIU MUST exposer `SYSTEM_APT_ENGINE`, `SYSTEM_GITHUB_ENGINE` et `SYSTEM_FLATPAK_ENGINE` avec les états 0 et 1 ; Flatpak MAY conserver `UNSET` lorsqu’un état historique est indéterminé. APT MUST valoir 1 par défaut. La valeur Flatpak historique MUST être reprise lorsque la nouvelle variable est absente. Une valeur invalide MUST produire une erreur.

#### Scenario: Migration Flatpak
- **WHEN** l'ancienne variable est définie et la nouvelle absente
- **THEN** le nouvel état reprend la valeur historique.

### Requirement: Isolation des tests de persistance
Si `SYSTEM_ENGINE_CONFIG_FILE` est fourni, le DIU MUST l’utiliser comme chemin de persistance, dont le défaut est `/root/diu/config/system.env`. `SYSTEM_FLATPAK_ENGINE_CONFIG_FILE` MAY remplacer le chemin des fonctions Flatpak historiques ; `SYSTEM_FLATPAK_CONFIG_FILE` reste accepté comme repli.

#### Scenario: Configuration temporaire
- **WHEN** un chemin de test isolé est fourni
- **THEN** les modifications sont limitées à ce chemin.

### Requirement: Activation et désactivation
Les commandes `diu system engine install|remove apt|github|flatpak` MUST activer ou désactiver le moteur ciblé. L'activation MUST garantir ses dépendances avant la persistance. La désactivation MUST préserver les dépendances installées. Les moteurs désactivés MUST refuser les actions logicielles explicites et être ignorés par les mises à jour globales.

#### Scenario: Désactivation
- **WHEN** un moteur est désactivé
- **THEN** son état devient 0 sans désinstaller ses dépendances.

#### Scenario: Échec d'activation
- **WHEN** les dépendances ne peuvent pas être satisfaites
- **THEN** l'erreur est signalée et l'état 1 n'est pas persisté.

### Requirement: Dépendances et informations
Le moteur APT MUST vérifier apt, apt-transport-https, apt-utils et dpkg-query. GitHub MUST vérifier curl, jq, tar, gzip et sha256sum. Flatpak MUST vérifier Flatpak et Flathub lorsqu'il est activé. `diu infos softwares` MUST considérer l'état configuré et les dépendances dans la disponibilité affichée. Les aides MUST présenter les commandes de moteur.

#### Scenario: Moteur désactivé
- **WHEN** un moteur vaut 0 et ses dépendances sont installées
- **THEN** son titre est affiché comme indisponible.
