# Publication Forgejo unifiée des projets

## Purpose

Remplacer la publication historique `gitpdi` par une release Forgejo capable
de publier les artefacts activés d'un projet DIU.

## Requirements

### Requirement: commande et fonction de release

Le système MUST exposer la commande
`rid projects forgejo release <ID PROJECT>` et la fonction
`projects_forgejo_release <ID PROJECT>`.

La fonction historique `git_push_docker_image` MUST être supprimée ou ne plus
être exposée. La commande `rid projects gitpdi <ID PROJECT>` MUST être
rejetée comme indisponible.

#### Scenario: dispatch de la nouvelle commande

- ÉTANT DONNÉ un projet identifié par `diu`
- QUAND l'utilisateur exécute `rid projects forgejo release diu`
- ALORS le dispatch appelle `projects_forgejo_release diu`
- ET aucun dispatch `gitpdi` n'est utilisé

#### Scenario: ancienne commande supprimée

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects gitpdi diu`
- QUAND le dispatch traite la commande
- ALORS aucune publication n'est exécutée
- ET la commande est rejetée comme indisponible

### Requirement: complétion de la configuration

La fonction MUST charger project.env, compléter séparément les blocs général et Forgejo qui le nécessitent, puis recharger et revérifier la configuration avant publication.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: configuration générale incomplète

- ÉTANT DONNÉ que `project.env` ne contient pas une variable générale requise
- QUAND la release est demandée
- ALORS `update_projects <ID PROJECT>` est appelée
- ET la publication attend la configuration complète

#### Scenario: configuration Forgejo incomplète

- ÉTANT DONNÉ que les variables Forgejo requises ne sont pas complètes
- QUAND la release est demandée
- ALORS `forgejo_update <ID PROJECT>` est appelée
- ET la publication attend la configuration complète

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

- ÉTANT DONNÉ que `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`
- ET que `${PROJECT_ID}:latest` existe localement
- QUAND la release est exécutée
- ALORS l'image est taguée pour Forgejo avec sa version et `latest`
- ET les deux tags sont poussés vers le dépôt Forgejo configuré

#### Scenario: image Docker absente

- ÉTANT DONNÉ que `PROJECT_DOCKERED` vaut `Yes`, `YES` ou `1`
- ET que `${PROJECT_ID}:latest` n'existe pas
- QUAND la release est exécutée
- ALORS une erreur explicite est affichée
- ET aucun push Docker n'est effectué

### Requirement: publication Debian conditionnelle

La publication Debian MUST être conditionnée à PROJECT_DEBIAN_PACKAGE. Lorsqu’elle est activée, la fonction MUST valider l’unique paquet du projet et refuser les cas invalides décrits ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: paquet unique

- ÉTANT DONNÉ que `PROJECT_DEBIAN_PACKAGE` vaut `Yes`, `YES` ou `1`
- ET que `dist/` contient exactement un paquet `.deb` du projet
- QUAND la release est exécutée
- ALORS le paquet est validé puis publié vers Forgejo

#### Scenario: répertoire dist absent

- ÉTANT DONNÉ que le paquet Debian est activé
- ET que `dist/` est absent
- QUAND la release est exécutée
- ALORS une erreur explicite est affichée
- ET aucune publication Debian n'est tentée

#### Scenario: plusieurs paquets

- ÉTANT DONNÉ que le paquet Debian est activé
- ET que `dist/` contient plusieurs paquets `.deb` du projet
- QUAND la release est exécutée
- ALORS une erreur liste les paquets trouvés
- ET aucune publication Debian n'est tentée

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

- ÉTANT DONNÉ que `PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` ne sont pas
  activés
- QUAND une release Forgejo est demandée
- ALORS la commande échoue explicitement
- ET aucune publication n'est exécutée

### Requirement: aides CLI

`rid projects help` MUST présenter la sous-commande `forgejo` et sa release.
`rid projects forgejo help` MUST présenter
`rid projects forgejo release <ID PROJECT>` et sa description.
Les aides ne doivent plus présenter `rid projects gitpdi`.

#### Scenario: aide Forgejo

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects forgejo help`
- QUAND l'aide est affichée
- ALORS la commande `release <ID PROJECT>` est décrite
- ET `gitpdi` n'est pas affichée
