# projects-template-devops Specification

## Purpose
Définir la génération et l'actualisation de DEVOPS.md pour un projet ciblé,
y compris à la fin de sa création, à partir des versions vérifiées des outils
hôte et de l'environnement DevOps, des dépendances Python déclarées et du
serveur PostgreSQL configuré, avec un manifeste minimal conditionnel pour Python.

## Requirements

### Requirement: Commande de génération du modèle DevOps

DIU SHALL fournir `projects_template_devops`, appelée par la commande
`rid projects template <ID PROJECT> devops`, avec un identifiant obligatoire. La fonction SHALL
générer ou actualiser `${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>/DEVOPS.md`.
La racine SHALL utiliser DEVOPS_PROJECTS_ROOT lorsqu'elle est définie, sinon
/home/${ENV_DEVOPS_USER}/datas. La fonction SHALL valider le nom d'utilisateur
et l'identifiant de projet, SHALL refuser les chemins, les identifiants . et ..
et les liens symboliques du dossier cible, et SHALL NOT créer le dossier du projet.
L'ancienne syntaxe sans identifiant SHALL être rejetée avec la nouvelle utilisation.

#### Scenario: Dossier absent

- **WHEN** le dossier du projet n'existe pas
- **THEN** la fonction rend la main avec un code de succès et un message indiquant ce dossier absent
- **AND THEN** aucun fichier ni dossier n'est créé

#### Scenario: Argument ou sous-commande inconnu

- **WHEN** la commande contient une sous-commande inconnue ou un argument supplémentaire
- **THEN** DIU échoue avec un diagnostic contextuel sans générer de document

#### Scenario: Projet sélectionné

- **WHEN** l'utilisateur exécute rid projects template application devops
- **THEN** seul le DEVOPS.md du projet application est généré ou actualisé
- **AND THEN** project.env et pyproject.toml sont ceux de ce projet

#### Scenario: Ancienne syntaxe ou identifiant invalide

- **WHEN** l'identifiant manque ou contient un chemin
- **THEN** la commande échoue avant toute écriture avec la nouvelle utilisation

### Requirement: Structure et version documentaire

Le document SHALL conserver un titre `DEVOPS.md — <ID PROJECT>` adapté à l'identifiant, la version
documentaire `0.2`, et les rubriques Système d'exploitation, Docker,
Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL
Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source
de vérité `pyproject.toml`, Python - Gestionnaire de paquets, dans cet ordre. Pour l'identifiant template, le titre SHALL rester
`DEVOPS.md — Template`.
Chaque rubrique logicielle SHALL placer le chemin du binaire après sa version.
Le serveur PostgreSQL SHALL indiquer son adresse après sa version.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire reste 0.2 et la structure reste celle du modèle

### Requirement: Distinction entre hôte et environnement DevOps

DIU SHALL relever le système d'exploitation hôte et les versions des outils
hôte Docker, Docker-Compose, Git, OpenSSL et PostgreSQL Client. DIU SHALL
relever Go, Node, NPM, OpenCode, OpenSpec, Python et pip depuis les binaires
situés dans `/home/${ENV_DEVOPS_USER}`, sous cet utilisateur. DIU SHALL NOT
remplacer un outil DevOps manquant par un outil hôte. NPM et OpenSpec SHALL
utiliser le Node DevOps et pip SHALL utiliser le Python DevOps, sans dépendre
des shebangs des scripts. Les sondes DevOps SHALL être exécutées depuis le
domicile de cet utilisateur sans changer le répertoire de l'appelant, y
compris lorsque son répertoire courant lui est inaccessible après changement
d'utilisateur. Une sonde absente, échouée ou sans version reconnue
SHALL être indiquée explicitement, sans conserver une version ancienne.

#### Scenario: Versions hôte différentes

- **WHEN** le PATH hôte contient un Node et un Python différents de ceux du domicile DevOps
- **THEN** les rubriques DevOps indiquent les versions et chemins du domicile DevOps

