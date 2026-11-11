## Purpose

Porter les recettes APT dans les déclarations GLOBAL et préparer leurs prérequis en conservant les opérations génériques et les logiciels pris en charge.

## ADDED Requirements
### Requirement: Recettes GLOBAL
Les 23 logiciels APT déjà gérés SHALL conserver leur prise en charge. Leurs déclarations GLOBAL SHALL fournir métadonnées, détecteurs et hooks spécifiques ; les trois opérations communes SHALL rester agnostiques. Les recettes SHALL pouvoir être chargées sans persistance ni installation. Les blocs logiciels historiques du monolithe SHALL être retirés sans modifier les recettes DevOps, Docker ou IA.
#### Scenario: Chargement des recettes
- **WHEN** le moteur charge les recettes avant la configuration
- **THEN** aucune valeur désirée et aucun logiciel ne sont modifiés
#### Scenario: Valeurs par défaut Zsh
- **WHEN** la configuration Zsh est appliquée explicitement
- **THEN** les alias et fonctions historiques sont fournis sans écraser les définitions personnelles ni recopier les valeurs des clés API

### Requirement: Prérequis des cinq variantes
Une recette SHALL déclarer ses besoins main, contrib, non-free, non-free-firmware, dépôts tiers et artefact direct. Avant une installation nécessaire, le moteur SHALL activer et persister les besoins, vérifier les sources réelles, régénérer les sources concernées et actualiser les index avant le paquet. Les erreurs SHALL interrompre l’installation et préserver le désir logiciel.
#### Scenario: Dépôt manquant malgré variable active
- **WHEN** une installation requiert un dépôt dont la variable vaut un mais dont la source est absente
- **THEN** le moteur restaure sa déclaration et actualise les index avant installation

#### Scenario: Dépôt de code source seulement
- **WHEN** le dépôt requis ne fournit qu’une entrée deb-src active
- **THEN** l’installation prépare une entrée deb avant la transaction de paquets binaires
### Requirement: Versions des paquets directs
Les recettes directes SHALL résoudre leur artefact et leur version disponible selon la politique du logiciel, avec conservation des sélecteurs explicites existants. Le moteur système SHALL comparer les versions et installer uniquement une version plus récente ; les convergences logiciels SHALL NOT devenir des mises à jour de versions.
#### Scenario: Version directe récente
- **WHEN** la résolution retourne une version plus récente pour un logiciel activé et présent
- **THEN** le moteur système effectue sa mise à jour sans modifier le désir

### Requirement: Précondition non-free du bureau
La recette bureau existante SHALL préparer le composant non-free par le helper SYSTEM avant d’installer Chromium et intel-media-va-driver-non-free. Les paquets et le reste de la recette SHALL rester inchangés ; un échec de préparation SHALL empêcher cette installation.
#### Scenario: Pilote du bureau sans composant actif
- **WHEN** l’installation existante du groupe Chromium est nécessaire et que non-free n’est pas prêt
- **THEN** SYSTEM active le composant, vérifie la source binaire et actualise les index avant l’installation
