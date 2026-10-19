# Release GitLab des projets DIU

## Purpose

Définir la publication conditionnelle d'artefacts vers une release GitLab.

## Requirements

### Requirement: commande de release GitLab

Le système SHALL exposer la commande `rid projects gitlab release <ID PROJECT>`.

#### Scenario: release d'un projet Dockerisé

- ÉTANT DONNÉ le dépôt local du projet `diu`.
- QUAND l'utilisateur exécute `rid projects gitlab release diu`.
- ALORS l'image Docker locale `diu:latest` est poussée vers le registre GitLab configuré.

### Requirement: initialisation de configuration incomplète

`projects_gitlab_release` SHALL corriger séparément les blocs incomplets :
`update_projects <ID PROJECT>` pour `PROJECT_ID` non conforme à la cible ou
`PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED`, `PROJECT_DEBIAN_PACKAGE`
absents ; `gitlab_update <ID PROJECT>` pour les variables GitLab attendues,
dont `REMOTE_GITLAB_REGISTRY` manquante ou invalide. Chaque correction SHALL
être suivie d'un rechargement et d'une vérification de `project.env` avant
publication.

#### Scenario: configuration GitLab incomplète

- **GIVEN** qu'une variable générale ou GitLab requise est absente
- **WHEN** une release GitLab est demandée
- **THEN** les mises à jour de configuration nécessaires sont exécutées avant
  la reprise de la release

#### Scenario: registre Docker GitLab absent

- **GIVEN** qu'un projet Dockerisé possède les autres variables GitLab requises
- **AND** que `REMOTE_GITLAB_REGISTRY` est absente
- **WHEN** une release GitLab est demandée
- **THEN** `gitlab_update <ID PROJECT>` est exécutée avant toute commande
  Docker de publication
- **AND** la release utilise la valeur enregistrée après rechargement de
  `project.env`

#### Scenario: registre Docker GitLab avec protocole

- **GIVEN** qu'un projet Dockerisé possède
  `REMOTE_GITLAB_REGISTRY=https://git.ec-nantes.fr:5050`
- **WHEN** une release GitLab est demandée
- **THEN** `gitlab_update <ID PROJECT>` est exécutée avant toute commande
  Docker de publication
- **AND** le registre corrigé ne contient pas de protocole

#### Scenario: Bloc général complet et bloc GitLab incomplet

- **GIVEN** que la configuration générale est complète et conforme et que GitLab est incomplet
- **WHEN** une release GitLab est demandée
- **THEN** seul gitlab_update est appelé pour compléter la configuration
- **AND** project.env est rechargé et revérifié avant toute publication

#### Scenario: Bloc général incomplet et bloc GitLab complet

- **GIVEN** que la configuration générale est incomplète et que GitLab est complet et valide
- **WHEN** une release GitLab est demandée
- **THEN** seul update_projects est appelé pour compléter la configuration
- **AND** project.env est rechargé et revérifié avant toute publication

#### Scenario: Configuration entièrement complète

- **GIVEN** que les deux blocs sont complets et conformes
- **WHEN** une release GitLab est demandée
- **THEN** aucune fonction de mise à jour de configuration n'est appelée

### Requirement: publication Docker conditionnelle

Lorsque `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`, la commande SHALL tenter la
publication Docker.

Lorsque `PROJECT_DOCKERED` n’a pas cette valeur, la commande SHALL ignorer la
partie Docker.

#### Scenario: projet non Dockerisé

- ÉTANT DONNÉ que `PROJECT_DOCKERED` n'est pas activé
- QUAND une release GitLab est demandée
- ALORS aucune publication Docker n'est tentée

### Requirement: publication Debian conditionnelle

Lorsque `PROJECT_DEBIAN_PACKAGE` vaut `Yes`, `YES` ou `1`, la commande SHALL tenter
la publication du paquet Debian.

Lorsque `PROJECT_DEBIAN_PACKAGE` n’a pas cette valeur, la commande SHALL ignorer la
partie Debian.

#### Scenario: paquet Debian désactivé

