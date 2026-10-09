## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.3` et l'ordre des rubriques du scénario « Rubriques documentaires conservées ». Pour template, le titre SHALL être `DEVOPS.md — Template`. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document, avec Chromium puis Firefox.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.3 et les rubriques existantes conservent leur ordre
- **AND THEN** une seule section Tests navigateurs extérieurs en mode headless termine le document

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Docker, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire

### Requirement: Écriture limitée et robuste

DIU SHALL écrire seulement DEVOPS.md, ses temporaires régénérables et le manifeste Python conditionnel dans le projet ciblé, en UTF-8/LF. Tout échec de préparation ou d'écriture SHALL retourner un code non nul et préserver l'existant. L'actualisation SHALL conserver droits et propriétaire ; la synchronisation et la préparation des créations SHALL rester inchangées. Les créations SHALL finir par la génération DevOps. À observations identiques, le contenu SHALL être identique hors horodatage.

#### Scenario: Échec de remplacement

- **WHEN** la préparation ou le remplacement du document échoue
- **THEN** le document existant est conservé et l'échec est signalé

#### Scenario: Réexécution stable

- **WHEN** deux exécutions observent le même environnement
- **THEN** le contenu documentaire produit est identique hors horodatage du début du relevé
- **AND THEN** chaque document indique le début de son propre relevé

## ADDED Requirements

### Requirement: Horodatage UTC du début du relevé

Chaque rendu SHALL capturer une seule fois, avant les sondes, le début du relevé avec date -u au format YYYY-MM-DDTHH:MM:SSZ. Cette collecte SHALL être bornée à 15 secondes. Une commande absente, échouée, expirée ou une sortie mal formée SHALL faire échouer la préparation, sans publier de sortie brute ni remplacer DEVOPS.md. L'horodatage SHALL NOT prétendre certifier la synchronisation de l'horloge ni une observation simultanée.

#### Scenario: Horloge contrôlée

- **WHEN** la collecte UTC retourne un instant valide
- **THEN** le document indique cet instant comme début du relevé, avant ses rubriques
- **AND THEN** une seule capture est effectuée avant les autres sondes

#### Scenario: Horodatage indisponible

- **WHEN** la commande manque, échoue, dépasse la borne ou retourne une sortie mal formée
- **THEN** la génération échoue avec un diagnostic fixe sans exposer la sortie brute
- **AND THEN** le document existant, ses droits et son propriétaire restent inchangés

### Requirement: Contexte d'exécution fourni par DIU

Le document SHALL indiquer la classification actuelle SYSTEM_DEBIAN_ENVIRONNEMENT parmi DOCKER, LXC, PHYSICAL, PROXMOX, VM ou UNSET. Une valeur absente, vide ou hors de ce vocabulaire SHALL être rendue comme UNSET, sans exposer la valeur brute ni exécuter son contenu. Cette génération SHALL NOT relancer la détection, déduire un contexte de PROJECT_DOCKERED, créer une configuration ou supposer un environnement physique.

#### Scenario: Classification reconnue

- **WHEN** SYSTEM_DEBIAN_ENVIRONNEMENT porte une classification reconnue
- **THEN** le document indique exactement cette classification fournie par DIU

#### Scenario: Classification inconnue

- **WHEN** la variable est absente, vide ou contient une valeur non reconnue
- **THEN** le document indique UNSET sans reproduire ni exécuter cette valeur

### Requirement: Provenance et portée informative du relevé

Avant la première rubrique, le document SHALL identifier DIU comme générateur et distinguer les sondes système de celles des outils et dépendances du compte DevOps. La légende SHALL préciser que les dépendances attendues viennent de [project].dependencies dans pyproject.toml et que l'inventaire ne vaut ni qualification fonctionnelle ni preuve de réussite des tests. Les parcours individuel, groupé et de création SHALL produire cette même présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé
