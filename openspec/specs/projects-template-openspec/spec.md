# projects-template-openspec Specification

## Purpose
Définir l'initialisation et l'actualisation OpenSpec d'un projet ciblé ou de
tous les projets configurés sous ENV_DEVOPS_USER, avec le profil custom et
l'intégration OpenCode conditionnelle,
avant la génération DevOps lors de la création d'un projet.

## Requirements

### Requirement: Commande OpenSpec ciblée

DIU SHALL exposer la commande OpenSpec ciblée avec sa priorité de routage, ses validations de chemin et d’utilisateur, sans lecture de project.env par la fonction individuelle.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Nouvelle syntaxe

- **WHEN** l'utilisateur exécute diu projects template openspec application
- **THEN** projects_template_openspec reçoit exactement application

#### Scenario: Ancienne syntaxe

- **WHEN** l'utilisateur exécute diu projects template application openspec
- **THEN** la commande rend un code non nul et présente la nouvelle syntaxe sans exécuter OpenSpec

#### Scenario: Projet absent ou paramètres invalides

- **WHEN** un prérequis n'est pas satisfait ou la CLI contient un argument supplémentaire
- **THEN** la commande rend un code non nul avec diagnostic sans appeler su

#### Scenario: Projet nommé all

- **WHEN** la boucle groupée sélectionne un dossier nommé all
- **THEN** la fonction individuelle traite ce projet une seule fois sans relancer le traitement groupé

#### Scenario: Projet nommé devops

- **WHEN** la commande vise openspec devops
- **THEN** OpenSpec traite uniquement le projet devops, sans lancer la génération DevOps

#### Scenario: DevOps pour un projet nommé openspec

- **WHEN** la commande vise devops openspec
- **THEN** seule la génération DevOps du projet openspec est appelée

#### Scenario: Routage et validation de la commande OpenSpec ciblée

- **WHEN** une commande template OpenSpec ciblée est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL exposer `diu projects template openspec <ID PROJECT>` et
`projects_template_openspec` avec exactement un identifiant de projet. Le
sélecteur openspec après template SHALL être prioritaire sur le routage
DevOps. L'ancienne syntaxe SHALL être rejetée lorsqu'elle ne correspond pas
déjà à une commande valide avec sélecteur openspec ou devops. Le chemin SHALL
utiliser ENV_DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas. La fonction
SHALL refuser les identifiants vides, chemins, points et caractères de contrôle,
un utilisateur DevOps absent ou invalide, un projet absent ou symbolique, et
une cible openspec symbolique ou non répertoire. La fonction individuelle
SHALL NOT lire project.env. La CLI SHALL réserver all au traitement groupé ;
la fonction individuelle SHALL pouvoir traiter directement le projet all.

### Requirement: Initialisation ou actualisation sous le compte DevOps

La fonction SHALL choisir update ou init dans le projet sous le compte DevOps, déterminer localement le choix OpenCode, transmettre les chemins littéralement et propager les échecs sans supprimer les écritures partielles.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Initialisation avec OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE=1
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --tools opencode --profile custom dans le projet

#### Scenario: Initialisation sans OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE=0
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --profile custom dans le projet

#### Scenario: Dossier OpenCode absent

- **WHEN** openspec et le dossier .opencode sont absents, avec OPENCODE égal à 0, 1, une valeur invalide, vide ou non définie
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --profile custom dans le projet
- **AND** OPENCODE conserve sa valeur configurée ou son absence dans l'appelant

#### Scenario: Fichier OpenCode non répertoire

- **WHEN** openspec est absent, .opencode est un fichier ordinaire et OPENCODE=1
- **THEN** l'initialisation utilise openspec init --profile custom

#### Scenario: Valeur invalide avec dossier OpenCode

- **WHEN** openspec est absent, le dossier .opencode est présent et OPENCODE est invalide, vide ou non défini
- **THEN** la fonction rend un code non nul avec diagnostic sans appeler su

#### Scenario: Projets mixtes sans contamination du choix OpenCode

- **WHEN** un appel groupé avec OPENCODE=1 traite un projet sans .opencode puis un projet avec ce dossier
- **THEN** le premier est initialisé sans intégration OpenCode et le second avec --tools opencode
- **AND** la variable configurée reste égale à 1

#### Scenario: Actualisation indépendante du choix OpenCode

- **WHEN** le dossier openspec existe déjà, notamment après copie du modèle, avec ou sans dossier .opencode
- **THEN** le compte ENV_DEVOPS_USER exécute openspec update dans le projet indépendamment de OPENCODE

#### Scenario: Chemin contenant des caractères shell

- **WHEN** le chemin contient espaces, apostrophes, dollars ou backticks
- **THEN** le shell enfant rejoint exactement ce chemin sans interpréter son contenu comme une commande

#### Scenario: Échec de l'outil

