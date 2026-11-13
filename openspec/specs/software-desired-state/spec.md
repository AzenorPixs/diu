# software-desired-state Specification

## Purpose
Définir l'état désiré des logiciels et la convergence de cet état avec leur installation réelle pour chaque moteur DIU.

## Requirements

### Requirement: État désiré persistant
Chaque logiciel géré SHALL disposer d'un état désiré persistant valant 0 ou 1. Une valeur existante SHALL être préservée lors des chargements suivants.

#### Scenario: Première initialisation
- **WHEN** un logiciel est initialisé sans état désiré existant et que son état réel est connu
- **THEN** son état désiré est initialisé à son état réel

#### Scenario: État déjà configuré
- **WHEN** un état désiré valide existe déjà
- **THEN** le chargement le conserve même si l'état réel diffère

### Requirement: Noms et migration des variables
Les variables SHALL utiliser les préfixes `SOFTWARE_APT_`, `SOFTWARE_FLATPAK_` et `SOFTWARE_GITHUB_` selon leur moteur. DIU SHALL migrer les valeurs existantes sans perte ni écrasement d'une valeur cible et signaler toute ambiguïté.

#### Scenario: Migration de Codex CLI
- **WHEN** seule l'ancienne variable `SOFTWARES_APT_CODEX_CLI` est définie avec une valeur valide
- **THEN** DIU reprend cette valeur dans `SOFTWARE_GITHUB_CODEX_CLI`

#### Scenario: Valeur cible présente
- **WHEN** la nouvelle variable existe déjà avec une valeur valide
- **THEN** DIU conserve cette valeur sans la remplacer par l'ancienne

#### Scenario: Identifiants Flatpak distincts
- **WHEN** deux identifiants Flatpak valides sont différents
- **THEN** leurs variables `SOFTWARE_FLATPAK_` sont distinctes et leur correspondance est conservée de façon persistante

### Requirement: Retrait des anciennes variables
Après reprise sûre de leurs valeurs, les anciennes variables gérées par GLOBAL SHALL être désactivées et celles gérées par l'ancien mécanisme SHALL être supprimées. Les nouvelles variables SHALL être les seules autorités.

#### Scenario: Ancienne déclaration GLOBAL
- **WHEN** une ancienne variable est gérée par GLOBAL et sa valeur a été reprise sans ambiguïté
- **THEN** sa déclaration est désactivée et la nouvelle variable fait autorité

#### Scenario: Ancien mécanisme
- **WHEN** une ancienne variable est gérée par l'ancien mécanisme et sa valeur a été reprise sans ambiguïté
- **THEN** l'ancienne variable est supprimée et la nouvelle variable fait autorité

### Requirement: Détection fiable de l'état réel
Chaque logiciel SHALL fournir une détection propre produisant 0 ou 1. Une erreur de détection SHALL être distinguée de ces deux états et SHALL interdire toute correction fondée sur un état supposé.

#### Scenario: Détection impossible
- **WHEN** l'état réel ne peut pas être déterminé
- **THEN** DIU signale l'erreur et ne lance ni installation ni désinstallation pour ce logiciel

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

### Requirement: Modification explicite de l'état désiré
Après initialisation, seules les commandes `diu softwares install` et `diu softwares remove` SHALL modifier l'état désiré du logiciel ciblé, respectivement à 1 et à 0, puis demander l'opération correspondante.

#### Scenario: Installation demandée
- **WHEN** un utilisateur demande l'installation d'un logiciel pris en charge
- **THEN** DIU enregistre l'état désiré 1 et demande son installation

#### Scenario: Désinstallation demandée
- **WHEN** un utilisateur demande la désinstallation d'un logiciel pris en charge
- **THEN** DIU enregistre l'état désiré 0 et demande sa désinstallation

### Requirement: Retrait des anciennes syntaxes logicielles
DIU SHALL supprimer les anciennes syntaxes `diu install`, `diu remove` et `diu update` ciblant les moteurs logiciels APT ou GitHub. Les commandes `diu softwares` SHALL constituer l'interface de gestion des logiciels.

#### Scenario: Ancienne syntaxe logicielle
- **WHEN** une ancienne syntaxe logicielle APT ou GitHub est invoquée
- **THEN** DIU la refuse sans modifier l'état désiré ni le logiciel

### Requirement: Préservation des logiciels pris en charge
DIU SHALL préserver la prise en charge des logiciels existants et des identifiants Flatpak auparavant acceptés, avec leurs traitements spécifiques nécessaires.

#### Scenario: Logiciel existant
- **WHEN** un logiciel pris en charge avant cette évolution est demandé
- **THEN** DIU conserve la possibilité de le gérer avec le moteur correspondant

### Requirement: Partage du paquet rsyslog
DIU SHALL conserver le paquet `rsyslog` tant que l'état désiré du rôle client ou du rôle serveur vaut 1. Les états et configurations des rôles SHALL être convergés séparément.

#### Scenario: Un rôle reste activé
- **WHEN** un rôle syslog est désactivé et que l'autre est activé
- **THEN** DIU conserve le paquet `rsyslog` et converge chaque rôle vers son état désiré

#### Scenario: Journalisation locale sans rôle géré
- **WHEN** le paquet `rsyslog` est présent mais qu'aucun rôle client ou serveur géré n'est actif et que les deux états désirés valent 0
- **THEN** DIU ne retire pas le paquet au seul motif de ces états conformes

#### Scenario: Configuration syslog historique non identifiable
- **WHEN** une configuration non marquée empêche de désactiver un rôle sans risque d'altérer des réglages personnels
- **THEN** DIU préserve les fichiers concernés et signale le conflit

### Requirement: Partage du bouncer CrowdSec
DIU SHALL conserver le paquet du bouncer CrowdSec tant que l'agent ou le bouncer le requiert. Lorsque les deux rôles sont activés, la configuration d'API locale de l'agent SHALL prévaloir.

#### Scenario: Deux rôles activés
- **WHEN** l'agent et le bouncer CrowdSec sont tous deux activés
- **THEN** DIU conserve le bouncer et utilise l'API locale de l'agent

#### Scenario: Agent seul
- **WHEN** l'agent est actif et que le rôle bouncer autonome est désactivé
- **THEN** DIU conserve le paquet requis par l'agent et désactive seulement le rôle autonome

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
