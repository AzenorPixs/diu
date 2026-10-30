# projects-forgejo-push-all Specification

## Purpose
Définir la publication groupée vers Forgejo des dépôts de projets DIU déjà
configurés.

## Requirements

### Requirement: publication Forgejo de tous les projets configurés

DIU MUST exposer `rid projects forgejo push all`. La commande MUST parcourir
les sous-répertoires directs de `${DEVOPS_PROJECTS_ROOT}`, dont la valeur
attendue est `/home/${DEVOPS_USER}/datas`, et appeler `forgejo_push()` une
fois pour chaque projet sélectionné.

#### Scenario: plusieurs projets Forgejo configurés

- **WHEN** l'utilisateur exécute `rid projects forgejo push all`
- **THEN** DIU parcourt les sous-répertoires directs de
  `${DEVOPS_PROJECTS_ROOT}`
- **AND THEN** il appelle `forgejo_push()` une fois pour chaque projet
  sélectionné

### Requirement: sélection non interactive des projets Forgejo

forgejo_push_all() MUST sélectionner uniquement les projets conformes aux critères détaillés ci-dessous, annoncer et ignorer les autres, sans assistant de configuration.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: configuration Forgejo absente ou incomplète

- **WHEN** un sous-répertoire ne contient pas `project.env` ou contient une
  variable requise absente ou incohérente
- **THEN** DIU l'ignore avec un diagnostic
- **AND THEN** aucun push ni assistant de configuration n'est exécuté pour ce
  répertoire

#### Scenario: Critères complets de sélection Forgejo groupée

- **WHEN** forgejo_push_all sélectionne les projets à publier
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

`forgejo_push_all()` MUST sélectionner uniquement un répertoire contenant un
fichier `project.env` où `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`,
`PROJECT_DOCKERED`, `REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER`,
`REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`,
`REMOTE_FORGEJO_BRANCH` et `REMOTE_FORGEJO_SSL_VERIFY` sont définis.
`PROJECT_ID` MUST correspondre au nom du répertoire. Un répertoire non
conforme MUST être annoncé et ignoré ; DIU MUST NOT appeler un assistant de
mise à jour de configuration pour ce répertoire.

### Requirement: poursuite après un échec de push Forgejo

`forgejo_push_all()` MUST poursuivre le parcours lorsque `forgejo_push()`
échoue pour un projet sélectionné. Après le parcours, elle MUST retourner un
code non nul si au moins un push a échoué.

#### Scenario: échec isolé

- **WHEN** le push Forgejo d'un projet sélectionné échoue et qu'un autre
  projet est encore sélectionné
- **THEN** DIU tente le push de l'autre projet
- **AND THEN** la commande retourne un code non nul après le parcours

### Requirement: agrégation des indisponibilités Forgejo

Le parcours groupé MUST poursuivre après une indisponibilité reconnue et
MUST la distinguer des pushes publiés. Il MUST retourner zéro si aucun échec
réel n'est rencontré, sans annoncer que tous les projets ont été publiés.
Un autre échec MUST conserver le résultat final non nul existant.

#### Scenario: projet indisponible et projet publié

- **WHEN** un projet est indisponible et un autre est publié
- **THEN** le parcours termine avec un état indiquant les indisponibilités et un code zéro

#### Scenario: erreur réelle dans le parcours

- **WHEN** un push échoue pour une cause non qualifiée comme indisponibilité
- **THEN** le parcours continue et termine avec un code non nul
