## MODIFIED Requirements

### Requirement: Commande de génération du modèle DevOps

DIU SHALL fournir `projects_template_devops`, appelée par la commande
`rid projects template devops <ID PROJECT>`, avec un identifiant obligatoire. La CLI SHALL exiger le sélecteur devops avant l'identifiant et SHALL rejeter
les anciens ordres lorsqu'ils ne correspondent pas déjà à une commande valide. La fonction SHALL générer ou actualiser
`${ENV_DEVOPS_PROJECTS_ROOT}/<ID PROJECT>/DEVOPS.md`.

#### Scenario: Dossier absent

- **WHEN** le dossier du projet n'existe pas
- **THEN** la fonction rend la main avec un code de succès et un message indiquant ce dossier absent
- **AND THEN** aucun fichier ni dossier n'est créé

#### Scenario: Argument ou sous-commande inconnu

- **WHEN** la commande contient une sous-commande inconnue ou un argument supplémentaire
- **THEN** DIU échoue avec un diagnostic contextuel sans générer de document

#### Scenario: Projet sélectionné

- **WHEN** l'utilisateur exécute rid projects template devops application
- **THEN** seul le DEVOPS.md du projet application est généré ou actualisé
- **AND THEN** project.env et pyproject.toml sont ceux de ce projet

#### Scenario: Ancienne syntaxe ou identifiant invalide

- **WHEN** l'identifiant manque, contient un chemin ou la commande utilise template application devops
- **THEN** la commande échoue avant toute écriture avec la nouvelle utilisation

#### Scenario: Projets nommés comme les sélecteurs

- **WHEN** la commande utilise template devops devops ou template devops openspec
- **THEN** seule la génération DevOps du projet désigné est appelée

### Requirement: Validation et racine du projet ciblé

La racine SHALL utiliser
ENV_DEVOPS_PROJECTS_ROOT lorsqu'elle est définie, sinon /home/${ENV_DEVOPS_USER}/datas. La fonction SHALL valider le nom d'utilisateur et l'identifiant de projet,
SHALL refuser les chemins, les identifiants . et .. et les liens symboliques
du dossier cible, et SHALL NOT créer le dossier du projet. L'ancienne syntaxe
sans identifiant SHALL être rejetée avec la nouvelle utilisation.

#### Scenario: Application des règles de validation et racine du projet ciblé

- **WHEN** la génération DevOps traite ce contexte
- **THEN** les règles de cette exigence sont appliquées

### Requirement: Génération DevOps de tous les projets configurés

DIU SHALL exposer rid projects template devops all et projects_template_devops_all. La fonction SHALL utiliser ENV_DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas,
et parcourir uniquement ses dossiers directs, y compris les dossiers cachés. Elle SHALL sélectionner les project.env ordinaires dont les affectations
littérales PROJECT_ID, PROJECT_NAME, PROJECT_TYPE, PROJECT_DOCKERED et
PROJECT_DEBIAN_PACKAGE sont toutes non vides.

#### Scenario: Projets complets

- **WHEN** plusieurs dossiers dont template contiennent les cinq variables renseignées et un PROJECT_ID conforme
- **THEN** projects_template_devops est appelée une fois pour chaque dossier éligible
- **AND THEN** les configurations restent isolées entre projets

#### Scenario: Projet incomplet ou identifiant discordant

- **WHEN** une variable requise manque ou est vide, ou PROJECT_ID diffère du dossier
- **THEN** le projet est ignoré avec un message et aucun de ses fichiers n'est généré

#### Scenario: Configuration contenant une commande

- **WHEN** une affectation du project.env contient une expression de commande
- **THEN** aucune commande n'est exécutée et une configuration inéligible ne déclenche aucune génération

#### Scenario: Dossier nommé all

- **WHEN** le dossier all remplit les critères
- **THEN** la boucle appelle directement projects_template_devops avec all sans relancer le traitement groupé

#### Scenario: Nouvelle syntaxe groupée

- **WHEN** l'utilisateur exécute rid projects template devops all
- **THEN** la fonction groupée est appelée une seule fois

#### Scenario: Ancienne syntaxe groupée

- **WHEN** l'utilisateur exécute rid projects template all devops
- **THEN** la CLI rend un code non nul sans génération

### Requirement: Emplacements des prompts communs

Chaque génération individuelle, groupée ou finale de création SHALL produire
une seule rubrique de niveau 1 « Prompts », après le gestionnaire de paquets
Python et avant les tests navigateurs. Ses puces « Dossier des prompts » et
« Index des prompts » SHALL indiquer /home/${ENV_DEVOPS_USER}/datas/prompts
et son fichier INDEX.md, avec la valeur réelle du compte validé, indépendamment
de ENV_DEVOPS_PROJECTS_ROOT.

#### Scenario: Compte DevOps configuré

- **WHEN** ENV_DEVOPS_USER vaut devops
- **THEN** les deux chemins sont /home/devops/datas/prompts et /home/devops/datas/prompts/INDEX.md

#### Scenario: Autre compte et racine de projets distincte

- **WHEN** ENV_DEVOPS_USER désigne un autre compte valide et ENV_DEVOPS_PROJECTS_ROOT désigne une racine de projets distincte
- **THEN** les deux chemins utilisent /home suivi du compte configuré, puis datas/prompts et datas/prompts/INDEX.md
- **AND THEN** aucun chemin de prompts n'est dérivé de ENV_DEVOPS_PROJECTS_ROOT ni du nom du projet
