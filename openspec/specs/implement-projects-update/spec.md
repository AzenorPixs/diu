# Mise à jour de la configuration générale des projets

## Purpose

Définir la mise à jour des variables générales d'un projet DIU.

## Requirements

### Requirement: mise à jour des variables générales d'un projet

DIU MUST exposer `rid projects update <ID PROJECT>` via `update_projects()`,
sans changer l'identifiant demandé. La fonction MUST gérer
`PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`,
`PROJECT_DOCKERED`, `PROJECT_DEBIAN_PACKAGE` et `PROJECT_ORCHESTRATED_CODING`
dans `<projet>/project.env`. Elle MUST proposer les valeurs existantes et
préserver les variables Git locales, distantes, les lignes non ciblées et
les droits prévus de configuration.

#### Scenario: création de la configuration générale

- **GIVEN** un répertoire de projet existant sans `project.env`
- **WHEN** l'utilisateur configure les variables générales
- **THEN** `PROJECT_ID` vaut l'identifiant demandé, `PROJECT_TYPE` vaut `BASH` par défaut
- **AND** `PROJECT_DOCKERED`, `PROJECT_DEBIAN_PACKAGE` et `PROJECT_ORCHESTRATED_CODING` sont proposés à `No`
- **AND** `PROJECT_NAME` est demandé et ne peut pas rester vide

#### Scenario: mise à jour ciblée du projet

- **GIVEN** une configuration existante avec `PROJECT_ORCHESTRATED_CODING=Yes`
- **WHEN** l'utilisateur conserve les valeurs proposées
- **THEN** la valeur reste `Yes` et les autres variables générales sont conservées
- **AND** les lignes hors des variables générales sont préservées

### Requirement: aide des commandes projects

`rid projects help` MUST afficher toutes les sous-commandes de premier niveau
de `projects` avec leur description, notamment `update` et `git`.

#### Scenario: aide générale des projets

- ÉTANT DONNÉ que l'utilisateur exécute `rid projects help`
- QUAND l'aide est affichée
- ALORS la commande `rid projects update <ID PROJECT>` est décrite
- ET la commande `rid projects git update <ID PROJECT>` est décrite
- ET les commandes projects existantes restent listées

### Requirement: Déclaration du mode de développement du projet

DIU MUST interpréter `PROJECT_ORCHESTRATED_CODING=No` comme un développement
autonome et `Yes` comme un agent de codage piloté par un orchestrateur.
`create_project`, `update_projects` et `git_update_legacy` MUST demander cette
variable, proposer la valeur enregistrée ou `No` si elle est absente, et
persister exclusivement `Yes` ou `No`. La variable MUST NOT activer un service.

#### Scenario: Création autonome par défaut

- **WHEN** un nouveau projet est créé et l'utilisateur accepte le défaut
- **THEN** son `project.env` contient `PROJECT_ORCHESTRATED_CODING=No`
- **AND** la copie du modèle ne remplace pas cette configuration

#### Scenario: Choix du mode piloté

- **WHEN** l'utilisateur répond `Yes` à la question du mode de développement
- **THEN** `PROJECT_ORCHESTRATED_CODING=Yes` est enregistré

### Requirement: Validation interactive du mode de développement

Le questionnaire partagé MUST conserver le défaut proposé pour une entrée
vide, redemander après toute autre saisie que `Yes` ou `No` et signaler
l'erreur sans persister cette saisie. Une fin d'entrée MUST échouer avant
persistance et sans message de réussite de la configuration du projet.

#### Scenario: Saisie invalide puis correction

- **WHEN** l'utilisateur répond une valeur différente de `Yes` ou `No`
- **THEN** DIU redemande la valeur sans persister cette saisie
- **AND** une réponse ultérieure valide est enregistrée

#### Scenario: Fin d'entrée avant choix

- **WHEN** l'entrée se ferme pendant la question du mode de développement
- **THEN** DIU retourne un code non nul et ne remplace pas `project.env`

### Requirement: Lecture rétrocompatible et isolée du mode de développement

DIU MUST fournir `project_orchestrated_coding_get <fichier>` indépendamment
du shell et des projets précédents. Il MUST retourner `No` si le fichier ou
la variable est absent, ou si la valeur littérale est vide, sans écriture.
La variable MUST rester facultative pour les projets historiques et MUST NOT
déclencher une migration globale ou un nouveau critère de sélection des projets.

#### Scenario: Projet historique après un projet piloté

