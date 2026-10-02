# projects-sync Specification

## Purpose
Permettre de remettre à jour de manière déterministe les ressources communes
d'un projet géré depuis le modèle local de l'utilisateur DevOps.

## Requirements

### Requirement: Commande de synchronisation d'un projet

DIU MUST accepter `rid projects sync <ID PROJECT>` pour synchroniser le
projet désigné depuis `/home/${DEVOPS_USER}/datas/template`. La commande MUST
refuser un identifiant absent, un projet destination absent, un fichier
`project.env` absent ou une configuration dont `PROJECT_ID` ne correspond pas
à l'identifiant demandé. Elle MUST obtenir `PROJECT_NAME` depuis cette
configuration et échouer si cette valeur est absente ou vide, avant toute
copie.

#### Scenario: Synchronisation d'un projet configuré

- **WHEN** l'utilisateur exécute `rid projects sync mon-projet` pour un
  projet configuré valide
- **THEN** DIU synchronise les ressources gérées du modèle dans
  `mon-projet`

#### Scenario: Projet non configurable

- **WHEN** l'utilisateur exécute la commande pour un projet absent ou dont
  `project.env` est invalide
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun élément de synchronisation n'est copié

### Requirement: Source de synchronisation contrôlée

Avant toute copie, DIU MUST vérifier l'existence du répertoire modèle
`/home/${DEVOPS_USER}/datas/template` et de chacun de ses éléments gérés : les
fichiers `AGENTS.md`, `.gitignore` et les répertoires
`.opencode/commands`, `.opencode/config`, `.opencode/skills` et `PROMPTS`.
Une source indisponible ou de type incorrect MUST faire échouer la commande
avec un code non nul avant toute copie. DIU MUST NOT exiger la présence de
`DEVOPS.md` dans le modèle, pour la synchronisation unitaire ou groupée.

#### Scenario: Répertoire modèle indisponible

- **WHEN** `/home/${DEVOPS_USER}/datas/template` n'est pas disponible
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun fichier ni répertoire de synchronisation n'est copié

#### Scenario: Élément géré manquant du modèle

- **WHEN** le modèle ne contient pas l'un de ses fichiers ou répertoires
  gérés attendus
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun élément de synchronisation n'est copié

#### Scenario: Modèle sans document d'environnement

- **WHEN** le modèle contient tous ses éléments gérés mais aucun `DEVOPS.md`
- **THEN** la synchronisation unitaire ou groupée accepte ce modèle

### Requirement: Copie ciblée et autoritaire du modèle

Une synchronisation réussie MUST copier, avec leur contenu récursif pour les
répertoires, uniquement `AGENTS.md`, `.gitignore`,
`.opencode/commands`, `.opencode/config`, `.opencode/skills` et `PROMPTS`.
Pour chaque élément copié dont une destination existe déjà, le contenu du
modèle MUST l'écraser. Les éléments destination hors de cette sélection MUST
être préservés. Pour la synchronisation unitaire ou groupée, DIU MUST NOT
copier, créer, personnaliser, supprimer ou changer les droits ou le
propriétaire du fichier `DEVOPS.md` à la racine du projet destination.

#### Scenario: Écrasement d'un élément géré

- **WHEN** un fichier ou un contenu de répertoire géré existe déjà dans le
  projet destination
- **THEN** sa version issue du modèle devient la version présente après la
  synchronisation

#### Scenario: Préservation d'un élément non géré

- **WHEN** le projet destination contient un élément qui ne fait pas partie
  de la sélection de synchronisation
- **THEN** cet élément est conservé après la synchronisation

#### Scenario: Préservation du document d'environnement existant

- **WHEN** le projet destination possède un `DEVOPS.md` et que la
  synchronisation unitaire ou groupée réussit
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Absence de création du document d'environnement

- **WHEN** le projet destination ne possède aucun `DEVOPS.md`, même si le
  modèle en contient un, et que la synchronisation unitaire ou groupée réussit
- **THEN** aucun `DEVOPS.md` n'est créé à la racine du projet destination

### Requirement: Personnalisation des Markdown synchronisés

Pour chaque fichier `*.md` provenant des éléments synchronisés, DIU MUST
remplacer toutes les occurrences de `Template` par `PROJECT_NAME` et toutes
les occurrences de `template` par `PROJECT_ID`. DIU MUST NOT appliquer ces
transformations aux fichiers Markdown qui existaient déjà dans le projet et
ne proviennent pas de la synchronisation.

#### Scenario: Personnalisation d'un Markdown du modèle

- **WHEN** un fichier Markdown copié depuis le modèle contient `Template` et
  `template`
- **THEN** le fichier destination contient respectivement `PROJECT_NAME` et
  `PROJECT_ID`

#### Scenario: Markdown destination non géré

- **WHEN** un fichier Markdown existant du projet n'appartient pas aux
  éléments synchronisés
- **THEN** son contenu n'est pas transformé par la commande
