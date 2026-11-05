## Purpose

Permettre de créer un projet DIU initialisé puis de fusionner de façon sûre le
contenu de sa branche Forgejo distante, sans importer de données Git.

## ADDED Requirements

### Requirement: Commande de clonage Forgejo d'un projet

DIU MUST accepter `diu projects forgejo clone <ID PROJECT>` et préparer le
projet avec le même comportement que `diu projects create <ID PROJECT>`. Après
cette préparation, DIU MUST demander la configuration Forgejo du projet avant
de tenter le clonage. La commande MUST refuser un identifiant absent et MUST
échouer avec un code non nul si la préparation du projet ou sa configuration
Forgejo échoue.

#### Scenario: Création puis clonage Forgejo valide

- **WHEN** l'utilisateur exécute `diu projects forgejo clone projet` avec une
  configuration Forgejo valide
- **THEN** DIU crée et initialise le projet `projet` depuis le template
- **AND THEN** DIU demande les variables Forgejo du projet
- **AND THEN** DIU fusionne le contenu du dépôt Forgejo configuré dans le
  projet

#### Scenario: Identifiant absent

- **WHEN** l'utilisateur exécute `diu projects forgejo clone` sans
  identifiant
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun projet n'est créé

### Requirement: Fusion prioritaire du contenu Forgejo

Après un clonage distant réussi, DIU MUST remplacer les fichiers locaux dont
le chemin existe aussi dans le dépôt distant. DIU MUST conserver les fichiers
locaux issus du template qui sont absents du dépôt distant. La fusion MUST
inclure les fichiers cachés ordinaires et MUST s'effectuer sans confirmation
supplémentaire.

#### Scenario: Fichiers concurrents et fichier template conservé

- **WHEN** le projet local contient un fichier créé par le template et un
  fichier également présent dans le dépôt distant
- **THEN** la version distante du fichier concurrent est présente après la
  fusion
- **AND THEN** le fichier du template absent du dépôt distant est conservé

#### Scenario: Fichier caché ordinaire du dépôt distant

- **WHEN** le dépôt distant contient un fichier caché ordinaire
- **THEN** ce fichier caché est présent dans le projet après la fusion

### Requirement: Exclusion des données Git distantes

DIU MUST NOT copier dans le projet un répertoire `.git`, ses sous-répertoires
ou toute autre métadonnée interne Git provenant du dépôt distant. Le projet
résultant MUST contenir uniquement la copie de travail fusionnée et les
fichiers locaux conservés.

#### Scenario: Dépôt distant cloné avec métadonnées Git

- **WHEN** DIU clone un dépôt Forgejo distant dans un emplacement temporaire
- **THEN** le projet final ne contient aucun répertoire `.git` provenant de ce
  clonage

### Requirement: Préservation du projet lors d'un échec de clonage ou de fusion

DIU MUST obtenir et vérifier la copie temporaire du dépôt distant avant de
modifier les fichiers du projet. En cas d'échec de clonage ou de fusion, DIU
MUST supprimer les artefacts temporaires, retourner un code non nul et
conserver le projet initialisé dans un état cohérent.

#### Scenario: Échec du clonage distant

- **WHEN** le clonage Forgejo échoue après la création et la configuration du
  projet
- **THEN** aucun contenu partiellement cloné n'est fusionné dans le projet
- **AND THEN** les fichiers du template déjà créés restent cohérents
