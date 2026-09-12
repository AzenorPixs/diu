# Mise à jour de la configuration Git locale des projets

## Purpose

Définir la mise à jour de la configuration Git locale des projets DIU.

## Requirements

### Requirement: mise à jour du dépôt Git local

Le système MUST exposer `rid projects git update <ID PROJECT>` et la fonction
`git_update()` en mode local.

La fonction DOIT gérer `LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et
`GIT_USER_EMAIL` dans `project.env`.

#### Scenario: mise à jour ciblée de Git local

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `rid projects git update <ID PROJECT>`
- ALORS les valeurs Git local existantes sont proposées
- ET seules les variables Git local sont remplacées
- ET les variables générales et distantes sont conservées

#### Scenario: configuration générale absente

- ÉTANT DONNÉ que la configuration générale du projet est absente ou
  incomplète
- QUAND une fonction appelle `git_update <ID PROJECT>`
- ALORS `update_projects <ID PROJECT>` complète d'abord les variables
  générales
- ET la mise à jour Git local est ensuite réalisée

### Requirement: compatibilité des appels existants

Les modes historiques nécessaires aux opérations de clonage et de configuration
GitLab MUST rester disponibles, sans supprimer les mises à jour distantes
déjà prises en charge par leurs fonctions dédiées.

#### Scenario: appel historique avec mode explicite

- ÉTANT DONNÉ qu'une opération interne appelle `git_update` avec un mode
  historique reconnu
- QUAND cette opération s'exécute
- ALORS son comportement de configuration complémentaire est conservé
- ET `PROJECT_DEBIAN_PACKAGE` n'est pas perdu lors de l'écriture