- ÉTANT DONNÉ que `PROJECT_DEBIAN_PACKAGE` n'est pas activé
- QUAND une release GitLab est demandée
- ALORS aucune publication Debian n'est tentée

### Requirement: sélection de paquet Debian

Lorsque le répertoire `dist/` est requis par la configuration Debian:

- s'il est absent → la commande SHALL retourner une erreur explicite.
- s'il contient zéro `.deb` → la commande SHALL retourner une erreur explicite.
- s'il contient plus d'un `.deb` → la commande SHALL retourner une erreur explicite
en listant les fichiers détectés.
- s'il contient un seul `.deb` → la commande poursuit la publication GitLab.

#### Scenario: paquet Debian unique

- ÉTANT DONNÉ que `dist/` contient un unique paquet `.deb`
- QUAND la publication Debian est requise
- ALORS la publication GitLab se poursuit avec ce paquet

### Requirement: aide CLI

`rid projects help` SHALL présenter `gitlab` avec `release`.

`rid projects gitlab help` SHALL présenter `update`, `push` et `release`.

`rid projects gitlab release <ID PROJECT>` SHALL afficher une aide cohérente.

#### Scenario: aide de release GitLab

- ÉTANT DONNÉ que l'utilisateur demande l'aide GitLab
- QUAND l'aide est affichée
- ALORS la commande `release` est présentée avec `update` et `push`

### Requirement: compatibilité

L'ajout de `projects gitlab release` SHALL préserver les comportements existants
de `rid projects gitlab push`, `projects_forgejo_release`, `git_push_provider` et des
parcours d'authentification GitLab.

#### Scenario: comportements existants préservés

- ÉTANT DONNÉ que les parcours de publication existants sont disponibles
- QUAND la release GitLab est ajoutée
- ALORS ces parcours conservent leur comportement

### Requirement: registre Docker GitLab explicite

Toute release GitLab SHALL exiger `REMOTE_GITLAB_REGISTRY`, y compris sans
publication Docker. Cette valeur MUST être une autorité sans protocole ni
chemin. La publication Docker SHALL l'utiliser telle quelle pour
l'authentification et les références d'image, port inclus, sans la déduire
de `REMOTE_GITLAB_BASE_URL`.

#### Scenario: registre avec port dédié

- **GIVEN** que `REMOTE_GITLAB_BASE_URL` vaut `https://git.ec-nantes.fr`
- **AND** que `REMOTE_GITLAB_REGISTRY` vaut `git.ec-nantes.fr:5050`
- **WHEN** une release Docker GitLab est demandée
- **THEN** l'authentification Docker cible `git.ec-nantes.fr:5050`
- **AND** les images versionnée et `latest` utilisent
  `git.ec-nantes.fr:5050/<owner>/<repository>`

#### Scenario: Release uniquement Debian sans registre

- **GIVEN** que le projet active uniquement la publication Debian et que REMOTE_GITLAB_REGISTRY est absente
- **WHEN** une release GitLab est demandée
- **THEN** gitlab_update est appelée avant la publication Debian
- **AND** aucune publication Docker n'est déclenchée

### Requirement: reprise ciblée d'une publication Docker transitoirement incohérente

Lorsqu'un `docker push` GitLab échoue avec le diagnostic
`blob unknown to registry`, la release SHALL réessayer ce même tag au plus
deux fois, après une attente progressive. Elle MUST conserver l'échec immédiat
pour tout autre diagnostic et MUST retourner un échec explicite lorsque les
trois tentatives échouent.

#### Scenario: blob rendu disponible après le premier push

- **GIVEN** qu'un premier `docker push` d'un tag GitLab échoue avec
  `blob unknown to registry`
- **WHEN** la tentative suivante réussit
- **THEN** la release poursuit la publication avec le tag suivant

#### Scenario: erreur de publication non transitoire

- **GIVEN** qu'un `docker push` GitLab échoue avec un diagnostic différent de
  `blob unknown to registry`
- **WHEN** la release traite cet échec
- **THEN** elle retourne l'échec sans relancer ce tag
