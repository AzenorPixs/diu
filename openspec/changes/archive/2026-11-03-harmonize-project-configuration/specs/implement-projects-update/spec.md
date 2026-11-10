## MODIFIED Requirements

### Requirement: mise à jour des variables générales d'un projet

DIU MUST exposer `rid projects update <ID PROJECT>` via `update_projects()`, sans changer l'identifiant demandé. La fonction MUST gérer `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED`, `PROJECT_DEBIAN_PACKAGE`, `PROJECT_ORCHESTRATED_CODING` et `PROJECT_VERSION` dans `<projet>/project.env`. Elle MUST proposer les valeurs existantes et préserver les autres lignes et les droits prévus de configuration.

#### Scenario: création de la configuration générale

- **GIVEN** un répertoire de projet existant sans `project.env`
- **WHEN** l'utilisateur configure les variables générales
- **THEN** `PROJECT_TYPE` vaut `BASH` par défaut, les options binaires sont proposées à `No`, et un nom et une version valides sont demandés

#### Scenario: mise à jour ciblée du projet

- **GIVEN** une configuration existante valide
- **WHEN** l'utilisateur conserve les valeurs proposées
- **THEN** les variables générales et la version sont conservées ainsi que les lignes hors périmètre

## ADDED Requirements

### Requirement: Questionnaire commun de configuration initiale et mise à jour

DIU MUST présenter les types BASH, GO, JAVASCRIPT, PERL et PYTHON sans interdire les autres types. PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE MUST accepter exclusivement Yes ou No, avec No par défaut et redemande en cas d'entrée invalide. PROJECT_VERSION MUST être demandée au format x.y.z sans zéro initial et enregistrée ; sa valeur existante valide MUST être proposée à la mise à jour. Sans version existante, une saisie valide MUST être fournie. Toute fin d'entrée MUST échouer avant persistance.

#### Scenario: Configuration initiale

- **WHEN** les informations valides sont saisies lors de la création
- **THEN** les variables générales et la version sont enregistrées dans project.env

#### Scenario: Mise à jour et entrée invalide

- **WHEN** une réponse binaire ou une version est invalide
- **THEN** elle est redemandée et ne remplace pas la configuration

### Requirement: Protocole de codage intégré à CAB

La création et la synchronisation MUST NOT exiger ni copier ancien protocole local, quel que soit le mode de développement. La synchronisation MUST conserver tout document destination existant.

#### Scenario: Mode piloté sans document source

- **WHEN** un projet piloté est créé ou synchronisé sans document source
- **THEN** l'absence du document ne provoque pas d'échec et aucune copie n'est effectuée

## REMOVED Requirements

### Requirement: Copie conditionnelle du protocole de codage piloté

**Reason**: Le protocole est intégré à CAB.
**Migration**: Les documents existants sont conservés sans être synchronisés.

### Requirement: Préservation du protocole en mode autonome

**Reason**: La copie est supprimée pour tous les modes.
**Migration**: Les documents existants sont conservés.

### Requirement: Échec avant copie du modèle

**Reason**: Le fichier de protocole n'est plus un prérequis ; le mode reste validé par son lecteur.
**Migration**: Aucune.

### Requirement: Décision du mode pour chaque projet synchronisé

**Reason**: La copie du protocole est supprimée pour tous les projets.
**Migration**: La synchronisation groupée conserve son traitement des erreurs.
