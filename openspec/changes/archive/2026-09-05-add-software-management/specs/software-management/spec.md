# Specification: software-management

## ADDED Requirements

### Requirement: Routage du cycle de vie des logiciels

DIU SHALL accepter `rid install <ENGINE> <SOFTWARE>`,
`rid remove <ENGINE> <SOFTWARE>`, `rid update <ENGINE> <SOFTWARE>` et
`rid update <ENGINE>`. Les moteurs définis SHALL être `deb` et `apt`.
Le logiciel SHALL être obligatoire pour installer ou désinstaller.
Un moteur inconnu, un identifiant invalide ou des arguments supplémentaires
SHALL provoquer un échec explicite avant toute opération sur le système.

#### Scenario: Installation ciblée

- **WHEN** `rid install deb geany` est invoqué
- **THEN** DIU délègue l'installation de `geany` au moteur `deb`

#### Scenario: Désinstallation sans logiciel

- **WHEN** `rid remove deb` est invoqué
- **THEN** DIU retourne une erreur de syntaxe sans désinstaller de paquet

#### Scenario: Moteur inconnu

- **WHEN** une commande désigne un moteur inconnu
- **THEN** DIU retourne une erreur sans exécuter d'opération de remplacement

### Requirement: Paquets officiels Debian

Le moteur `deb` SHALL installer, désinstaller et mettre à jour les paquets
logiciels officiels Debian à l'aide de la gestion APT Debian.
Il SHALL vérifier que le paquet ciblé relève de son périmètre et SHALL NOT
sélectionner une version issue d'un dépôt tiers, y compris pour les dépendances.
Il SHALL signaler l'impossibilité de satisfaire ce périmètre sans basculer
implicitement vers le moteur `apt`.

#### Scenario: Installation officielle

- **WHEN** `rid install deb <SOFTWARE>` cible un paquet officiel disponible
- **THEN** DIU installe ce paquet et ses dépendances nécessaires depuis les sources officielles autorisées

#### Scenario: Version tierce candidate

- **WHEN** un dépôt tiers fournit une version candidate du paquet demandé
- **THEN** le moteur `deb` ne sélectionne pas cette version tierce
- **AND** il échoue explicitement si aucune résolution officielle admissible n'est possible

#### Scenario: Désinstallation officielle

- **WHEN** `rid remove deb <SOFTWARE>` cible un paquet officiel installé
- **THEN** DIU demande sa désinstallation au gestionnaire de paquets
- **AND** tout échec est propagé à l'appelant

### Requirement: Portée des mises à jour du moteur deb

`rid update deb <SOFTWARE>` SHALL mettre à jour uniquement le logiciel officiel
ciblé et les dépendances nécessaires à cette opération.
`rid update deb` SHALL traiter tous les paquets officiels Debian installés,
y compris ceux installés en dehors de DIU, sans inclure les logiciels tiers.
Une mise à jour SHALL NOT installer un logiciel cible absent.

#### Scenario: Mise à jour ciblée

- **WHEN** `rid update deb geany` est invoqué pour un paquet installé
- **THEN** DIU limite l'opération à ce paquet et à ses dépendances nécessaires

#### Scenario: Mise à jour de tous les paquets officiels

- **WHEN** `rid update deb` est invoqué
- **THEN** DIU traite les mises à jour admissibles de tous les paquets officiels installés
- **AND** il ne met pas à jour les paquets tiers

#### Scenario: Logiciel cible absent

- **WHEN** une mise à jour ciblée désigne un logiciel non installé
- **THEN** DIU signale cette absence sans installer le logiciel

### Requirement: Logiciels tiers avec dépôt

Le moteur `apt` SHALL déterminer, à partir de la définition du logiciel, si
l'installation dépend d'un dépôt. Si oui, il SHALL déléguer la préparation de
ce dépôt au moteur de dépôts DIU avant d'installer le paquet.
Il SHALL NOT reproduire localement un moteur de dépôts de remplacement.
La désinstallation et la mise à jour SHALL cibler les paquets du logiciel tiers.

