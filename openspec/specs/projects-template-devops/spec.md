# projects-template-devops Specification

## Purpose
Définir la génération et l'actualisation de DEVOPS.md pour un projet ciblé
ou pour tous les projets configurés,
y compris à la fin de sa création, à partir des versions vérifiées des outils
hôte et de l'environnement DevOps, des dépendances Python et JavaScript déclarées et du
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

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version
`0.7` et l'ordre du scénario « Rubriques documentaires conservées ».
Pour template, le titre SHALL être `DEVOPS.md — Template`.
Matériel SHALL suivre immédiatement Système d'exploitation.
Chaque rubrique logicielle SHALL placer le chemin après la version ;
PostgreSQL Serveur SHALL placer l'adresse après la version.
Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.7 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Python - Outils de compilation si Cython est déclaré dans [build-system].requires, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Distinction entre hôte et environnement DevOps

DIU SHALL relever le système d'exploitation hôte et les versions des outils
hôte Docker-Compose, Git, OpenSSL et PostgreSQL Client. Docker SHALL être
relevé uniquement si ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`. DIU SHALL
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

La rubrique Python SHALL indiquer venv et ensurepip en troisième ligne ; la rubrique pip SHALL conserver sa version et son chemin DevOps. Les dépendances d’exécution de cette rubrique SHALL provenir uniquement de [project].dependencies et être recherchées dans les venv du projet avant le repli Python DevOps. Le document SHALL conserver les contraintes et signaler manifeste absent, invalide, dynamique ou paquet introuvable/non vérifiable, sans inventer ni installer de dépendance.

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

DIU SHALL limiter ses écritures à DEVOPS.md, ses temporaires et au manifeste Python conditionnel du projet, en UTF-8/LF, sauf préparation des exécutables DevOps connus. Tout échec SHALL être signalé par un code non nul et préserver l'existant. L'actualisation SHALL conserver droits et propriétaire. Synchronisation et préparation des créations SHALL rester inchangées ; les créations SHALL finir par la génération DevOps. À observations identiques, le contenu SHALL être identique hors horodatage.

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

Avant la première rubrique, DIU SHALL distinguer sondes système, outils DevOps et dépendances. La légende SHALL expliquer priorité des venv et repli DevOps, sources [project].dependencies et [build-system].requires pour Cython, manifestes JavaScript par composant, déclaration/verrou/observation et absence de qualification fonctionnelle ou preuve de tests. Les trois parcours SHALL partager cette présentation sans doublon.

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

### Requirement: Découverte des manifestes JavaScript du projet

DIU SHALL rechercher les package.json ordinaires à la racine et dans les sous-dossiers ordinaires du projet, sans suivre les liens de dossiers. Les chemins relatifs SHALL être triés. La découverte SHALL être réalisée une seule fois par rendu.

#### Scenario: Projet sans manifeste racine

- **WHEN** frontend/package.json et .opencode/package.json existent sans package.json racine
- **THEN** les deux sources peuvent être retenues et sont traitées une seule fois

### Requirement: Exclusions de découverte JavaScript

La recherche SHALL exclure node_modules, les venv détectés par pyvenv.cfg, les caches, Git, les sorties dist/build/output/reports, journaux, PROMPTS, openspec et ressources d'outillage.

#### Scenario: Manifestes tiers et générés

- **WHEN** node_modules, un venv ou une sortie contient package.json
- **THEN** ces manifestes ne sont pas découverts

### Requirement: Exception ciblée du manifeste OpenCode

La découverte SHALL traiter .opencode/package.json explicitement avec ses verrous racine associés. Elle SHALL NOT parcourir les configurations, états, commandes ou skills OpenCode.

#### Scenario: Outillage OpenCode du projet

- **WHEN** le dossier .opencode contient un manifeste et des ressources internes
- **THEN** seuls le manifeste racine et ses verrous associés servent à la déclaration

### Requirement: Sélection des manifestes JavaScript utiles

DIU SHALL retenir les manifestes racine et OpenCode présents, ceux déclarant des dépendances, ainsi que les organisateurs et membres de workspaces déclarés. Les motifs de workspaces SHALL rester relatifs et confinés au projet. Les autres manifestes vides SHALL être comptés comme non retenus.

#### Scenario: Workspace sans dépendance

- **WHEN** un membre découvert correspond à un motif de workspace déclaré et n'a aucune dépendance
- **THEN** il est retenu tandis que les autres manifestes vides sont comptés comme non retenus

### Requirement: Sources JavaScript invalides et découverte incomplète

Un manifeste invalide, illisible ou symbolique SHALL recevoir un diagnostic fixe sans exposer son contenu. Une découverte incomplète SHALL être explicite et SHALL NOT valoir absence certaine de manifeste.

#### Scenario: Manifeste impossible à lire

- **WHEN** la découverte rencontre un manifeste illisible ou une limite
- **THEN** le relevé indique cette limite sans reproduire l'erreur brute ni annoncer une absence certaine

### Requirement: Déclarations JavaScript par catégorie

Chaque inventaire SHALL identifier son manifeste et conserver séparément dependencies, devDependencies, peerDependencies et optionalDependencies, y compris lorsqu'un nom apparaît dans plusieurs groupes. Les champs engines et packageManager renseignés SHALL être rapportés comme déclarations sans déduire le gestionnaire effectif d'un verrou.

#### Scenario: Frontend et outils

- **WHEN** React relève de dependencies et Vite de devDependencies
- **THEN** les deux groupes et leurs contraintes restent distincts avec leur source

### Requirement: Références JavaScript et types sûrs

Les types incohérents SHALL être signalés. Les références URL, Git ou locales SHALL être masquées ou catégorisées sans publier de valeur sensible. Les alias npm et références workspace sûrs MAY être identifiés sans exécution. Les valeurs et chemins publiés SHALL être validés ou échappés pour préserver le Markdown.

#### Scenario: Référence privée

- **WHEN** une dépendance contient une URL ou un chemin privé
- **THEN** seule une catégorie fixe est publiée sans divulgation ni exécution

### Requirement: Versions verrouillées npm distinctes de l'installation

DIU SHALL lire les versions verrouillées depuis npm-shrinkwrap.json ou package-lock.json aux formats 2 et 3, avec priorité de npm-shrinkwrap.json. Les entrées SHALL être résolues selon leur chemin dans packages, y compris les liens internes au verrou. Un verrou SHALL NOT servir de preuve d'installation.

#### Scenario: Verrou sans paquet local

- **WHEN** le verrou indique une version mais aucune installation locale n'est observée
- **THEN** les deux informations restent distinctes

### Requirement: Verrou local et héritage de workspace

Le verrou local SHALL primer. Un membre de workspace sans verrou local MAY utiliser le verrou de son organisateur déclaré. L'inventaire SHALL citer le fichier effectivement consulté pour ce membre.

#### Scenario: Verrou partagé

- **WHEN** un workspace déclaré utilise le verrou npm de son organisateur
- **THEN** l'entrée packages pertinente est sélectionnée et la source du verrou est affichée

### Requirement: Verrous non analysés et incohérences

Les autres formats de verrou SHALL être identifiés comme non analysés. Un verrou absent, invalide, incomplet ou désynchronisé SHALL être signalé sans inventer de version. Des formats concurrents SHALL être explicites sans déduire le gestionnaire réellement utilisé.

#### Scenario: Formats concurrents

- **WHEN** des verrous npm, Yarn, pnpm ou Bun coexistent
- **THEN** les sources sont identifiées, la priorité npm est respectée et les formats non pris en charge ne fournissent pas de version

### Requirement: Recherche des installations JavaScript locales

DIU SHALL lire seulement le package.json d'installation correspondant à chaque dépendance, dans node_modules au plus près du manifeste puis dans les parents jusqu'à la racine du projet. La première installation présente SHALL primer, sans masquer une métadonnée invalide par un parent. Aucun paquet npm global ni cache extérieur SHALL être utilisé comme repli.

#### Scenario: Installation proche et partagée

- **WHEN** un paquet existe près du manifeste et à la racine
- **THEN** l'installation proche est retenue avec son chemin réel

### Requirement: Identité et confinement des paquets JavaScript

DIU SHALL rapporter version observée et chemin réel d'installation et vérifier l'identité du paquet ou de l'alias connu. Les liens de dossiers MAY être résolus uniquement dans les ressources autorisées du projet, notamment pour les workspaces et pnpm. Un fichier de métadonnées symbolique ou une cible extérieure ou protégée SHALL rester non vérifiable sans être lu.

#### Scenario: Liens d'installation

- **WHEN** un lien vise un composant interne autorisé et un autre vise un dossier extérieur
- **THEN** la cible interne peut être observée et la cible extérieure n'est pas lue

### Requirement: Absence locale et métadonnées JavaScript inconnues

Une erreur de lecture, une métadonnée invalide ou une identité incohérente SHALL être non vérifiable. Une absence complète dans les emplacements locaux pertinents SHALL être libellée non observée localement, sans conclure à l'absence globale du paquet ni au chargement d'un plugin.

#### Scenario: Métadonnée invalide

- **WHEN** le paquet proche est présent mais ses métadonnées sont illisibles
- **THEN** l'état reste non vérifiable sans utiliser un paquet global ou une installation plus haute

### Requirement: Écart entre verrou et observation JavaScript

Lorsque les versions verrouillée et observée sont connues et différentes, DIU SHALL signaler cet écart. Le relevé SHALL NOT prétendre résoudre les contraintes SemVer, qualifier le graphe ou prouver un chargement de plugin.

#### Scenario: Versions différentes

- **WHEN** le verrou indique 1.0.0 et les métadonnées locales 2.0.0
- **THEN** l'écart est affiché sans conclusion automatique de compatibilité

### Requirement: Collecte JavaScript passive

La collecte SHALL utiliser sous le compte DevOps un Python existant, isolé et sans site automatique, avec la bibliothèque standard. Elle SHALL NOT lancer npm, Bun, OpenCode, un script, un import applicatif, une installation ou une requête réseau. Elle SHALL NOT lire .npmrc, les configurations OpenCode, les fichiers env ni les secrets. L'absence de Node SHALL NOT bloquer une analyse passive disponible.

#### Scenario: Code à effet de bord

- **WHEN** un manifeste contient des scripts et un paquet contient du code exécutable
- **THEN** la collecte ne les exécute pas et ne modifie aucun fichier du projet

### Requirement: Limites de collecte JavaScript

La collecte SHALL être bornée à 12 secondes sous la borne utilisateur de 15 secondes, 10 000 entrées de découverte, 128 manifestes, 1 024 dépendances restituées, 1 Mio par manifeste ou métadonnée, 8 Mio par verrou et 32 Mio de lectures JSON cumulées.

#### Scenario: Collecte trop grande

- **WHEN** une borne de temps, de taille ou de nombre est atteinte
- **THEN** le relevé explicite son caractère incomplet

### Requirement: Analyseur JavaScript indisponible ou échoué

Une limite atteinte SHALL être explicite. Un analyseur absent ou échoué SHALL produire un diagnostic fixe sans publier sa sortie brute ni une absence certaine. La collecte SHALL utiliser le Python DevOps disponible, sinon un Python système existant pour cette seule analyse.

#### Scenario: Analyseur absent

- **WHEN** aucun analyseur utilisable n'est disponible
- **THEN** un diagnostic fixe remplace l'inventaire sans installation ni conservation de données anciennes

### Requirement: Restitution JavaScript dans les rubriques existantes

NPM SHALL recevoir la sous-section Dépendances JavaScript du projet pour les composants applicatifs retenus. OpenCode SHALL recevoir Dépendances OpenCode du projet pour .opencode/package.json. Chaque dépendance SHALL distinguer déclaration, version verrouillée npm et observation locale, avec chemin d'installation vérifié.

#### Scenario: Deux usages Pixs

- **WHEN** frontend/package.json et .opencode/package.json déclarent des paquets
- **THEN** chaque manifeste apparaît une seule fois dans sa rubrique respective

### Requirement: Cohérence des rendus JavaScript

Les sous-sections sans manifeste ni diagnostic SHALL être omises. Les versions des binaires Node, NPM et OpenCode SHALL rester distinctes des paquets. Les parcours individuel, groupé et de création SHALL utiliser le même rendu, avec ordre principal et section finale des navigateurs conservés.

#### Scenario: Parcours existants

- **WHEN** un rendu individuel, groupé ou final de création est produit
- **THEN** les sous-sections sont identiques à observations égales et n'ajoutent aucun doublon

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

### Requirement: Références Docker des tests nécessitant des droits root

La rubrique Docker SHALL porter le titre exact
`Conteneur Docker, pour tests nécessitant des droits root`. Elle SHALL contenir cinq
puces, dans cet ordre : version détectée ou diagnostic existant, chemin du
binaire ou diagnostic existant, `/var/run/docker.sock`, `debian:stable-slim`, puis la puce commune d’autorisation.
Le socket et l’image SHALL rester des références documentaires fixes.

#### Scenario: Docker disponible

- **GIVEN** ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`
- **WHEN** la version et le binaire Docker sont détectés
- **THEN** la rubrique porte le titre exact et les cinq puces dans l'ordre prévu
- **AND THEN** les deux références apparaissent chacune une seule fois

