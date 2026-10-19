## MODIFIED Requirements

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

## ADDED Requirements

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
