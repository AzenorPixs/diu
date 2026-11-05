# Publication Forgejo unifiée des projets

## Purpose

Remplacer la publication historique `gitpdi` par une release Forgejo capable
de publier les artefacts activés d'un projet DIU.

## Requirements

### Requirement: commande et fonction de release

Le système MUST exposer la commande
`diu projects forgejo release <ID PROJECT>` et la fonction
`projects_forgejo_release <ID PROJECT>`.

La fonction historique `git_push_docker_image` MUST être supprimée ou ne plus
être exposée. La commande `diu projects gitpdi <ID PROJECT>` MUST être
rejetée comme indisponible.

#### Scenario: dispatch de la nouvelle commande

- **GIVEN** un projet identifié par `diu`
- **WHEN** l'utilisateur exécute `diu projects forgejo release diu`
- **THEN** le dispatch appelle `projects_forgejo_release diu`
- **AND** aucun dispatch `gitpdi` n'est utilisé

#### Scenario: ancienne commande supprimée

- **GIVEN** que l'utilisateur exécute `diu projects gitpdi diu`
- **WHEN** le dispatch traite la commande
- **THEN** aucune publication n'est exécutée
- **AND** la commande est rejetée comme indisponible

### Requirement: complétion de la configuration

La fonction MUST charger project.env, compléter séparément les blocs général et Forgejo qui le nécessitent, puis recharger et revérifier la configuration avant publication.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: configuration générale incomplète

- **GIVEN** que `project.env` ne contient pas une variable générale requise
- **WHEN** la release est demandée
- **THEN** `update_projects <ID PROJECT>` est appelée
- **AND** la publication attend la configuration complète

#### Scenario: configuration Forgejo incomplète

- **GIVEN** que les variables Forgejo requises ne sont pas complètes
- **WHEN** la release est demandée
- **THEN** `forgejo_update <ID PROJECT>` est appelée
- **AND** la publication attend la configuration complète

#### Scenario: Complétion et rechargement des blocs de configuration

- **WHEN** la fonction prépare la configuration avant une publication Forgejo
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction MUST charger la configuration de `<projet>/project.env`.

Si une variable générale parmi `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`,
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` est absente, vide ou
incohérente avec `<ID PROJECT>`, la fonction MUST appeler
`update_projects <ID PROJECT>`, recharger `project.env` et revérifier la
configuration avant toute publication.

Si une variable Forgejo parmi `REMOTE_FORGEJO_BASE_URL`,
`REMOTE_FORGEJO_OWNER`, `REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`,
`REMOTE_FORGEJO_BRANCH` et `REMOTE_FORGEJO_SSL_VERIFY` est absente ou vide,
la fonction MUST appeler `forgejo_update <ID PROJECT>`, recharger
`project.env` et revérifier la configuration avant toute publication.

### Requirement: publication Docker conditionnelle

Lorsque `PROJECT_DOCKERED` vaut exactement `Yes`, `YES` ou `1`, la fonction
MUST vérifier que l'image locale `${PROJECT_ID}:latest` existe déjà avant de
la publier vers Forgejo.

Lorsque `PROJECT_DOCKERED` n'est pas activé, aucune commande Docker ne doit
être exécutée et la release peut continuer avec le paquet Debian.

#### Scenario: image Docker disponible

- **GIVEN** que `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`
- **AND** que `${PROJECT_ID}:latest` existe localement
- **WHEN** la release est exécutée
- **THEN** l'image est taguée pour Forgejo avec sa version et `latest`
- **AND** les deux tags sont poussés vers le dépôt Forgejo configuré

#### Scenario: image Docker absente

- **GIVEN** que `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`
- **AND** que `${PROJECT_ID}:latest` n'existe pas
- **WHEN** la release est exécutée
- **THEN** une erreur explicite est affichée
- **AND** aucun push Docker n'est effectué

### Requirement: publication Debian conditionnelle

La publication Debian MUST être conditionnée à PROJECT_DEBIAN_PACKAGE. Lorsqu’elle est activée, la fonction MUST valider l’unique paquet du projet et refuser les cas invalides décrits ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: paquet unique

- **GIVEN** que `PROJECT_DEBIAN_PACKAGE` vaut `Yes`, `YES` ou `1`
- **AND** que `dist/` contient exactement un paquet `.deb` du projet
- **WHEN** la release est exécutée
- **THEN** le paquet est validé puis publié vers Forgejo

#### Scenario: répertoire dist absent

- **GIVEN** que le paquet Debian est activé
- **AND** que `dist/` est absent
- **WHEN** la release est exécutée
- **THEN** une erreur explicite est affichée
- **AND** aucune publication Debian n'est tentée

#### Scenario: plusieurs paquets

- **GIVEN** que le paquet Debian est activé
- **AND** que `dist/` contient plusieurs paquets `.deb` du projet
- **WHEN** la release est exécutée
- **THEN** une erreur liste les paquets trouvés
- **AND** aucune publication Debian n'est tentée

#### Scenario: Sélection et validation du paquet Debian à publier

- **WHEN** la fonction traite la publication Debian conditionnelle
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Lorsque `PROJECT_DEBIAN_PACKAGE` vaut exactement `Yes`, `YES` ou `1`, la
fonction MUST vérifier que `<projet>/dist/` existe et contient exactement un
fichier paquet Debian `.deb` généré pour le projet.

La fonction MUST échouer si `dist/` est absent, vide de paquet valide ou
contient plusieurs paquets `.deb`, en indiquant les éléments responsables.
Le paquet unique MUST être validé avant sa publication Forgejo.

Lorsque `PROJECT_DEBIAN_PACKAGE` n'est pas activé, aucune lecture de `dist/`
ni publication Debian ne doit être effectuée.

### Requirement: aucun artefact activé

La fonction MUST échouer explicitement lorsqu'aucun des indicateurs
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` n'est activé.

#### Scenario: aucun artefact activé

- **GIVEN** que `PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` ne sont pas
  activés
- **WHEN** une release Forgejo est demandée
- **THEN** la commande échoue explicitement
- **AND** aucune publication n'est exécutée

### Requirement: aides CLI

`diu projects help` MUST présenter la sous-commande `forgejo` et sa release.
`diu projects forgejo help` MUST présenter
`diu projects forgejo release <ID PROJECT>` et sa description.
Les aides ne doivent plus présenter `diu projects gitpdi`.

#### Scenario: aide Forgejo

- **GIVEN** que l'utilisateur exécute `diu projects forgejo help`
- **WHEN** l'aide est affichée
- **THEN** la commande `release <ID PROJECT>` est décrite
- **AND** `gitpdi` n'est pas affichée
