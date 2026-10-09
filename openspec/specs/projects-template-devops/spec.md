# projects-template-devops Specification

## Purpose
Définir la génération et l'actualisation de DEVOPS.md pour un projet ciblé
ou pour tous les projets configurés,
y compris à la fin de sa création, à partir des versions vérifiées des outils
hôte et de l'environnement DevOps, des dépendances Python déclarées et du
serveur PostgreSQL configuré, avec un manifeste minimal conditionnel pour Python.

## Requirements

### Requirement: Commande de génération du modèle DevOps

DIU SHALL fournir `projects_template_devops`, appelée par la commande
`rid projects template devops <ID PROJECT>`, avec un identifiant obligatoire.
La CLI SHALL exiger le sélecteur devops avant l'identifiant et SHALL rejeter
les anciens ordres lorsqu'ils ne correspondent pas déjà à une commande valide.
La fonction SHALL générer ou actualiser
`${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>/DEVOPS.md`. La racine SHALL utiliser
DEVOPS_PROJECTS_ROOT lorsqu'elle est définie, sinon /home/${ENV_DEVOPS_USER}/datas.
La fonction SHALL valider le nom d'utilisateur et l'identifiant de projet,
SHALL refuser les chemins, les identifiants . et .. et les liens symboliques
du dossier cible, et SHALL NOT créer le dossier du projet. L'ancienne syntaxe
sans identifiant SHALL être rejetée avec la nouvelle utilisation.

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

La rubrique Python SHALL indiquer venv et ensurepip en troisième ligne ; la rubrique pip SHALL conserver sa version et son chemin DevOps. Les dépendances SHALL provenir uniquement de [project].dependencies et être recherchées dans les venv du projet avant le repli Python DevOps. Le document SHALL conserver les contraintes et signaler manifeste absent, invalide, dynamique ou paquet introuvable/non vérifiable, sans inventer ni installer de dépendance.

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

DIU SHALL écrire seulement DEVOPS.md, ses temporaires régénérables et le manifeste Python conditionnel dans le projet ciblé, en UTF-8/LF. Tout échec de préparation ou d'écriture SHALL retourner un code non nul et préserver l'existant. L'actualisation SHALL conserver droits et propriétaire ; la synchronisation et la préparation des créations SHALL rester inchangées. Les créations SHALL finir par la génération DevOps. À observations identiques, le contenu SHALL être identique hors horodatage.

#### Scenario: Échec de remplacement

- **WHEN** la préparation ou le remplacement du document échoue
- **THEN** le document existant est conservé et l'échec est signalé

#### Scenario: Réexécution stable

- **WHEN** deux exécutions observent le même environnement
- **THEN** le contenu documentaire produit est identique hors horodatage du début du relevé
- **AND THEN** chaque document indique le début de son propre relevé

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
projet, create_project SHALL appeler projects_template_openspec puis
projects_template_devops avec l'identifiant du nouveau projet avant son message
final de succès. La copie SHALL exclure le pyproject.toml racine du modèle si
PROJECT_TYPE est différent de PYTHON ou absent ; un projet Python MAY conserver
le manifeste copié. Si une opération finale échoue, create_project SHALL rendre
un code non nul, signaler cet échec et conserver le projet déjà préparé. Un
échec OpenSpec SHALL empêcher l'appel DevOps et le message final de succès.

#### Scenario: Création réussie

- **WHEN** la préparation et les deux opérations finales réussissent
- **THEN** OpenSpec puis DevOps sont appelés une seule fois avec le bon identifiant après l'attribution des droits
- **AND THEN** DEVOPS.md est actualisé avant le message de succès

#### Scenario: Création non Python depuis un modèle Python

- **WHEN** le modèle contient pyproject.toml et le nouveau projet est non Python
- **THEN** ce fichier racine n'est pas copié ni généré

#### Scenario: Échec OpenSpec final

- **WHEN** projects_template_openspec échoue
- **THEN** DevOps n'est pas appelé et la création signale l'échec sans message final de succès
- **AND THEN** le dossier préparé est conservé

#### Scenario: Échec de génération finale

- **WHEN** projects_template_devops échoue
- **THEN** la création signale l'échec sans message final de succès
- **AND THEN** le dossier préparé est conservé

### Requirement: Génération DevOps de tous les projets configurés

DIU SHALL exposer rid projects template devops all et projects_template_devops_all.
La fonction SHALL utiliser DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas,
et parcourir uniquement ses dossiers directs, y compris les dossiers cachés.
Elle SHALL sélectionner les project.env ordinaires dont les affectations
littérales PROJECT_ID, PROJECT_NAME, PROJECT_TYPE, PROJECT_DOCKERED et
PROJECT_DEBIAN_PACKAGE sont toutes non vides. PROJECT_ID SHALL correspondre
au nom du dossier. Les valeurs 0 et No SHALL être acceptées comme renseignées.
La sélection SHALL NOT exécuter project.env, utiliser des valeurs héritées
du shell ou afficher des valeurs de configuration. Les dossiers et fichiers
project.env symboliques SHALL être ignorés. Les projets incomplets, absents,
illisibles ou invalides SHALL être signalés puis ignorés.

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

