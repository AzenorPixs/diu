## MODIFIED Requirements

### Requirement: initialisation de configuration incomplète

Si `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_DOCKERED`,
`PROJECT_DEBIAN_PACKAGE` ou toute variable `REMOTE_GITLAB_*` attendue, y
compris `REMOTE_GITLAB_REGISTRY`, est manquante ou invalide,
`projects_gitlab_release` SHALL appeler automatiquement :

- `update_projects <ID PROJECT>` ;
- `gitlab_update <ID PROJECT>`.

Puis la fonction reprend la commande de release.

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

## ADDED Requirements

### Requirement: registre Docker GitLab explicite

Une release Docker GitLab SHALL utiliser `REMOTE_GITLAB_REGISTRY` comme
autorité du registre pour l'authentification Docker et les références d'image.
Elle MUST conserver cette valeur telle qu'elle est configurée, y compris un
port explicite, sans la déduire de `REMOTE_GITLAB_BASE_URL`. Cette valeur MUST
être une autorité de registre sans protocole ni chemin.

#### Scenario: registre avec port dédié

- **GIVEN** que `REMOTE_GITLAB_BASE_URL` vaut `https://git.ec-nantes.fr`
- **AND** que `REMOTE_GITLAB_REGISTRY` vaut `git.ec-nantes.fr:5050`
- **WHEN** une release Docker GitLab est demandée
- **THEN** l'authentification Docker cible `git.ec-nantes.fr:5050`
- **AND** les images versionnée et `latest` utilisent
  `git.ec-nantes.fr:5050/<owner>/<repository>`

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
