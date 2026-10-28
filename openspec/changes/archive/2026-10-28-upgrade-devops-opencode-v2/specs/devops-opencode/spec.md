# Spec Delta

## Purpose

Définit l'installation et la mise à jour de la version majeure 2 d'OpenCode dans l'environnement DevOps du DIU, en suivant les releases stables et en évitant les réinstallations inutiles.

## ADDED Requirements

### Requirement: Détection d'une release OpenCode V2

Lorsque `OPENCODE=1`, DIU SHALL déterminer la dernière release stable disponible sur le dépôt officiel OpenCode et SHALL accepter uniquement une version stable de majeure 2.

#### Scenario: Release stable V2 disponible
- **WHEN** GitHub fournit une dernière release stable avec une version `2.x.y`
- **THEN** DIU retient cette version pour la comparaison locale

#### Scenario: Release hors V2 ou illisible
- **WHEN** la dernière release ne porte pas une version stable `2.x.y` ou ne peut pas être déterminée
- **THEN** DIU signale une erreur et SHALL NOT lancer d'installation ni de mise à jour OpenCode

### Requirement: Mise à jour OpenCode uniquement vers une V2 plus récente

Lorsque `OPENCODE=1`, DIU SHALL installer la release V2 détectée si le binaire est absent ou si sa version stable est inférieure. L'installation SHALL utiliser l'installateur officiel V2 et SHALL NOT utiliser l'installateur V1.

#### Scenario: Binaire absent
- **WHEN** aucun binaire OpenCode n'est installé et qu'une release stable V2 est disponible
- **THEN** DIU installe OpenCode depuis l'installateur V2 officiel

#### Scenario: Version V1 installée
- **WHEN** la version installée est `1.19.4` et qu'une release stable V2 est disponible
- **THEN** DIU installe OpenCode depuis l'installateur V2 officiel

#### Scenario: Version installée plus ancienne
- **WHEN** la version stable installée est inférieure à la dernière version stable V2
- **THEN** DIU installe OpenCode depuis l'installateur V2 officiel

#### Scenario: Version égale ou plus récente
- **WHEN** la version installée est égale ou supérieure à la dernière version stable V2
- **THEN** DIU conserve le binaire installé sans lancer l'installateur

#### Scenario: Comparaison numérique
- **WHEN** les versions diffèrent par le nombre de chiffres d'une composante, par exemple `2.10.0` et `2.9.0`
- **THEN** DIU compare les composantes numériquement et traite `2.10.0` comme plus récente

### Requirement: Échec de détection sans installation

Si la version distante ou la version locale nécessaire à la comparaison est invalide ou indisponible, DIU SHALL signaler l'échec et SHALL NOT lancer l'installateur OpenCode.

#### Scenario: Téléchargement de la release en échec
- **WHEN** la requête GitHub échoue
- **THEN** DIU retourne un code non nul et n'exécute aucune commande d'installation OpenCode

#### Scenario: Version locale invalide
- **WHEN** un binaire existe mais sa commande de version ne retourne pas une version stable `x.y.z`
- **THEN** DIU signale l'échec sans remplacer le binaire

### Requirement: Préservation du périmètre d'installation DevOps

La mise à jour SHALL préserver l'activation par `OPENCODE=1`, le chemin du binaire DevOps et l'absence de modification automatique du `PATH`. Lorsque `OPENCODE` ne vaut pas `1`, DIU SHALL NOT consulter GitHub ni installer OpenCode.

#### Scenario: OpenCode désactivé
- **WHEN** `OPENCODE` ne vaut pas `1`
- **THEN** DIU ne lance aucune requête GitHub et aucune commande d'installation OpenCode

#### Scenario: Mise à jour réussie
- **WHEN** l'installation V2 se termine avec succès
- **THEN** le binaire DevOps conserve son chemin prévu et reçoit le droit d'exécution
- **AND** l'ancien fichier `/etc/profile.d/opencode.sh` est nettoyé comme auparavant