#### Scenario: Outil manquant ou défaillant

- **WHEN** un outil est absent ou sa sonde échoue
- **THEN** sa rubrique indique que sa version est indisponible et le chemin attendu ou l'absence de binaire
- **AND THEN** aucune installation n'est réalisée

#### Scenario: Répertoire de l'appelant inaccessible à DevOps

- **WHEN** la génération est lancée depuis un dossier inaccessible à l'utilisateur DevOps, par exemple /root
- **THEN** les sondes, notamment go version, sont exécutées depuis son domicile accessible
- **AND THEN** la version Go disponible est relevée et le répertoire courant de l'appelant est préservé

### Requirement: Python et dépendances déclarées

La rubrique Python SHALL indiquer en troisième ligne la disponibilité de venv
et ensurepip. La rubrique dépendances SHALL utiliser uniquement
`[project].dependencies` de pyproject.toml et SHALL vérifier les versions
installées avec le Python DevOps. Elle SHALL signaler le manifeste absent,
invalide, les dépendances dynamiques ou les paquets non installés sans
inventer de dépendance. La rubrique gestionnaire de paquets SHALL vérifier
la version et le chemin du pip de cet environnement.

#### Scenario: Manifeste absent

- **WHEN** pyproject.toml est absent
- **THEN** le document indique cette absence sans ajouter implicitement psycopg

#### Scenario: Dépendances présentes

- **WHEN** pyproject.toml déclare des dépendances
- **THEN** chaque dépendance déclarée est documentée avec sa contrainte et sa version installée ou son indisponibilité

### Requirement: Vérification sûre du serveur PostgreSQL

DIU SHALL déterminer l'adresse du serveur depuis les affectations littérales
PG_HOST ou PG_SERVER et PG_PORT du project.env du projet ciblé, et vérifier sa version avec
`SHOW server_version`. Les paramètres de connexion SHALL rester locaux.
Les caractères spéciaux des valeurs citées, notamment PG_PASSWORD, SHALL
être conservés littéralement, sans expansion de variable ou de commande.
Lorsque PG_PORT est absent, DIU SHALL utiliser le port standard 5432.
DIU SHALL NOT exécuter le contenu de project.env, publier les identifiants ou
mots de passe, demander un mot de passe interactif, ni modifier le serveur.
Une configuration absente ou invalide, un client manquant ou un serveur
inaccessible SHALL être indiqué explicitement. Les sondes SHALL être bornées.
Le diagnostic de configuration SHALL distinguer un fichier illisible, une
affectation non littérale, une adresse absente ou invalide et un port invalide,
en utilisant uniquement des libellés fixes et les noms de variables reconnus.

#### Scenario: Serveur distant disponible

- **WHEN** project.env configure un serveur accessible dont la version diffère du client hôte
- **THEN** la rubrique serveur indique la version interrogée et l'adresse configurée
- **AND THEN** aucune valeur sensible ni erreur brute n'est affichée

#### Scenario: Configuration invalide ou serveur inaccessible

- **WHEN** la configuration est absente, contient une affectation invalide, ou la connexion échoue
- **THEN** la rubrique indique que la version serveur n'est pas vérifiable
- **AND THEN** aucune expression shell n'est exécutée ni connexion vers une adresse implicite réalisée
- **AND THEN** le diagnostic précise la catégorie d'erreur sans restituer la valeur rejetée

#### Scenario: Mot de passe contenant des caractères spéciaux

- **WHEN** PG_PASSWORD contient une valeur citée avec des caractères ayant un sens pour le shell
- **THEN** le client reçoit exactement la valeur littérale, sans expansion ni exécution
- **AND THEN** le document indique la version du serveur accessible sans afficher le mot de passe

#### Scenario: Lignes de référence de configuration