#### Scenario: Docker indisponible

- **GIVEN** ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`
- **WHEN** le binaire Docker est absent ou sa sonde échoue
- **THEN** les diagnostics existants sont conservés dans les premières puces
- **AND THEN** le socket et l'image restent indiqués sans nouvelle sonde ou action Docker

#### Scenario: Portée documentaire des références

- **WHEN** les références Docker sont ajoutées au document
- **THEN** le générateur ne sonde pas le socket, ne télécharge ni ne lance l'image et ne modifie aucune permission
- **AND THEN** leur présence ne constitue pas une preuve de disponibilité ou de fonctionnement

#### Scenario: Docker désactivé

- **WHEN** ENV_DEVOPS_TESTS_DOCKER est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique Docker, ses cinq puces et sa sonde sont omises
- **AND** Docker-Compose et les autres rubriques restent présents

### Requirement: Structure de l'inventaire matériel TPM

La rubrique Matériel SHALL contenir une sous-rubrique TPM avec six puces
dans cet ordre : Chemin, Version, Fabricant, Identifiant fournisseur,
Révision de spécification, Registres PCR. Le rendu SHALL être commun aux
générations individuelle, groupée et finale de création.

#### Scenario: Rendu matériel commun

- **WHEN** un des trois parcours génère le document
- **THEN** Matériel et TPM apparaissent une seule fois après l'OS et avant les rubriques de conteneurs activées, ou avant OpenSSH & SSHPASS si elles sont omises
- **AND THEN** les six champs sont présents dans l'ordre prévu

### Requirement: Sélection locale et version du TPM

DIU SHALL sélectionner un périphérique caractère tpmrmN avant tpmN dans
l'ordre lexical C de chaque famille. La version majeure sysfs du même
indice SHALL fournir 1.2 ou 2.0 pour les valeurs 1 ou 2. Une famille TPM 2
valide MAY compléter une version sysfs indisponible. DIU SHALL conserver
le chemin choisi si les sondes échouent, sans repli sur un autre TPM.

#### Scenario: Gestionnaire de ressources disponible

- **WHEN** /dev/tpmrm0 et /dev/tpm0 sont visibles
- **THEN** Chemin indique /dev/tpmrm0 en première puce
- **AND THEN** la version provient du sysfs de tpm0 ou de la famille observée

#### Scenario: Gestionnaire absent

- **WHEN** seul un périphérique caractère tpmN est visible
- **THEN** son chemin est sélectionné et le sysfs du même indice est utilisé

#### Scenario: Aucun périphérique visible

- **WHEN** aucun périphérique TPM n'est visible dans le contexte DIU
- **THEN** les six champs indiquent cette indisponibilité sans conclure à une absence physique
- **AND THEN** aucune sonde TPM n'est exécutée

### Requirement: Propriétés publiques du TPM

DIU SHALL utiliser uniquement properties-fixed de tpm2_getcap déjà présent
pour relever la famille, la valeur ASCII et le code hexadécimal de
TPM2_PT_MANUFACTURER, puis TPM2_PT_REVISION. Fabricant SHALL utiliser la
valeur ASCII ; Identifiant fournisseur SHALL utiliser le code hexadécimal.
Une propriété absente, invalide ou dupliquée SHALL rester non vérifiable.

#### Scenario: Propriétés disponibles

- **WHEN** la sonde renvoie des propriétés publiques reconnues
- **THEN** famille, fabricant, identifiant et révision de spécification sont rendus séparément
- **AND THEN** aucune version de firmware n'est utilisée comme révision de spécification

#### Scenario: Propriétés incomplètes ou mal formées

- **WHEN** une propriété manque, est dupliquée ou n'a pas un format reconnu
- **THEN** le champ concerné reste non vérifiable et les autres champs valides sont conservés
- **AND THEN** aucune valeur brute non reconnue n'est publiée ou exécutée

### Requirement: Inventaire des registres PCR alloués

DIU SHALL utiliser uniquement pcrs de tpm2_getcap pour indiquer les banques
et leurs indices PCR alloués. DIU SHALL NOT lire les valeurs de registres,
choisir arbitrairement un PCR ou modifier l'allocation. Une réponse vide,
ambiguë ou mal formée SHALL rester non vérifiable.

#### Scenario: Plusieurs banques allouées

- **WHEN** pcrs fournit des banques et des listes d'indices valides
- **THEN** Registres PCR contient chaque banque et ses indices sans valeur de registre

#### Scenario: PCR impossibles à relever

- **WHEN** la réponse PCR échoue ou n'est pas reconnue
- **THEN** Registres PCR indique cette limite sans bloquer la génération ni effacer les propriétés valides

### Requirement: Sondes TPM bornées et sans mutation

Chaque sonde SHALL utiliser le transport explicite device du chemin retenu,
avec 5 secondes de délai et une seconde supplémentaire avant terminaison
forcée. DIU SHALL NOT installer un outil, modifier permissions ou TPM,
utiliser un transport réseau implicite ou publier stderr. Une indisponibilité
SHALL produire un diagnostic fixe par champ sans bloquer le document.

#### Scenario: Outil absent ou accès refusé

- **WHEN** tpm2_getcap manque ou le périphérique n'est pas accessible
- **THEN** chemin et version sysfs disponibles sont conservés, les autres champs explicitent la limite
- **AND THEN** aucune installation ni élévation de privilèges n'est tentée

#### Scenario: Sonde expirée ou échouée

- **WHEN** une requête échoue ou dépasse son délai
- **THEN** ses champs indiquent une sonde échouée ou expirée sans exposer ses sorties
- **AND THEN** la génération continue avec les autres informations vérifiables

#### Scenario: TPM 1.2 visible

- **WHEN** sysfs indique un TPM 1.2
- **THEN** chemin et version sont rendus, les autres champs signalent la limite de la sonde TPM 2
- **AND THEN** tpm2_getcap n'est pas exécuté

### Requirement: Préparation des exécutables DevOps connus

Avant les inventaires et sondes du rendu commun, DIU SHALL préparer uniquement
ces chemins sous `/home/${ENV_DEVOPS_USER}` : `go/current/bin/go`,
`node/current/bin/node`, `node/current/bin/npm`, `.opencode/bin/opencode`,
`.local/npm/bin/openspec`, `python/current/bin/python3` et
`python/current/bin/pip3`. Les outils absents SHALL rester indisponibles sans
création ni installation. La version documentaire, les commandes et le
contexte des sondes SHALL rester inchangés.

#### Scenario: Sept outils présents sans droit d'exécution

- **WHEN** les sept fichiers DevOps existent sans bits d'exécution
- **THEN** DIU ajoute leurs bits ugo+x avant les inventaires et les sondes
- **AND THEN** les versions et inventaires disponibles sont relevés normalement
- **AND THEN** propriétaires, droits de lecture et d'écriture, outils hôte et autres fichiers restent inchangés

### Requirement: Confinement de la préparation DevOps

DIU SHALL résoudre chaque cible existante et SHALL vérifier qu'elle est un
fichier ordinaire dans le domicile canonique DevOps avant de modifier ses
droits. DIU SHALL NOT parcourir récursivement le domicile, modifier les outils
hôte ou modifier un autre fichier pour cette préparation. Une cible externe
ou non ordinaire SHALL être refusée sans modification de cette cible.

#### Scenario: Cible externe ou non ordinaire

- **WHEN** un chemin connu désigne une cible externe ou un objet non ordinaire
- **THEN** DIU refuse la préparation sans modifier cette cible
- **AND THEN** le document précédent est conservé

### Requirement: Ajout idempotent des droits d'exécution

DIU SHALL ajouter les seuls bits `ugo+x` manquants et SHALL conserver le
propriétaire et les droits de lecture et d'écriture. Un fichier déjà doté de
ces trois bits SHALL rester inchangé. Les liens internes SHALL être conservés.

#### Scenario: Liens symboliques internes et réexécution

- **WHEN** un chemin connu désigne un fichier via un lien interne au domicile DevOps
- **THEN** DIU prépare sa cible ordinaire sans remplacer le lien
- **AND THEN** une réexécution ne modifie pas les fichiers déjà dotés des trois bits d'exécution

### Requirement: Diagnostics et échecs de préparation DevOps

Une sonde directe SHALL distinguer fichier absent et fichier présent non
exécutable sans modifier ses droits. Une préparation impossible SHALL arrêter
la génération avec un code non nul et un diagnostic contextuel avant les
inventaires et sondes suivants. Le DEVOPS.md précédent SHALL être conservé.
Les droits déjà préparés SHALL rester appliqués sans annulation automatique.

#### Scenario: Outil absent ou sonde directe non exécutable

- **WHEN** un outil connu est absent ou une sonde directe reçoit un fichier non exécutable
- **THEN** le diagnostic distingue binaire absent et binaire non exécutable
- **AND THEN** aucun fichier manquant n'est créé ni remplacé par un outil hôte

#### Scenario: Préparation refusée

- **WHEN** une cible sort du domicile, n'est pas un fichier ordinaire, ne peut pas être résolue ou ses droits ne peuvent pas être préparés
- **THEN** DIU retourne un code non nul avec un diagnostic contextuel sans lancer les inventaires et sondes suivants
- **AND THEN** le DEVOPS.md précédent est conservé
- **AND THEN** les droits déjà préparés restent appliqués sans annulation automatique

### Requirement: Nom d'hôte dans la rubrique système

DIU SHALL ajouter en deuxième puce de Système d'exploitation le résultat
de `hostname -f`, après le nom de l'OS. La sonde SHALL utiliser le binaire
système du contexte d'exécution DIU, sans modifier le nom ni le réseau.
Sa durée SHALL être bornée à 15 secondes. Sa sortie SHALL être une seule
ligne de 1 à 253 caractères ASCII alphanumériques, points ou tirets,
commençant par un caractère alphanumérique. Une impossibilité SHALL être
rendue explicitement sans bloquer la génération.

#### Scenario: Nom d'hôte disponible

- **WHEN** hostname -f réussit avec hvp1.pixs.fr
- **THEN** la rubrique contient le nom de l'OS puis hvp1.pixs.fr en deuxième puce
- **AND THEN** hostname est appelé une seule fois avec le seul argument -f
- **AND THEN** la rubrique Matériel et les rubriques suivantes gardent leur ordre

#### Scenario: Valeur actualisée dans tous les parcours

- **WHEN** le nom retourné change entre deux générations individuelles, groupées ou à la création
- **THEN** chaque document utilise la valeur actuellement retournée sans nom codé en dur
- **AND THEN** le document porte la version 0.7

#### Scenario: Commande indisponible, échouée ou expirée

- **WHEN** hostname est absent, échoue ou dépasse la durée autorisée
- **THEN** la deuxième puce indique explicitement une indisponibilité
- **AND THEN** la génération se poursuit sans nom inventé ni erreur brute

#### Scenario: Sortie invalide

- **WHEN** hostname retourne une sortie vide, multiligne, trop longue ou contenant des caractères non admis
- **THEN** la deuxième puce indique un nom d'hôte invalide sans publier la sortie rejetée
- **AND THEN** aucune valeur ancienne ni aucun repli sur hostname sans -f n'est utilisé

### Requirement: Activation de la rubrique Docker

La rubrique Docker SHALL être générée uniquement si ENV_DEVOPS_TESTS_DOCKER vaut
exactement `1`. Une valeur absente, vide ou différente SHALL omettre la rubrique
et MUST NOT provoquer de résolution ou de sonde du binaire Docker.

#### Scenario: Indicateur Docker désactivant

- **WHEN** ENV_DEVOPS_TESTS_DOCKER est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique Docker et sa sonde sont omises, indépendamment de LXC
- **AND** Docker-Compose reste présent

### Requirement: Rubrique LXC documentaire conditionnelle

Le rendu commun SHALL générer `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH`
uniquement si ENV_DEVOPS_TESTS_LXC vaut exactement `1`, indépendamment de Docker.
Une valeur absente, vide ou différente SHALL omettre cette rubrique.
LXC SHALL suivre Docker s'il est présent, sinon Matériel, et SHALL précéder OpenSSH & SSHPASS, puis Docker-Compose.
Le format SHALL rester `0.7` et les trois parcours SHALL partager ce comportement.

#### Scenario: Deux conteneurs activés

- **WHEN** les deux indicateurs valent exactement `1`
- **THEN** les rubriques sont Matériel, Conteneur Docker, Conteneur LXC, OpenSSH & SSHPASS, Docker-Compose

#### Scenario: LXC seul

- **WHEN** seul ENV_DEVOPS_TESTS_LXC vaut exactement `1`
- **THEN** LXC suit Matériel et précède OpenSSH & SSHPASS puis Docker-Compose sans rubrique ni sonde Docker

#### Scenario: LXC désactivé

- **WHEN** ENV_DEVOPS_TESTS_LXC est absent, vide, égal à `0` ou différent de `1`
- **THEN** la rubrique LXC et ses cinq puces sont omises indépendamment de Docker

### Requirement: Contenu documentaire LXC

La rubrique LXC SHALL contenir exactement cinq puces dans l'ordre :
`Variables d'accès disponible dans project.env pour l'accès SSH`, `Debian 13`, `Accès TPM OK`,
puis la puce commune d’autorisation et enfin
`Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests.`.
Les trois premières mentions SHALL rester déclaratives et MUST NOT être présentées comme une
qualification distante.

#### Scenario: Contenu fixe demandé

- **WHEN** LXC est activé dans un des trois parcours
- **THEN** le titre et les cinq puces exactes apparaissent une seule fois dans l'ordre prévu

#### Scenario: Conservation des dépendances de test

- **WHEN** la rubrique LXC est générée
- **THEN** sa cinquième et dernière puce est exactement `Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests.`
- **AND** aucune installation ni désinstallation n’est exécutée par ce rendu documentaire

### Requirement: Absence de connexion pour le rendu LXC

Le générateur MUST NOT lire les identifiants LXC, se connecter à un conteneur
ou lancer une sonde TPM distante pour cette rubrique.

#### Scenario: Rendu sans accès distant

- **WHEN** la rubrique LXC est générée dans un des trois parcours
- **THEN** les cinq puces sont émises sans commande LXC, accès aux identifiants ou sonde TPM distante

### Requirement: Puce commune d'autorisation des tests

Chaque rubrique de conteneur activée SHALL contenir la puce exacte ci-dessous,
en dernière position pour Docker et en quatrième position pour LXC :
`Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests.`.

#### Scenario: Autorisation explicite en dernière position

- **WHEN** Docker est activé dans un des trois parcours de génération
- **THEN** sa dernière puce est la formulation validée
- **AND** elle suit l’image Docker

#### Scenario: Rubrique omise

- **WHEN** une rubrique de conteneur est désactivée
- **THEN** aucune puce d'autorisation n'est émise pour cette rubrique
- **AND** aucune autre rubrique ne reçoit cette autorisation

#### Scenario: Autorisation LXC avant la conservation des dépendances

- **WHEN** LXC est activé dans un des trois parcours de génération
- **THEN** sa quatrième puce est la formulation commune validée
- **AND** elle suit « Accès TPM OK » et précède la puce de conservation des binaires et bibliothèques

### Requirement: Portée documentaire de l'autorisation

L'ajout de la puce SHALL rester un rendu documentaire et MUST NOT modifier les
contrôles techniques de permissions des outils ou plateformes, ni lancer des
opérations de test ou de conteneur pendant la génération.
Un échec d'écriture de cette puce SHALL être propagé.

#### Scenario: Génération sans modification des permissions

- **WHEN** la puce est ajoutée à un document
- **THEN** les conditions, sondes, format 0.7 et autres rubriques restent inchangés
- **AND** aucun contrôle technique de permission n'est désactivé

#### Scenario: Échec du rendu de l'autorisation

- **WHEN** l'écriture de la puce échoue
- **THEN** le rendu retourne un statut non nul et l'ancien document est conservé

### Requirement: Rubrique locale OpenSSH et SSHPASS

Le rendu commun SHALL émettre une seule rubrique `OpenSSH & SSHPASS` après les rubriques de conteneurs présentes et avant Docker-Compose, indépendamment des indicateurs Docker et LXC. Elle SHALL contenir exactement quatre puces : version OpenSSH, chemin hôte de ssh, version sshpass, chemin hôte de sshpass. Le format SHALL rester 0.7.

#### Scenario: Rubrique dans tous les parcours

- **WHEN** un document est généré individuellement, en groupe ou en fin de création
- **THEN** la rubrique apparaît une seule fois avec ses quatre puces, après LXC s’il est actif et immédiatement avant Docker-Compose
- **AND** les conditions et contenus des autres rubriques restent préservés

#### Scenario: Conteneurs désactivés

- **WHEN** Docker et LXC sont omis
- **THEN** OpenSSH & SSHPASS suit Matériel et précède Docker-Compose

### Requirement: Sondes locales de version SSH

DIU SHALL résoudre ssh et sshpass dans le PATH système contrôlé et appeler chaque binaire une fois avec le seul argument -V, avec une borne de 15 secondes. DIU SHALL extraire uniquement la version de la première ligne OpenSSH_ ou sshpass, y compris OpenSSH sur stderr. DIU MUST NOT établir de connexion, lire d’identifiants, installer d’outil ni modifier les droits pour ces sondes.

#### Scenario: Versions observées et actualisées

- **WHEN** les binaires retournent OpenSSH_10.0p2 suivi d’informations Debian/OpenSSL et sshpass 1.10 suivi de sa licence
- **THEN** seules les versions 10.0p2 et 1.10 apparaissent avec leurs chemins respectifs
- **AND** une génération ultérieure utilise les nouvelles versions retournées, sans valeur codée en dur

#### Scenario: Outil indisponible ou sortie invalide

- **WHEN** un outil est absent, non exécutable, échoue, expire ou ne retourne pas le préfixe et une version reconnus
- **THEN** sa puce de version porte un diagnostic explicite sans sortie brute, ancienne version ni repli vers la version OpenSSL
- **AND** le chemin détecté, ou une absence explicite de binaire, reste indiqué et les autres rubriques sont générées

### Requirement: Déclaration préalable de Cython pour la compilation

DIU SHALL reconnaître le nom de distribution Cython, sans distinction de casse, uniquement dans la liste [build-system].requires du TOML. DIU SHALL émettre « Python - Outils de compilation » après pip et avant Prompts seulement si Cython est déclaré. Sans déclaration confirmée, DIU MUST NOT découvrir ou sonder des venv pour Cython. Une analyse invalide ou impossible SHALL produire un diagnostic fixe hors de cette rubrique.

#### Scenario: Cython déclaré pour la construction

- **WHEN** [build-system].requires contient Cython, cython ou une exigence Cython avec contrainte ou marqueur
- **THEN** la rubrique de compilation apparaît une seule fois après pip et avant Prompts, avec la déclaration et sa source
- **AND** les contraintes et marqueurs restent déclaratifs sans résolution, et les références directes restent masquées
- **AND** les dépendances d’exécution et autres outils de compilation restent inchangés

#### Scenario: Cython non déclaré pour la construction

- **WHEN** le manifeste est absent, sans [build-system].requires, ou déclare Cython uniquement dans une autre table, un commentaire ou un nom de distribution différent
- **THEN** la rubrique est omise et aucune découverte ni sonde Cython n’est exécutée
- **AND** un manifeste absent reste signalé par l’inventaire d’exécution existant

#### Scenario: Déclaration non vérifiable

- **WHEN** le manifeste est illisible, invalide, possède un requires mal typé ou l’analyseur est indisponible
- **THEN** le diagnostic explique que la déclaration n’est pas vérifiable sans émettre la rubrique de compilation ni conclure à une absence d’installation

### Requirement: Installation de Cython observée dans les venv du projet

Après déclaration confirmée, DIU SHALL rechercher Cython uniquement dans les venv du projet, dans l’ordre .venv, venv, env puis autres chemins triés. Les résultats SHALL distinguer version observée, « Cython : non installé » avec environnements vérifiés et « Cython : installation non vérifiable ». L’absence de venv ou une recherche ou sonde incomplète SHALL NOT prouver une absence. DIU MUST NOT utiliser de paquet global en repli.

#### Scenario: Cython installé dans un venv

- **WHEN** un venv du projet fournit des métadonnées Cython valides
- **THEN** le premier environnement selon la priorité fournit la version et les chemins observés, sans déduire un usage fonctionnel ni une conformité de version

#### Scenario: Absence vérifiée de Cython

- **WHEN** la découverte est achevée et tous les venv trouvés ont été sondés avec succès sans métadonnées Cython
- **THEN** le document indique non installé et les environnements vérifiés, même si le Python DevOps possède Cython

#### Scenario: Installation non vérifiable

- **WHEN** aucun venv n’est trouvé, ou une recherche ou sonde échoue, expire, dépasse son budget ou fournit des métadonnées ambiguës sans installation valide observée
- **THEN** le document indique installation non vérifiable avec un diagnostic fixe sans sortie rejetée

#### Scenario: Rendu et isolation communs

- **WHEN** un rendu individuel, groupé ou final de création traite un projet déclarant Cython
- **THEN** la rubrique conditionnelle est identique à observations égales, avec chemins du projet, sans import de paquet ni chargement de .pth, installation ou modification du manifeste

### Requirement: Sondes Cython isolées et rendu commun

DIU SHALL sonder les métadonnées avec -I -B -S, dans les bornes existantes de 3 secondes par sonde et 12 secondes de recherche/sondes. DIU MUST NOT importer Cython, charger de .pth, installer, compiler ni modifier le manifeste. Les trois parcours SHALL partager ce rendu au format 0.7. Les chemins observés SHALL provenir des environnements du projet ; aucune sortie rejetée SHALL être publiée.

#### Scenario: Sonde passive et bornée

- **WHEN** un environnement contient Cython, un fichier .pth à effet de bord ou un interpréteur qui expire
- **THEN** aucun paquet ni fichier .pth n’est exécuté, et toute expiration termine la sonde et ses descendants sans exposer de sortie brute
- **AND** les contraintes déclarées ne sont pas résolues et aucun fichier de manifeste n’est modifié