### Requirement: Bilan et poursuite du traitement groupé

La fonction SHALL conserver le comportement de génération individuelle et
l'appel en fin de création. Elle SHALL poursuivre après un échec individuel,
afficher les nombres de projets sélectionnés, réussis, ignorés et échoués,
et rendre un code non nul si une génération échoue. Sans projet éligible,
elle SHALL afficher un message et rendre un succès. Une racine absente,
un utilisateur DevOps invalide ou un Python système absent SHALL provoquer
une erreur avant génération. La commande SHALL refuser les arguments
supplémentaires et les opérations inconnues.

#### Scenario: Échec puis réussite

- **WHEN** une génération échoue et un projet suivant est éligible
- **THEN** le projet suivant est traité et le bilan compte l'échec
- **AND THEN** le code final est non nul

#### Scenario: Aucun projet éligible

- **WHEN** la racine existe mais aucun dossier ne remplit les critères
- **THEN** la commande signale l'absence de projet éligible et rend un succès

#### Scenario: Racine absente

- **WHEN** la racine configurée n'existe pas
- **THEN** la commande échoue sans créer de dossier ou de document

### Requirement: Navigateurs externes hôte pour le mode headless

DIU SHALL détecter Chromium et Firefox sur l'hôte de génération à partir du
PATH système fixe utilisé par projects_template_devops_host_binary, sans utiliser
le PATH DevOps ni des caches de frameworks de test. La recherche SHALL retenir
le premier exécutable disponible parmi chromium puis chromium-browser pour
Chromium, et firefox puis firefox-esr pour Firefox.

Chaque sous-rubrique SHALL indiquer la version relevée avec --version, puis
le chemin de l'exécutable détecté et la ligne « Mode headless : --headless ».
La section SHALL préciser que la détection de version ne vérifie pas le
fonctionnement du mode headless. Les sondes SHALL être limitées à 15 secondes
et SHALL conserver les arguments et les chemins contenant des espaces.

Un navigateur absent SHALL être indiqué par « indisponible (binaire absent) »
et « binaire introuvable ». Une sonde échouée ou sans version reconnue SHALL
être indiquée explicitement avec le chemin détecté, sans afficher les erreurs
brutes ni conserver une ancienne version. DIU SHALL NOT sélectionner une
autre variante après l'échec de la sonde du premier exécutable détecté.
Ces indisponibilités SHALL NOT empêcher la génération du document.
La détection SHALL NOT installer de logiciel ni démarrer un test de navigation.

#### Scenario: Navigateurs hôte disponibles

- **WHEN** chromium et firefox sont présents sur le PATH système hôte et leurs sondes réussissent
- **THEN** la section finale indique leurs versions, leurs chemins et l'option --headless
- **AND THEN** elle précise que le fonctionnement headless n'est pas vérifié

#### Scenario: Variantes de noms

- **WHEN** seuls chromium-browser et firefox-esr sont présents
- **THEN** leurs versions et chemins sont affichés sous Chromium et Firefox

#### Scenario: Plusieurs variantes disponibles

- **WHEN** les noms canoniques et les variantes sont tous présents
- **THEN** chromium et firefox sont retenus avant chromium-browser et firefox-esr

#### Scenario: Navigateurs absents

- **WHEN** aucun exécutable d'une famille n'est trouvé sur le PATH système hôte
- **THEN** sa sous-rubrique indique la version indisponible et le binaire introuvable
- **AND THEN** la génération peut réussir sans installation

#### Scenario: Sonde défaillante ou version non reconnue

- **WHEN** un exécutable détecté échoue, dépasse le délai ou ne produit pas de version reconnue
- **THEN** sa sous-rubrique indique explicitement la sonde échouée ou la version non reconnue et conserve son chemin
- **AND THEN** aucune variante alternative ni ancienne version ne remplace ce résultat

#### Scenario: Réexécution et appels existants

- **WHEN** une génération individuelle, groupée ou finale de création appelle projects_template_devops
- **THEN** le document produit inclut la même section finale actualisée sans doublon
- **AND THEN** les garanties existantes d'idempotence, de droits et de préservation du document en cas d'échec d'écriture restent applicables

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

Avant la première rubrique, le document SHALL identifier DIU et distinguer sondes système, outils DevOps et dépendances du projet. La légende SHALL expliquer priorité des venv, repli DevOps, source [project].dependencies et absence de qualification fonctionnelle ou de preuve de tests. Les parcours individuel, groupé et de création SHALL conserver cette présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé

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