- **GIVEN** le shell contient une valeur `Yes` provenant d'un autre projet
- **WHEN** le lecteur consulte un fichier sans la variable
- **THEN** il retourne `No` sans modifier ce fichier

### Requirement: Lecture littérale contrôlée du mode de développement

Le lecteur MUST reconnaître `Yes` et `No`, avec guillemets simples ou doubles,
espaces et préfixe `export` facultatifs. Il MUST NOT exécuter le fichier ni
évaluer ses expressions shell. Une valeur non vide invalide ou un fichier
présent illisible ou non ordinaire MUST produire un code non nul et un
diagnostic sans reproduire son contenu.

#### Scenario: Lecture littérale sans exécution

- **GIVEN** un fichier contenant la valeur littérale `Yes` et une autre ligne de commande shell
- **WHEN** le lecteur est appelé
- **THEN** il retourne `Yes` sans exécuter cette commande

#### Scenario: Configuration invalide

- **WHEN** le fichier contient une valeur non vide différente de `Yes` ou `No`
- **THEN** le lecteur échoue sans afficher le contenu invalide ni persister de correction

### Requirement: Conservation du mode lors des réécritures historiques

`git_update_legacy` MUST inclure le mode choisi dans son résumé et dans la
réécriture de `project.env`, y compris lorsqu'une configuration existante
contient `Yes`. Le point d'entrée public Git local MUST conserver son
questionnement limité aux variables Git. Le clonage local MUST conserver
la valeur source, ou son absence historique, sans question supplémentaire.

#### Scenario: Réécriture historique d'un projet piloté

- **GIVEN** une configuration valide contenant `PROJECT_ORCHESTRATED_CODING=Yes`
- **WHEN** le parcours historique réenregistre la configuration en conservant les défauts
- **THEN** le résumé et le fichier final conservent `Yes`

#### Scenario: Configuration Git locale seule

- **WHEN** l'utilisateur met à jour les variables Git locales
- **THEN** la nouvelle variable reste inchangée et aucune question de mode n'est posée

#### Scenario: Clonage local

- **WHEN** un projet est cloné localement
- **THEN** la destination conserve la valeur de mode source ou son absence

### Requirement: Copie conditionnelle du protocole de codage piloté

Pour la création depuis le modèle et la synchronisation, DIU MUST copier le
document racine ORCHESTRATED_CODING.md si et seulement si
project_orchestrated_coding_get retourne Yes depuis le project.env destination.
La copie MUST suivre la personnalisation Markdown et les règles de propriété
existantes.

#### Scenario: Projet piloté

- **WHEN** le mode destination vaut Yes et le document modèle est disponible
- **THEN** la création ou synchronisation copie le document, avec remplacement de Template et template
- **AND** une version destination gérée est écrasée à la synchronisation

#### Scenario: Configuration du modèle ou du shell différente

- **WHEN** le modèle ou le shell indique Yes et le projet destination indique No ou omet la variable
- **THEN** le document n'est pas copié et la configuration destination est préservée

### Requirement: Préservation du protocole en mode autonome

Pour No, une variable absente ou vide, DIU MUST NOT copier, créer, supprimer,
personnaliser ou changer les attributs d'un document destination existant,
et MUST NOT exiger le document source lors de la création ou synchronisation.

#### Scenario: Projet autonome ou historique

- **WHEN** le mode destination vaut No ou est absent ou vide
- **THEN** le document modèle n'est pas copié et une destination existante reste intacte
- **AND** une source absente n'empêche pas l'opération

### Requirement: Échec avant copie du modèle

Une valeur de mode invalide MUST provoquer un échec avant toute copie du
modèle. Pour Yes, une source ORCHESTRATED_CODING.md absente ou non régulière
MUST provoquer le même échec. La création MAY conserver le répertoire et la
configuration déjà préparés ; elle MUST NOT annoncer un succès.

#### Scenario: Mode invalide ou source requise indisponible

- **WHEN** le mode est invalide ou vaut Yes avec un document modèle absent ou non régulier
- **THEN** l'opération échoue avant toute copie du modèle et sans message de succès

### Requirement: Décision du mode pour chaque projet synchronisé

La synchronisation groupée MUST décider de la copie du protocole séparément
pour chaque projet. Elle MUST conserver la poursuite après échec et son code
de retour non nul en présence d'un projet en échec.

#### Scenario: Synchronisation groupée de modes différents

- **WHEN** plusieurs projets ont des modes distincts, dont un projet piloté en échec
- **THEN** chaque projet reçoit uniquement les copies correspondant à son mode
- **AND** les projets suivants sont traités et le résultat global est non nul