- **WHEN** la rubrique PostgreSQL Serveur est générée
- **THEN** ses deux dernières lignes sont « Les variables PostgreSQL sont chargées depuis project.env » puis « PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD »
- **AND THEN** chacune est une puce Markdown et ne contient aucune valeur sensible

### Requirement: Écriture limitée et robuste

DIU SHALL modifier uniquement DEVOPS.md dans le projet ciblé, ses artefacts
temporaires régénérables et le pyproject.toml conditionnel décrit ci-dessous. Le document SHALL être UTF-8 avec fins de ligne LF.
Tout échec de préparation ou d'écriture SHALL rendre un code non nul et
préserver le document existant. Une actualisation SHALL conserver ses droits
et sa propriété. La synchronisation des projets SHALL conserver son comportement. La création
SHALL conserver son comportement de préparation, puis effectuer la génération
DevOps finale décrite ci-dessous.

#### Scenario: Échec de remplacement

- **WHEN** la préparation ou le remplacement du document échoue
- **THEN** le document existant est conservé et l'échec est signalé

#### Scenario: Réexécution stable

- **WHEN** deux exécutions observent le même environnement
- **THEN** le contenu documentaire produit est identique

### Requirement: Manifeste Python conditionnel

Lorsque pyproject.toml est absent, DIU SHALL le créer uniquement si
l'affectation littérale PROJECT_TYPE dans project.env vaut exactement PYTHON.
Le manifeste SHALL contenir [project], le nom normalisé à partir de l'identifiant
(remplacement des caractères autres que lettres ASCII, chiffres, point, tiret et
underscore par un tiret, retrait des séparateurs aux extrémités et repli sur
project si le nom est vide), version = "0.0.0" et dependencies = [].
Un pyproject.toml existant SHALL être conservé sans modification. La lecture
de PROJECT_TYPE SHALL NOT exécuter project.env ni exposer ses valeurs.
Une configuration absente ou sans PROJECT_TYPE SHALL NOT créer de manifeste.
Un échec de création du manifeste SHALL être signalé avec un code non nul.
Si l'écriture documentaire échoue ensuite, le manifeste créé SHALL être conservé.

#### Scenario: Projet Python sans manifeste

- **WHEN** PROJECT_TYPE=PYTHON et pyproject.toml est absent
- **THEN** le manifeste minimal sans dépendance est créé sous l'utilisateur DevOps
- **AND THEN** DEVOPS.md indique l'absence de dépendances déclarées

#### Scenario: Projet non Python ou configuration absente

- **WHEN** PROJECT_TYPE est absent ou différent de PYTHON, ou project.env est absent
- **THEN** aucun pyproject.toml n'est créé

#### Scenario: Manifeste préexistant

- **WHEN** pyproject.toml existe, quel que soit PROJECT_TYPE
- **THEN** son contenu, sa propriété et ses droits sont conservés

### Requirement: Génération finale lors de la création

Après la préparation, la personnalisation et l'attribution des droits du
projet, create_project SHALL appeler projects_template_devops avec
l'identifiant du nouveau projet avant son message final de succès. La copie
SHALL exclure le pyproject.toml racine du modèle si PROJECT_TYPE est différent
de PYTHON ou absent ; un projet Python MAY conserver le manifeste copié.
Si la génération échoue, create_project SHALL rendre un code non nul,
signaler cet échec et conserver le projet déjà préparé.

#### Scenario: Création réussie

- **WHEN** la préparation du nouveau projet et la génération réussissent
- **THEN** la génération est appelée une seule fois avec le bon identifiant après l'attribution des droits
- **AND THEN** DEVOPS.md est actualisé avant le message de succès

#### Scenario: Création non Python depuis un modèle Python

- **WHEN** le modèle contient pyproject.toml et le nouveau projet est non Python
- **THEN** ce fichier racine n'est pas copié ni généré

#### Scenario: Échec de génération finale

- **WHEN** projects_template_devops échoue
- **THEN** la création signale l'échec sans message final de succès
- **AND THEN** le dossier préparé est conservé
