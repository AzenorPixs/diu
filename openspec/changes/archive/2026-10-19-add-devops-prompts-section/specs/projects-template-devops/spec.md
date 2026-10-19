## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.6` et l'ordre des rubriques du scénario « Rubriques documentaires conservées ». Pour template, le titre SHALL être `DEVOPS.md — Template`. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document, avec Chromium puis Firefox.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.6 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Docker, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire

## ADDED Requirements

### Requirement: Emplacements des prompts communs

Chaque génération individuelle, groupée ou finale de création SHALL produire
une seule rubrique de niveau 1 « Prompts », après le gestionnaire de paquets
Python et avant les tests navigateurs. Ses puces « Dossier des prompts » et
« Index des prompts » SHALL indiquer /home/${ENV_DEVOPS_USER}/datas/prompts
et son fichier INDEX.md, avec la valeur réelle du compte validé, indépendamment
de DEVOPS_PROJECTS_ROOT.

#### Scenario: Compte DevOps configuré

- **WHEN** ENV_DEVOPS_USER vaut devops
- **THEN** les deux chemins sont /home/devops/datas/prompts et /home/devops/datas/prompts/INDEX.md

#### Scenario: Autre compte et racine de projets distincte

- **WHEN** ENV_DEVOPS_USER désigne un autre compte valide et DEVOPS_PROJECTS_ROOT désigne une racine de projets distincte
- **THEN** les deux chemins utilisent /home suivi du compte configuré, puis datas/prompts et datas/prompts/INDEX.md
- **AND THEN** aucun chemin de prompts n'est dérivé de DEVOPS_PROJECTS_ROOT ni du nom du projet

### Requirement: Références Prompts passives

La rubrique Prompts SHALL NOT lire, sonder, créer ni modifier le dossier des
prompts ou son index. Leur absence SHALL NOT empêcher la génération.

#### Scenario: Ressources Prompts absentes

- **WHEN** le dossier prompts et son INDEX.md sont absents
- **THEN** la rubrique affiche les emplacements attendus sans erreur liée à cette absence
- **AND THEN** aucun dossier ni fichier de prompts n'est créé
