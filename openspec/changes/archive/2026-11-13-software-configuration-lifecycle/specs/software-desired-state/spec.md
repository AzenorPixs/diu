## MODIFIED Requirements

### Requirement: Opérations génériques par moteur
Chaque moteur SHALL fournir des opérations agnostiques d'installation, de désinstallation, de convergence, de configuration et de nettoyage. Les métadonnées et traitements propres aux logiciels SHALL être déclarés séparément.

#### Scenario: Logiciel déclaré
- **WHEN** une opération cible un logiciel déclaré du moteur
- **THEN** l'opération générique utilise les informations et traitements déclarés pour ce logiciel

### Requirement: Convergence sans mutation du désir
La convergence SHALL comparer l'état désiré à l'état réel et corriger tout écart par installation ou désinstallation. Elle SHALL préserver l'état désiré, y compris en cas d'échec, et vérifier l'état réel après correction. Si les deux états valent 0, elle SHALL ne produire aucune sortie console pour le logiciel.

#### Scenario: État déjà conforme
- **WHEN** l'état réel et l'état désiré valent 1
- **THEN** DIU applique sa configuration et signale l'état conforme

#### Scenario: Logiciel absent et non désiré
- **WHEN** l'état réel et l'état désiré valent 0
- **THEN** DIU ne produit aucune sortie console pour ce logiciel et ne rejoue pas son nettoyage

#### Scenario: Écart corrigé
- **WHEN** l'état réel diffère de l'état désiré
- **THEN** DIU affiche une croix rouge avec l'état réel, lance l'opération appropriée et vérifie son résultat

#### Scenario: Correction échouée
- **WHEN** l'opération de correction échoue ou laisse un état différent de l'état désiré
- **THEN** DIU signale l'échec et conserve l'état désiré

#### Scenario: Installation présente mais configuration requise non conforme
- **WHEN** une installation explicite est demandée pour un logiciel présent dont la configuration nécessaire est incomplète
- **THEN** DIU signale l'écart et réapplique l'opération prévue avant de confirmer la conformité

#### Scenario: Réparation sans mise à jour de version
- **WHEN** la convergence répare une configuration d'un logiciel déjà installé
- **THEN** elle ne met pas à jour sa version ni celle des autres logiciels déjà installés

#### Scenario: Retrait APT impliquant d'autres paquets
- **WHEN** la simulation APT indique qu'une désinstallation retirerait un paquet non autorisé par l'opération
- **THEN** DIU refuse l'opération et signale les paquets concernés sans modifier l'état désiré

## ADDED Requirements

### Requirement: Configuration et nettoyage propres à chaque logiciel
Chaque logiciel pris en charge par les moteurs APT, Flatpak et GitHub SHALL disposer d'opérations de configuration et de nettoyage, y compris sous forme d'opérations sans effet lorsqu'aucun traitement n'est nécessaire. Les opérations génériques des moteurs SHALL déléguer les traitements propres au logiciel.

#### Scenario: Configuration après installation
- **WHEN** l'installation d'un logiciel réussit
- **THEN** DIU applique sa configuration et signale tout échec

#### Scenario: Convergence d'un logiciel installé
- **WHEN** l'état désiré vaut 1 et que le logiciel est installé
- **THEN** DIU applique sa configuration idempotente, sans mettre à jour sa version ni modifier son état désiré

#### Scenario: Nettoyage après désinstallation
- **WHEN** DIU désinstalle effectivement un logiciel
- **THEN** DIU exécute son nettoyage et signale tout échec

#### Scenario: Logiciel déjà absent
- **WHEN** l'état désiré vaut 0 et que le logiciel est déjà absent
- **THEN** DIU ne rejoue pas son nettoyage et ne produit aucune sortie console pour ce logiciel

#### Scenario: Rôles et fichiers partagés
- **WHEN** une configuration ou un nettoyage concerne un rôle ou une ressource partagée
- **THEN** DIU préserve les autres rôles désirés et les réglages personnels non identifiables, et signale les conflits
