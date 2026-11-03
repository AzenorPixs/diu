## MODIFIED Requirements

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
