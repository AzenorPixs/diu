# Mise à jour de la configuration Git locale des projets

## Purpose

Définir la mise à jour de la configuration Git locale des projets DIU.

## Requirements

### Requirement: mise à jour des variables Git locales

Le système MUST exposer `diu projects git update <ID PROJECT>` et la fonction
`git_update()` en mode local.

La fonction DOIT gérer `LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et
`GIT_USER_EMAIL` dans `project.env`.

#### Scenario: mise à jour ciblée de Git local

- ÉTANT DONNÉ que `project.env` contient une configuration générale conforme
- QUAND l'utilisateur exécute `diu projects git update <ID PROJECT>`
- ALORS les valeurs Git local existantes sont proposées
- ET seules les variables Git local sont remplacées
- ET les variables générales et distantes sont conservées

#### Scenario: indépendance de la configuration générale

- QUAND une fonction appelle `git_update <ID PROJECT>`
- ALORS seules `LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et `GIT_USER_EMAIL`
  sont demandées ou mises à jour
- ET `update_projects <ID PROJECT>` n'est pas appelée
- ET les variables générales et distantes déjà présentes sont conservées

#### Scenario: fichier de projet absent

- ÉTANT DONNÉ que le répertoire du projet existe mais que `project.env` est
  absent
- QUAND l'utilisateur exécute `diu projects git update <ID PROJECT>`
- ALORS `project.env` est créé avec les seules variables Git locales
- ET `update_projects <ID PROJECT>` n'est pas appelée

### Requirement: signature limitée

La fonction publique `git_update()` MUST accepter uniquement `<ID PROJECT>`.
Les parcours de clonage et les configurations distantes utilisent leurs
fonctions dédiées et ne passent pas par `git_update()`.

#### Scenario: appel public

- QUAND l'utilisateur exécute `diu projects git update <ID PROJECT>`
- ALORS `git_update <ID PROJECT>` met à jour uniquement les variables Git
  locales

### Requirement: Enregistrement système après mise à jour Git locale

Après l'enregistrement réussi des variables locales, `git_update` MUST
enregistrer l'exception système exacte du chemin canonique du projet selon
les mêmes règles d'idempotence et d'erreur que `git_init`. Le questionnaire,
les variables distantes et générales et la signature publique MUST rester
inchangés. La fonction interne `git_update_local` MUST rester limitée aux
variables locales et MUST NOT écrire `safe.directory`.

#### Scenario: Mise à jour avec exception absente

- **WHEN** le questionnaire Git local se termine et les variables sont enregistrées
- **THEN** l'exception exacte est enregistrée en portée système
- **AND** une nouvelle exécution n'ajoute pas de doublon

#### Scenario: Échec du questionnaire ou de l'enregistrement local

- **WHEN** la mise à jour locale échoue
- **THEN** aucune écriture safe.directory n'est tentée

#### Scenario: Échec de l'enregistrement système

- **GIVEN** les variables locales enregistrées et l'ajout système impossible
- **WHEN** git_update tente d'enregistrer l'exception
- **THEN** la commande retourne un échec explicite
- **AND** les variables déjà enregistrées sont conservées
