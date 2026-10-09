## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.4` et l'ordre des rubriques du scénario « Rubriques documentaires conservées ». Pour template, le titre SHALL être `DEVOPS.md — Template`. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document, avec Chromium puis Firefox.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.4 et les rubriques existantes conservent leur ordre
- **AND THEN** une seule section Tests navigateurs extérieurs en mode headless termine le document

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Docker, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire

### Requirement: Python et dépendances déclarées

La rubrique Python SHALL indiquer venv et ensurepip en troisième ligne ; la rubrique pip SHALL conserver sa version et son chemin DevOps. Les dépendances SHALL provenir uniquement de [project].dependencies et être recherchées dans les venv du projet avant le repli Python DevOps. Le document SHALL conserver les contraintes et signaler manifeste absent, invalide, dynamique ou paquet introuvable/non vérifiable, sans inventer ni installer de dépendance.

#### Scenario: Manifeste absent

- **WHEN** pyproject.toml est absent
- **THEN** le document indique cette absence sans ajouter implicitement psycopg

#### Scenario: Dépendances présentes

- **WHEN** pyproject.toml déclare des dépendances
- **THEN** chaque dépendance déclarée est documentée avec sa contrainte et sa version installée ou son indisponibilité

### Requirement: Provenance et portée informative du relevé

Avant la première rubrique, le document SHALL identifier DIU et distinguer sondes système, outils DevOps et dépendances du projet. La légende SHALL expliquer priorité des venv, repli DevOps, source [project].dependencies et absence de qualification fonctionnelle ou de preuve de tests. Les parcours individuel, groupé et de création SHALL conserver cette présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé

## ADDED Requirements

### Requirement: Découverte des environnements Python du projet

DIU SHALL rechercher les dossiers ordinaires portant un pyvenv.cfg ordinaire dans le projet, sans suivre les liens de dossiers ni entrer dans les venv, caches, .git, node_modules, sorties, journaux et ressources d'outillage. Les interpréteurs bin/python3 puis bin/python SHALL être retenus sans résoudre leur lien vers le Python de base. La priorité SHALL être .venv, venv, env à la racine, puis les autres chemins relatifs triés.

#### Scenario: Environnements multiples et imbriqués

- **WHEN** plusieurs venv existent à la racine ou sous un dossier du projet
- **THEN** ils sont découverts et sondés dans la priorité déclarée, sans dépendre de l'ordre du système de fichiers

#### Scenario: Ressources ignorées et liens

- **WHEN** un venv se trouve dans un cache, une sortie ou un dossier d'outillage, ou qu'un lien de dossier vise un venv extérieur
- **THEN** ce chemin n'est pas parcouru
- **AND THEN** le lien usuel bin/python3 vers un interpréteur de base reste autorisé et son chemin d'entrée est conservé

### Requirement: Sondes de venv isolées et absence vérifiée

Chaque sonde de venv SHALL s'exécuter sous le compte DevOps avec Python isolé, sans site automatique, activation shell ni import applicatif. Elle SHALL être bornée à 3 secondes, dans un budget de recherche/sondes de 12 secondes, sous la borne existante de 15 secondes. Une erreur, une recherche incomplète ou une métadonnée ambiguë SHALL NOT être publiée comme une absence certaine. Une valeur brute de sonde échouée SHALL NOT être exposée.

#### Scenario: Sonde impossible ou ambiguë

- **WHEN** un venv est incomplet, inaccessible, échoue, dépasse son délai ou fournit des métadonnées contradictoires
- **THEN** l'inventaire indique sa limite sans divulguer la sortie brute
- **AND THEN** une dépendance non observée ne devient pas « non installé » tant qu'une recherche pertinente reste non vérifiable

#### Scenario: Aucun code de paquet chargé

- **WHEN** un paquet ou un fichier .pth du venv contient du code à effet de bord
- **THEN** sa consultation par métadonnées ne charge ni ce paquet ni le fichier .pth

### Requirement: Priorité et chemins des distributions observées

Chaque dépendance observée SHALL indiquer version, interpréteur sondé, environnement et chemin d'installation issu des métadonnées. Une distribution trouvée dans un venv SHALL primer sur le repli DevOps. Le repli et les recherches incomplètes SHALL être explicites. Un inventaire multi-environnements SHALL NOT valoir validation d'un environnement Python unique. Aucun chemin de paquet SHALL être déduit de son nom.

#### Scenario: Distribution locale préférée

- **WHEN** la même distribution existe dans un venv du projet et dans le Python DevOps
- **THEN** la première distribution locale selon la priorité est affichée, avec son interpréteur et son installation observés

#### Scenario: Repli et provenance par dépendance

- **WHEN** une dépendance n'est trouvée dans aucun venv sondé et existe dans le Python DevOps
- **THEN** le document indique la version et le chemin DevOps comme repli explicite
- **AND THEN** chaque autre dépendance conserve sa propre provenance

### Requirement: Analyse sans Python DevOps

La lecture SHALL utiliser le Python DevOps disponible, sinon le Python système existant ; un analyseur sans tomllib SHALL être signalé comme non vérifiable. Avec un analyseur disponible, un venv sondable SHALL être pris en compte même sans Python DevOps. Le rôle d'analyse du Python système SHALL NOT fournir de repli de paquets système ni installer quoi que ce soit.

#### Scenario: Venv utilisable sans Python DevOps

- **WHEN** le Python DevOps est absent et un analyseur existant peut lire le manifeste
- **THEN** les distributions observées dans les venv sont documentées normalement
- **AND THEN** les paquets du Python système ne sont pas présentés comme un repli DevOps