#### Scenario: Dépôt requis

- **WHEN** `rid install apt <SOFTWARE>` cible un logiciel nécessitant un dépôt
- **THEN** DIU fait préparer le dépôt par son moteur de dépôts
- **AND** il installe le paquet uniquement après le succès de cette préparation

#### Scenario: Moteur de dépôts indisponible

- **WHEN** l'installation requiert un dépôt et que son moteur DIU n'est pas disponible
- **THEN** DIU signale la fonctionnalité indisponible et retourne un code non nul
- **AND** il ne tente pas l'installation du logiciel

### Requirement: Logiciels tiers sans dépôt

Pour un logiciel tiers sans dépôt, le moteur `apt` SHALL appeler une fonction
propre au logiciel pour chacune des actions installation, désinstallation et
mise à jour. Il SHALL NOT construire une commande arbitraire à partir de
l'identifiant fourni par l'utilisateur.

#### Scenario: Installation sans dépôt

- **WHEN** `rid install apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique d'installation
- **AND** il n'appelle pas le moteur de dépôts

#### Scenario: Désinstallation sans dépôt

- **WHEN** `rid remove apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de désinstallation

#### Scenario: Mise à jour sans dépôt

- **WHEN** `rid update apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de mise à jour

#### Scenario: Fonction indisponible

- **WHEN** une action ne dispose pas de fonction spécifique pour le logiciel
- **THEN** DIU signale l'action non prise en charge et retourne un code non nul

### Requirement: Mise à jour de tous les logiciels tiers

`rid update apt` SHALL traiter tous les logiciels tiers installés et reconnus
par DIU, selon leur mode avec dépôt ou sans dépôt, sans traiter les logiciels
officiels du moteur `deb` ni installer des logiciels absents.

#### Scenario: Mise à jour du moteur apt

- **WHEN** `rid update apt` est invoqué et le moteur est disponible
- **THEN** DIU exécute les mises à jour des logiciels tiers installés reconnus
- **AND** il utilise les fonctions propres aux logiciels sans dépôt

### Requirement: Erreurs et répétition des opérations

Les moteurs SHALL propager les échecs avec un diagnostic et un code non nul.
Une installation d'un logiciel déjà à la version attendue, une suppression
d'un logiciel reconnu déjà absent ou une mise à jour sans version plus récente
SHALL signaler cet état sans effet de bord inattendu.

#### Scenario: Échec du gestionnaire de paquets

- **WHEN** le gestionnaire de paquets échoue
- **THEN** DIU retourne un code non nul et ne présente pas l'action comme réussie

#### Scenario: Aucune mise à jour disponible

- **WHEN** un logiciel est déjà à jour
- **THEN** DIU signale cet état sans réinstallation inutile

### Requirement: Isolation des sources officielles dans la première étape

Le moteur `deb` SHALL utiliser des index temporaires limités aux dépôts d'origine
Debian de la version installée, avec ses suites updates et security, vérifiés
avec le trousseau officiel Debian. Il SHALL NOT modifier les sources persistantes
ni inclure les backports ou une autre version majeure de Debian.
Une origine installée non vérifiable SHALL entraîner un refus explicite.

#### Scenario: Sources officielles et tierces mélangées

- **WHEN** la machine dispose de dépôts officiels et tiers
- **THEN** la transaction deb utilise uniquement les index officiels isolés
- **AND** les sources persistantes restent inchangées

#### Scenario: Version installée introuvable dans les index officiels

- **WHEN** la version installée ne figure ni dans les index officiels actualisés ni dans les anciens index officiels disponibles
- **THEN** DIU refuse l'opération sur ce paquet et signale une origine non vérifiable

#### Scenario: Moteur apt réservé à une étape ultérieure

- **WHEN** une commande apt est invoquée dans la première étape sans moteur implémenté
- **THEN** DIU retourne un code non nul et annonce explicitement son indisponibilité
