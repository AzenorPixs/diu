# projects-template-all Specification

## Purpose
Définir le traitement de tous les modèles pour tous les projets configurés,
avec OpenSpec avant DevOps et DevOps en dernier pour chaque projet,
une sélection project.env commune et un bilan des résultats.

## Requirements

### Requirement: Commande de tous les modèles pour tous les projets

DIU SHALL exposer `diu projects template all all` et projects_template_all_all
sans argument. Le premier all SHALL désigner tous les modèles disponibles,
actuellement OpenSpec et DevOps ; le second SHALL désigner tous les projets
configurés. La CLI SHALL refuser un identifiant individuel après le premier
all, les arguments manquants ou supplémentaires. Les commandes existantes
individuelles, groupées et create SHALL être conservées.

#### Scenario: Commande complète

- **WHEN** l'utilisateur exécute diu projects template all all
- **THEN** la CLI appelle uniquement projects_template_all_all sans argument

#### Scenario: Commande invalide

- **WHEN** all est suivi d'un projet individuel, manque d'un argument ou contient un argument supplémentaire
- **THEN** la CLI rend un code non nul avant tout traitement

### Requirement: Sélection commune des projets configurés

La fonction SHALL réutiliser la sélection DevOps sur la racine effective des projets, accepter seulement les configurations littérales conformes et signaler les autres sans les exécuter ni exposer leurs valeurs.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Dossiers éligibles

- **WHEN** plusieurs dossiers ordinaires, cachés ou nommés all ou template satisfont les critères
- **THEN** chacun est sélectionné une fois sans parcourir les sous-dossiers

#### Scenario: Configuration invalide

- **WHEN** une variable requise manque, est vide ou l'identifiant est discordant, ou un chemin est symbolique
- **THEN** le dossier est ignoré sans appeler un modèle

#### Scenario: Sélection commune et protection des configurations

- **WHEN** la fonction sélectionne les projets pour tous les modèles
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL utiliser ENV_DEVOPS_PROJECTS_ROOT, sinon
/home/${ENV_DEVOPS_USER}/datas, et réutiliser le contrôle de sélection DevOps
existant. Elle SHALL parcourir les dossiers directs, cachés compris, avec
project.env ordinaire et cinq affectations littérales non vides : PROJECT_ID,
PROJECT_NAME, PROJECT_TYPE, PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE.
PROJECT_ID SHALL correspondre au dossier ; 0 et No SHALL être acceptés.
Les dossiers et project.env symboliques, identifiants invalides et
configurations absentes, illisibles, incomplètes ou discordantes SHALL être
signalés puis ignorés. La sélection SHALL NOT exécuter project.env, utiliser
des valeurs héritées du shell ou afficher les valeurs de configuration.

### Requirement: DevOps en dernier pour chaque projet

La fonction SHALL appeler les modèles individuels dans l’ordre prévu, garder DevOps en dernier, poursuivre les autres projets après échec et conserver les écritures partielles.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Ordre par projet

- **WHEN** deux projets sont sélectionnés
- **THEN** OpenSpec puis DevOps sont exécutés pour le premier avant OpenSpec puis DevOps pour le second

#### Scenario: Échec OpenSpec

- **WHEN** OpenSpec échoue pour un projet
- **THEN** DevOps n'est pas appelé pour ce projet et le projet suivant est traité

#### Scenario: Échec DevOps

- **WHEN** DevOps échoue après réussite OpenSpec
- **THEN** le projet est déclaré échoué, ses fichiers sont conservés et le projet suivant est traité

#### Scenario: Ordre et poursuite des modèles par projet

- **WHEN** les modèles sont appliqués aux projets sélectionnés
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL appeler directement les modèles individuels pour chaque
projet, actuellement projects_template_openspec puis projects_template_devops.
DevOps SHALL rester l'étape finale après les autres modèles du projet.
Un échec OpenSpec SHALL empêcher DevOps pour ce projet. Un échec d'une étape
SHALL être signalé et SHALL NOT empêcher le traitement du projet suivant.
Les commandes et l'utilisateur su existants d'OpenSpec SHALL être conservés.
Le dossier all SHALL être traité directement sans récursion. Les écritures
existantes ou partielles SHALL être conservées en cas d'échec.

### Requirement: Prérequis et bilan des modèles

La fonction SHALL vérifier ses prérequis avant traitement, afficher un bilan exact et retourner un statut cohérent avec les échecs ou l’absence de projet éligible.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Bilan mixte

- **WHEN** un projet échoue et un autre réussit
- **THEN** le bilan contient deux sélectionnés, un réussi et un échoué et le code final est non nul

#### Scenario: Aucun projet éligible

- **WHEN** aucun dossier ne satisfait les critères
- **THEN** aucun modèle n'est appelé, un bilan est affiché et la commande réussit

#### Scenario: Prérequis invalide

- **WHEN** un argument, la racine, le compte, les droits ou Python est invalide
- **THEN** la commande signale l'échec avant tout appel de modèle

#### Scenario: Prérequis et comptage du bilan des modèles

- **WHEN** le traitement de tous les modèles est préparé puis terminé
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL valider ses arguments, le compte ENV_DEVOPS_USER, les
droits root ou du compte DevOps, la racine et le Python système avant
traitement. Elle SHALL afficher les nombres de projets sélectionnés,
réussis, ignorés et échoués. Un projet SHALL compter réussi uniquement si
tous ses modèles réussissent et échoué une seule fois si une étape échoue.
Au moins un échec SHALL produire un code non nul ; sans projet éligible,
la fonction SHALL afficher ce fait et le bilan puis rendre un succès.