- **WHEN** su ou OpenSpec échoue
- **THEN** l'opération signale un échec sans annoncer de succès ni supprimer le projet

#### Scenario: Choix local OpenCode et exécution OpenSpec

- **WHEN** la fonction prépare OpenSpec dans le projet
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL exécuter dans le répertoire du projet, via
`su - "$ENV_DEVOPS_USER" -c`, `openspec update` si le dossier openspec existe.
Sinon, elle SHALL déterminer une valeur OpenCode effective locale au projet.
Sans dossier `.opencode` dans le projet, cette valeur SHALL être 0, quelle que
soit la valeur configurée de OPENCODE ; un fichier non répertoire SHALL NOT
compter comme dossier. Avec ce dossier, la valeur effective SHALL être la
valeur configurée de OPENCODE. La fonction SHALL NOT modifier la variable
OPENCODE de l'appelant ou des projets suivants.
Elle SHALL exécuter `openspec init --tools opencode --profile custom` si la
valeur effective vaut 1 et `openspec init --profile custom` si elle vaut 0.
Une valeur effective absente ou différente SHALL empêcher l'initialisation
avec diagnostic. Les caractères spéciaux du chemin SHALL être transmis
littéralement au shell enfant. Un échec SHALL produire un diagnostic et un
code non nul, sans succès. La fonction SHALL NOT supprimer les écritures
partielles d'OpenSpec.

### Requirement: Sélection OpenSpec de tous les projets configurés

DIU SHALL exposer le traitement OpenSpec groupé avec la sélection DevOps, conserver les valeurs renseignées 0 et No, et ignorer les configurations invalides sans les exécuter ni afficher leurs valeurs.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Projets éligibles

- **WHEN** des projets ordinaires, cachés ou nommés template et all remplissent les cinq critères
- **THEN** chacun est sélectionné une fois, sans parcourir leurs sous-dossiers

#### Scenario: Configuration invalide ou chemin symbolique

- **WHEN** une configuration est absente, vide, discordante, non littérale ou symbolique, ou le dossier est symbolique
- **THEN** le projet est ignoré sans exécuter sa configuration ni appeler OpenSpec

#### Scenario: Sélection sûre des projets OpenSpec groupés

- **WHEN** la fonction groupée sélectionne les projets OpenSpec
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL exposer `diu projects template openspec all` et
projects_template_openspec_all. La sélection SHALL réutiliser celle de
DevOps all : dossiers directs, cachés compris, avec project.env ordinaire
et affectations littérales non vides PROJECT_ID, PROJECT_NAME, PROJECT_TYPE,
PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE. PROJECT_ID SHALL correspondre au
nom du dossier ; 0 et No SHALL être acceptés comme renseignés. Les dossiers
et project.env symboliques, identifiants invalides et configurations absentes,
illisibles, incomplètes ou discordantes SHALL être signalés puis ignorés. La sélection SHALL NOT
exécuter project.env, hériter de valeurs du shell ou afficher les valeurs.

### Requirement: Exécution groupée OpenSpec et bilan

La fonction groupée SHALL vérifier ses prérequis, appeler les fonctions individuelles, poursuivre après un échec et produire le bilan et le statut détaillés ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Initialisation et actualisation mélangées

- **WHEN** les projets sélectionnés comprennent des dossiers avec et sans OpenSpec
- **THEN** chacun utilise sa branche individuelle init ou update sous ENV_DEVOPS_USER

#### Scenario: Échec puis réussite

- **WHEN** un projet échoue puis un autre réussit
- **THEN** les deux sont traités et le bilan compte l'échec et la réussite
- **AND THEN** le code final est non nul et les fichiers existants sont conservés

#### Scenario: Aucun projet éligible

- **WHEN** aucun projet ne remplit les critères
- **THEN** aucun appel su n'est effectué, un bilan est affiché et la commande réussit

#### Scenario: Prérequis invalide

- **WHEN** la racine, le compte, les droits, Python ou les arguments sont invalides
- **THEN** un diagnostic et un code non nul sont rendus avant traitement

#### Scenario: Exécution et bilan OpenSpec groupés

- **WHEN** la fonction exécute le traitement OpenSpec groupé
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction groupée SHALL valider ses arguments, le compte ENV_DEVOPS_USER,
les droits d'exécution root ou du compte DevOps, la racine des projets et
le Python système avant traitement. Elle SHALL appeler directement la
fonction OpenSpec individuelle pour chaque projet sélectionné et poursuivre
après un échec individuel. Elle SHALL afficher les nombres sélectionnés,
réussis, ignorés et échoués et rendre un code non nul si une opération échoue.
Sans projet éligible, elle SHALL afficher ce fait et un bilan puis rendre un
succès. Les trois commandes individuelles, leur compte su et leur appel
avant DevOps lors de create SHALL être conservés.
